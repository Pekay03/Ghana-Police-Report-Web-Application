using MySql.Data.MySqlClient;
using Org.BouncyCastle.Asn1.Cmp;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;

namespace PoliceBackgroundCheckSystem
{
    public partial class CertificateManagement : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboard();
                LoadCertificates();
            }
        }

        private bool IsAdmin()
        {
            object role = Session["Role"];

            if (role == null)
                return false;

            string normalized = Convert.ToString(role).Trim();

            return normalized.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                || normalized.Equals("Administrator", StringComparison.OrdinalIgnoreCase)
                || normalized.Equals("SystemAdmin", StringComparison.OrdinalIgnoreCase);
        }

        private void LoadDashboard()
        {
            try
            {
                const string summarySql = @"
                    SELECT
                        (SELECT COUNT(*) FROM certificates) AS TotalCertificates,
                        (SELECT COUNT(*) FROM certificates
                         WHERE DATE(IssueDate) = CURDATE()) AS IssuedToday,
                        (SELECT COUNT(DISTINCT ApplicationID)
                         FROM payments
                         WHERE PaymentVerified = 1 AND TransactionID LIKE 'HBT-%') AS PaidApplications,
                        (SELECT COUNT(*)
                         FROM applications a
                         INNER JOIN payments p
                             ON p.ApplicationID = a.ApplicationID
                            AND p.PaymentVerified = 1 AND p.TransactionID LIKE 'HBT-%'
                         LEFT JOIN certificates c
                             ON c.ApplicationReference = a.application_id
                         WHERE a.Status = 'Approved'
                           AND c.CertificateID IS NULL) AS AwaitingCertificates;";

                using (MySqlConnection connection = new MySqlConnection(connStr))
                using (MySqlCommand command = new MySqlCommand(summarySql, connection))
                {
                    connection.Open();

                    using (MySqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblTotalCertificates.Text = Convert.ToString(reader["TotalCertificates"]);
                            lblIssuedToday.Text = Convert.ToString(reader["IssuedToday"]);
                            lblPaidApplications.Text = Convert.ToString(reader["PaidApplications"]);
                            lblAwaitingCertificates.Text = Convert.ToString(reader["AwaitingCertificates"]);
                        }
                    }
                }
            }
            catch (MySqlException ex)
            {
                ShowError("Certificate summary could not be loaded because of a database error: " + ex.Message);
            }
            catch (Exception ex)
            {
                ShowError("Certificate summary could not be loaded: " + ex.Message);
            }
        }

        private void LoadCertificates()
        {
            try
            {
                string search = txtSearch.Text.Trim();
                string status = ddlStatus.SelectedValue;

                string orderBy;

                switch (ddlSort.SelectedValue)
                {
                    case "oldest":
                        orderBy = "c.IssueDate ASC, c.CertificateID ASC";
                        break;

                    case "name":
                        orderBy = "a.FullName ASC, c.CertificateID DESC";
                        break;

                    default:
                        orderBy = "c.IssueDate DESC, c.CertificateID DESC";
                        break;
                }

                string sql = @"
                    SELECT
                        c.CertificateID,
                        c.ApplicationReference,
                        c.CertificateReference,
                        c.CertificateStatus,
                        c.IssueDate,
                        a.FullName,
                        a.Purpose
                    FROM certificates c
                    INNER JOIN applications a
                        ON a.application_id = c.ApplicationReference
                    WHERE
                        (
                            @Search = ''
                            OR c.CertificateReference LIKE CONCAT('%', @Search, '%')
                            OR c.ApplicationReference LIKE CONCAT('%', @Search, '%')
                            OR a.FullName LIKE CONCAT('%', @Search, '%')
                        )
                        AND (@Status = '' OR c.CertificateStatus = @Status)
                    ORDER BY " + orderBy + ";";

                DataTable table = new DataTable();

                using (MySqlConnection connection = new MySqlConnection(connStr))
                using (MySqlCommand command = new MySqlCommand(sql, connection))
                {
                    command.Parameters.Add("@Search", MySqlDbType.VarChar, 150).Value = search;
                    command.Parameters.Add("@Status", MySqlDbType.VarChar, 30).Value = status;

                    connection.Open();

                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                    {
                        adapter.Fill(table);
                    }
                }

                gvCertificates.DataSource = table;
                gvCertificates.DataBind();
            }
            catch (MySqlException ex)
            {
                ShowError("Certificate records could not be loaded because of a database error: " + ex.Message);
            }
            catch (Exception ex)
            {
                ShowError("Certificate records could not be loaded: " + ex.Message);
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            gvCertificates.PageIndex = 0;
            LoadCertificates();
        }

        protected void gvCertificates_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvCertificates.PageIndex = e.NewPageIndex;
            LoadCertificates();
        }

        protected string GetStatusCss(object value)
        {
            string status = Convert.ToString(value);

            if (status.Equals("Issued", StringComparison.OrdinalIgnoreCase))
                return "cm-pill issued";

            return "cm-pill other";
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }
    }
}
