using System;
using System.Configuration;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class VettingDetails : Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCertificate();
            }
        }

        private void LoadCertificate()
        {
            try
            {
                if (!IsCitizenRole())
                {
                    ShowError("Only a citizen account can access a background check certificate.");
                    HideCertificate();
                    return;
                }

                string email = GetSessionEmail();

                if (string.IsNullOrWhiteSpace(email))
                {
                    ShowError("Your session has expired. Please log in again.");
                    HideCertificate();
                    return;
                }

                string applicationReference =
                    Convert.ToString(Request.QueryString["applicationId"]).Trim();

                if (string.IsNullOrWhiteSpace(applicationReference))
                {
                    ShowError("No application reference was supplied.");
                    HideCertificate();
                    return;
                }

                ApplicationDetails application =
                    GetApplication(applicationReference, email);

                if (application == null)
                {
                    ShowError("The application could not be found for your account.");
                    HideCertificate();
                    return;
                }

                if (!application.Status.Equals(
                    "Approved",
                    StringComparison.OrdinalIgnoreCase))
                {
                    ShowError(
                        "Your application has not been approved yet. " +
                        "The certificate is available only after approval."
                    );

                    HideCertificate();
                    return;
                }

                PaymentDetails payment =
                    GetVerifiedPayment(application.ApplicationID);

                if (payment == null)
                {
                    ShowError(
                        "A verified payment was not found for this application. " +
                        "The certificate cannot be issued yet."
                    );

                    HideCertificate();
                    return;
                }

                string certificateReference =
                    EnsureCertificateRecord(
                        applicationReference
                    );

                CertificateDetails certificate =
                    GetCertificate(
                        applicationReference
                    );

                if (certificate == null)
                {
                    ShowError(
                        "The certificate record could not be loaded."
                    );

                    HideCertificate();
                    return;
                }

                PopulateCertificate(
                    application,
                    payment,
                    certificate
                );

                ShowSuccess(
                    "Your background check certificate is ready."
                );
            }
            catch (MySqlException)
            {
                ShowError(
                    "The certificate could not be loaded because of a database error. " +
                    "Please make sure XAMPP MySQL is running and the database is available."
                );

                HideCertificate();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Citizen certificate load failed ({0}).",
                    ex.GetType().Name);
                ShowError("The certificate could not be loaded. Please try again later.");

                HideCertificate();
            }
        }

        private ApplicationDetails GetApplication(
            string applicationReference,
            string email)
        {
            const string sql = @"
                SELECT
                    ApplicationID,
                    application_id,
                    FullName,
                    Gender,
                    DateOfBirth,
                    NationalIDType,
                    GhanaCard,
                    Purpose,
                    Status,
                    DateSubmitted
                FROM applications
                WHERE application_id = @ApplicationReference
                  AND Email = @Email
                LIMIT 1;";

            using (MySqlConnection connection =
                new MySqlConnection(connStr))
            {
                connection.Open();

                using (MySqlCommand command =
                    new MySqlCommand(sql, connection))
                {
                    command.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationReference;

                    command.Parameters.Add(
                        "@Email",
                        MySqlDbType.VarChar,
                        255
                    ).Value = email;

                    using (MySqlDataReader reader =
                        command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        ApplicationDetails application =
                            new ApplicationDetails();

                        application.ApplicationID =
                            reader["ApplicationID"] == DBNull.Value
                                ? 0
                                : Convert.ToInt32(
                                    reader["ApplicationID"]
                                );

                        application.ApplicationReference =
                            GetString(
                                reader,
                                "application_id"
                            );

                        application.FullName =
                            GetString(
                                reader,
                                "FullName"
                            );

                        application.Gender =
                            GetString(
                                reader,
                                "Gender"
                            );

                        application.DateOfBirth =
                            GetDate(
                                reader,
                                "DateOfBirth"
                            );

                        application.NationalIDType =
                            GetString(
                                reader,
                                "NationalIDType"
                            );

                        application.GhanaCard =
                            GetString(
                                reader,
                                "GhanaCard"
                            );

                        application.Purpose =
                            GetString(
                                reader,
                                "Purpose"
                            );

                        application.Status =
                            GetString(
                                reader,
                                "Status"
                            );

                        application.DateSubmitted =
                            GetDate(
                                reader,
                                "DateSubmitted"
                            );

                        return application;
                    }
                }
            }
        }

        private PaymentDetails GetVerifiedPayment(
            int applicationId)
        {
            if (applicationId <= 0)
            {
                return null;
            }

            const string sql = @"
                SELECT
                    PaymentMethod,
                    TransactionID,
                    AmountPaid,
                    PaymentDate,
                    PaymentVerified
                FROM payments
                WHERE ApplicationID = @ApplicationID
                  AND PaymentVerified = 1
                  AND TransactionID LIKE 'HBT-%'
                ORDER BY PaymentID DESC
                LIMIT 1;";

            using (MySqlConnection connection =
                new MySqlConnection(connStr))
            {
                connection.Open();

                using (MySqlCommand command =
                    new MySqlCommand(sql, connection))
                {
                    command.Parameters.Add(
                        "@ApplicationID",
                        MySqlDbType.Int32
                    ).Value = applicationId;

                    using (MySqlDataReader reader =
                        command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        PaymentDetails payment =
                            new PaymentDetails();

                        payment.PaymentMethod =
                            GetString(
                                reader,
                                "PaymentMethod"
                            );

                        payment.TransactionID =
                            GetString(
                                reader,
                                "TransactionID"
                            );

                        payment.AmountPaid =
                            reader["AmountPaid"] == DBNull.Value
                                ? 0m
                                : Convert.ToDecimal(
                                    reader["AmountPaid"]
                                );

                        payment.PaymentDate =
                            GetDate(
                                reader,
                                "PaymentDate"
                            );

                        payment.PaymentVerified =
                            reader["PaymentVerified"] != DBNull.Value &&
                            Convert.ToInt32(
                                reader["PaymentVerified"]
                            ) == 1;

                        return payment;
                    }
                }
            }
        }

        private string EnsureCertificateRecord(
            string applicationReference)
        {
            const string findSql = @"
                SELECT CertificateReference
                FROM certificates
                WHERE ApplicationReference = @ApplicationReference
                ORDER BY CertificateID DESC
                LIMIT 1;";

            using (MySqlConnection connection =
                new MySqlConnection(connStr))
            {
                connection.Open();

                using (MySqlTransaction workflowTransaction = connection.BeginTransaction())
                {
                var workflowApplication = AdminWorkflowService.LockCertificateApplication(
                    connection, workflowTransaction, Context, applicationReference);
                using (MySqlCommand findCommand =
                    new MySqlCommand(
                        findSql,
                        connection,
                        workflowTransaction))
                {
                    findCommand.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationReference;

                    object existing =
                        findCommand.ExecuteScalar();

                    if (existing != null &&
                        existing != DBNull.Value &&
                        !string.IsNullOrWhiteSpace(
                            Convert.ToString(existing)))
                    {
                        workflowTransaction.Commit();
                        return Convert.ToString(existing);
                    }
                }

                string certificateReference =
                    GenerateCertificateReference();

                const string insertSql = @"
                    INSERT INTO certificates
                    (
                        ApplicationReference,
                        CertificateReference,
                        CertificateStatus,
                        IssueDate
                    )
                    VALUES
                    (
                        @ApplicationReference,
                        @CertificateReference,
                        @CertificateStatus,
                        @IssueDate
                    );";

                using (MySqlCommand insertCommand =
                    new MySqlCommand(
                        insertSql,
                        connection,
                        workflowTransaction))
                {
                    insertCommand.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationReference;

                    insertCommand.Parameters.Add(
                        "@CertificateReference",
                        MySqlDbType.VarChar,
                        100
                    ).Value = certificateReference;

                    insertCommand.Parameters.Add(
                        "@CertificateStatus",
                        MySqlDbType.VarChar,
                        30
                    ).Value = "Issued";

                    insertCommand.Parameters.Add(
                        "@IssueDate",
                        MySqlDbType.DateTime
                    ).Value = DateTime.Now;

                    int rows =
                        insertCommand.ExecuteNonQuery();

                    if (rows != 1)
                    {
                        throw new Exception(
                            "The certificate record could not be created."
                        );
                    }
                }

                AdminWorkflowService.AppendWorkflow(connection, workflowTransaction,
                    Convert.ToInt32(workflowApplication["ApplicationID"]), AdminWorkflowService.SessionActor(Context),
                    "CertificateIssued", "Approved", "Approved", "Certificate issuance record created: " + certificateReference);
                AdminWorkflowService.Audit(connection, workflowTransaction, Context,
                    AdminWorkflowService.SessionActor(Context), null, "CertificateIssued",
                    "Application " + applicationReference + "; certificate " + certificateReference);
                workflowTransaction.Commit();
                return certificateReference;
                }
            }
        }

        private CertificateDetails GetCertificate(
            string applicationReference)
        {
            const string sql = @"
                SELECT
                    CertificateReference,
                    CertificateStatus,
                    IssueDate
                FROM certificates
                WHERE ApplicationReference = @ApplicationReference
                ORDER BY CertificateID DESC
                LIMIT 1;";

            using (MySqlConnection connection =
                new MySqlConnection(connStr))
            {
                connection.Open();

                using (MySqlCommand command =
                    new MySqlCommand(
                        sql,
                        connection))
                {
                    command.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationReference;

                    using (MySqlDataReader reader =
                        command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        CertificateDetails certificate =
                            new CertificateDetails();

                        certificate.CertificateReference =
                            GetString(
                                reader,
                                "CertificateReference"
                            );

                        certificate.CertificateStatus =
                            GetString(
                                reader,
                                "CertificateStatus"
                            );

                        certificate.IssueDate =
                            GetDate(
                                reader,
                                "IssueDate"
                            );

                        return certificate;
                    }
                }
            }
        }

        private void PopulateCertificate(
            ApplicationDetails application,
            PaymentDetails payment,
            CertificateDetails certificate)
        {
            lblCertificateStatus.InnerText =
                string.IsNullOrWhiteSpace(
                    certificate.CertificateStatus)
                    ? "Issued"
                    : certificate.CertificateStatus;

            lblCertificateReference.InnerText =
                certificate.CertificateReference;

            lblApplicationReference.InnerText =
                application.ApplicationReference;

            lblFullName.InnerText =
                application.FullName;

            lblGender.InnerText =
                application.Gender;

            lblDateOfBirth.InnerText =
                FormatDate(
                    application.DateOfBirth
                );

            string nationalIdText =
                application.NationalIDType;

            if (!string.IsNullOrWhiteSpace(
                application.GhanaCard))
            {
                nationalIdText +=
                    " — " +
                    MaskNationalId(
                        application.GhanaCard
                    );
            }

            lblNationalId.InnerText =
                nationalIdText;

            lblPurpose.InnerText =
                application.Purpose;

            lblApplicationStatus.InnerText =
                application.Status;

            lblDateSubmitted.InnerText =
                FormatDateTime(
                    application.DateSubmitted
                );

            lblIssueDate.InnerText =
                FormatDateTime(
                    certificate.IssueDate
                );

            lblPaymentMethod.InnerText =
                payment.PaymentMethod;

            lblAmountPaid.InnerText =
                "GHS " +
                payment.AmountPaid.ToString("0.00");

            lblTransactionId.InnerText =
                payment.TransactionID;

            lblPaymentVerification.InnerText =
                payment.PaymentVerified
                    ? "Verified"
                    : "Not Verified";
        }

        private string MaskNationalId(
            string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return "";
            }

            string clean =
                value.Trim();

            if (clean.Length <= 4)
            {
                return clean;
            }

            return
                new string(
                    '•',
                    clean.Length - 4
                ) +
                clean.Substring(
                    clean.Length - 4
                );
        }

        private string GenerateCertificateReference()
        {
            return
                "GPRS-CERT-" +
                DateTime.Now.ToString("yyyyMMdd") +
                "-" +
                Guid.NewGuid()
                    .ToString("N")
                    .Substring(0, 8)
                    .ToUpperInvariant();
        }

        private bool IsCitizenRole()
        {
            string role =
                Convert.ToString(
                    Session["Role"]
                );

            return role.Equals(
                "Citizen",
                StringComparison.OrdinalIgnoreCase
            );
        }

        private string GetSessionEmail()
        {
            string email =
                Convert.ToString(
                    Session["Email"]
                );

            return string.IsNullOrWhiteSpace(email)
                ? null
                : email.Trim();
        }

        private string GetString(
            MySqlDataReader reader,
            string column)
        {
            if (reader[column] == DBNull.Value)
            {
                return "";
            }

            return Convert.ToString(
                reader[column]
            ).Trim();
        }

        private DateTime GetDate(
            MySqlDataReader reader,
            string column)
        {
            if (reader[column] == DBNull.Value)
            {
                return DateTime.MinValue;
            }

            return Convert.ToDateTime(
                reader[column]
            );
        }

        private string FormatDate(
            DateTime value)
        {
            return value == DateTime.MinValue
                ? "Not available"
                : value.ToString("dd MMMM yyyy");
        }

        private string FormatDateTime(
            DateTime value)
        {
            return value == DateTime.MinValue
                ? "Not available"
                : value.ToString("dd MMMM yyyy, HH:mm");
        }

        private void ShowError(
            string message)
        {
            pnlError.Attributes["class"] =
                "message-box message-error show";

            litError.InnerText =
                message;
        }

        private void ShowSuccess(
            string message)
        {
            pnlSuccess.Attributes["class"] =
                "message-box message-success show";

            litSuccess.InnerText =
                message;
        }

        private void HideCertificate()
        {
            if (pnlCertificate != null)
            {
                pnlCertificate.Visible = false;
            }
        }

        private sealed class ApplicationDetails
        {
            public int ApplicationID { get; set; }
            public string ApplicationReference { get; set; }
            public string FullName { get; set; }
            public string Gender { get; set; }
            public DateTime DateOfBirth { get; set; }
            public string NationalIDType { get; set; }
            public string GhanaCard { get; set; }
            public string Purpose { get; set; }
            public string Status { get; set; }
            public DateTime DateSubmitted { get; set; }
        }

        private sealed class PaymentDetails
        {
            public string PaymentMethod { get; set; }
            public string TransactionID { get; set; }
            public decimal AmountPaid { get; set; }
            public DateTime PaymentDate { get; set; }
            public bool PaymentVerified { get; set; }
        }

        private sealed class CertificateDetails
        {
            public string CertificateReference { get; set; }
            public string CertificateStatus { get; set; }
            public DateTime IssueDate { get; set; }
        }
    }
}
