using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace PoliceBackgroundCheckSystem
{
    public partial class VettingDashboard : System.Web.UI.Page
    {
        // ---------------------------------------------------------
        // DATABASE CONNECTION
        // ---------------------------------------------------------

        private readonly string connStr =
            ConfigurationManager
                .ConnectionStrings["PoliceReportDB"]
                .ConnectionString;
        private int authenticatedOfficerUserId;
        private string authenticatedOfficerName = string.Empty;


        // ---------------------------------------------------------
        // PAGE LOAD
        // ---------------------------------------------------------

        protected void Page_Load(object sender, EventArgs e)
        {
            // Only authenticated police officers can access
            // the vetting dashboard.
            if (!IsOfficerAuthenticated())
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Refresh from the authenticated database account on every request,
            // including postbacks. This is not an invented staff/badge number.
            LoadOfficerInformation();
            if (!IsPostBack)
            {

                ViewState["SortExpression"] =
                    "DateSubmitted";

                ViewState["SortDirection"] =
                    "DESC";

                LoadStatistics();

                LoadApplications();

                ResetVerificationDisplay();

                PrepareReviewControls();
            }
        }


        // ---------------------------------------------------------
        // CHECK POLICE OFFICER LOGIN
        // ---------------------------------------------------------

        private bool IsOfficerAuthenticated()
        {
            try
            {
                if (Session["IsAuthenticated"] == null)
                    return false;

                bool authenticated;

                if (!bool.TryParse(
                        Session["IsAuthenticated"].ToString(),
                        out authenticated))
                {
                    return false;
                }

                if (!authenticated)
                    return false;

                string role =
                    Convert.ToString(
                        Session["Role"]).Trim();

                if (string.IsNullOrWhiteSpace(role))
                    return false;

                string normalizedRole =
                    role
                        .Replace(" ", "")
                        .Replace("-", "")
                        .Replace("_", "")
                        .ToUpperInvariant();

                bool officerRole =
                    normalizedRole == "POLICEOFFICER" ||
                    normalizedRole == "OFFICER" ||
                    normalizedRole == "POLICE" ||
                    normalizedRole == "VETTING";
                int userId;
                if (!officerRole ||
                    !int.TryParse(Convert.ToString(Session["UserID"]), out userId) ||
                    userId <= 0)
                    return false;

                using (MySqlConnection connection = new MySqlConnection(connStr))
                {
                    connection.Open();
                    using (MySqlCommand command = new MySqlCommand(
                        "SELECT UserID, FirstName, LastName, Email, Role, IsActive FROM users WHERE UserID=@UserID LIMIT 1;",
                        connection))
                    {
                        command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = userId;
                        using (MySqlDataReader reader = command.ExecuteReader())
                        {
                            if (!reader.Read() || !Convert.ToBoolean(reader["IsActive"]))
                                return false;
                            string currentRole = Convert.ToString(reader["Role"])
                                .Replace(" ", "").Replace("-", "").Replace("_", "").ToUpperInvariant();
                            bool allowed = currentRole == "POLICEOFFICER" ||
                                currentRole == "OFFICER" ||
                                currentRole == "POLICE" ||
                                currentRole == "VETTING";
                            if (!allowed) return false;
                            authenticatedOfficerUserId = Convert.ToInt32(reader["UserID"]);
                            authenticatedOfficerName = (Convert.ToString(reader["FirstName"]) +
                                " " + Convert.ToString(reader["LastName"])).Trim();
                            if (string.IsNullOrWhiteSpace(authenticatedOfficerName))
                                authenticatedOfficerName = Convert.ToString(reader["Email"]).Trim();
                            if (string.IsNullOrWhiteSpace(authenticatedOfficerName))
                                authenticatedOfficerName = "Account #" + authenticatedOfficerUserId;
                            Session["FullName"] = authenticatedOfficerName;
                            Session["UserFullName"] = authenticatedOfficerName;
                            return true;
                        }
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        private bool RequireOfficerAuthentication()
        {
            if (IsOfficerAuthenticated())
                return true;

            Response.Redirect("~/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
            return false;
        }


        // ---------------------------------------------------------
        // LOAD OFFICER INFORMATION
        // ---------------------------------------------------------

        private void LoadOfficerInformation()
        {
            lblOfficerName.Text = Server.HtmlEncode(authenticatedOfficerName);
            lblOfficerStaffId.Text = authenticatedOfficerUserId.ToString();
        }


        // ---------------------------------------------------------
        // GET CURRENT OFFICER IDENTITY
        // ---------------------------------------------------------

        private string GetCurrentOfficerIdentity()
        {
            if (authenticatedOfficerUserId <= 0 ||
                string.IsNullOrWhiteSpace(authenticatedOfficerName))
                throw new InvalidOperationException("An authenticated officer account is required.");
            return authenticatedOfficerName + " (account #" + authenticatedOfficerUserId + ")";
        }


        // ---------------------------------------------------------
        // LOAD DASHBOARD STATISTICS
        // ---------------------------------------------------------

        private void LoadStatistics()
        {
            try
            {
                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();

                    const string sql = @"
                        SELECT
                            COUNT(*) AS TotalApplications,

                            SUM(
                                CASE
                                    WHEN LOWER(TRIM(COALESCE(Status, '')))
                                         IN ('pending', 'pending approval')
                                    THEN 1
                                    ELSE 0
                                END
                            ) AS PendingApplications,

                            SUM(
                                CASE
                                    WHEN LOWER(TRIM(COALESCE(Status, '')))
                                         = 'approved'
                                    THEN 1
                                    ELSE 0
                                END
                            ) AS ApprovedApplications,

                            SUM(
                                CASE
                                    WHEN LOWER(TRIM(COALESCE(Status, '')))
                                         = 'rejected'
                                    THEN 1
                                    ELSE 0
                                END
                            ) AS RejectedApplications

                        FROM applications;";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               sql,
                               connection))
                    using (MySqlDataReader reader =
                           command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblTotal.Text =
                                SafeCount(
                                    reader["TotalApplications"]);

                            lblPending.Text =
                                SafeCount(
                                    reader["PendingApplications"]);

                            lblApproved.Text =
                                SafeCount(
                                    reader["ApprovedApplications"]);

                            lblRejected.Text =
                                SafeCount(
                                    reader["RejectedApplications"]);
                        }
                        else
                        {
                            SetStatisticsToZero();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                SetStatisticsToZero();

                ShowApplicationError(
                    "Dashboard statistics could not be loaded.",
                    ex);
            }
        }


        // ---------------------------------------------------------
        // SAFE COUNT
        // ---------------------------------------------------------

        private string SafeCount(object value)
        {
            if (value == null ||
                value == DBNull.Value)
            {
                return "0";
            }

            int number;

            if (int.TryParse(
                    value.ToString(),
                    out number))
            {
                return number.ToString();
            }

            return "0";
        }


        // ---------------------------------------------------------
        // SET STATISTICS TO ZERO
        // ---------------------------------------------------------

        private void SetStatisticsToZero()
        {
            lblTotal.Text = "0";
            lblPending.Text = "0";
            lblApproved.Text = "0";
            lblRejected.Text = "0";
        }


        // ---------------------------------------------------------
        // LOAD CITIZEN APPLICATIONS
        // ---------------------------------------------------------

        private void LoadApplications()
        {
            string selectedStatus =
                ddlStatus.SelectedValue;

            string applicantName =
                txtSearchName.Text.Trim();

            string cardNumber =
                txtSearchCard.Text.Trim();

            if (string.IsNullOrWhiteSpace(
                selectedStatus))
            {
                selectedStatus = "All";
            }

            try
            {
                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();

                    string sql = @"
                        SELECT
                            application_id,
                            FullName,
                            GhanaCard,
                            Purpose,
                            Status,
                            DateSubmitted

                        FROM applications

                        WHERE 1 = 1";

                    if (!string.Equals(
                            selectedStatus,
                            "All",
                            StringComparison.OrdinalIgnoreCase))
                    {
                        if (string.Equals(
                                selectedStatus,
                                "Pending",
                                StringComparison.OrdinalIgnoreCase))
                        {
                            sql += @"
                                AND LOWER(TRIM(COALESCE(Status, '')))
                                IN ('pending', 'pending approval')";
                        }
                        else
                        {
                            sql += @"
                                AND LOWER(TRIM(COALESCE(Status, '')))
                                = LOWER(@Status)";
                        }
                    }

                    if (!string.IsNullOrWhiteSpace(
                        applicantName))
                    {
                        sql += @"
                            AND LOWER(COALESCE(FullName, ''))
                            LIKE LOWER(
                                CONCAT(
                                    '%',
                                    @ApplicantName,
                                    '%'
                                )
                            )";
                    }

                    if (!string.IsNullOrWhiteSpace(
                        cardNumber))
                    {
                        sql += @"
                            AND LOWER(COALESCE(GhanaCard, ''))
                            LIKE LOWER(
                                CONCAT(
                                    '%',
                                    @CardNumber,
                                    '%'
                                )
                            )";
                    }

                    sql +=
                        " ORDER BY " +
                        GetSafeOrderBy() +
                        ";";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               sql,
                               connection))
                    {
                        if (!string.Equals(
                                selectedStatus,
                                "All",
                                StringComparison.OrdinalIgnoreCase) &&
                            !string.Equals(
                                selectedStatus,
                                "Pending",
                                StringComparison.OrdinalIgnoreCase))
                        {
                            command.Parameters.Add(
                                "@Status",
                                MySqlDbType.VarChar,
                                50).Value =
                                selectedStatus;
                        }

                        if (!string.IsNullOrWhiteSpace(
                            applicantName))
                        {
                            command.Parameters.Add(
                                "@ApplicantName",
                                MySqlDbType.VarChar,
                                150).Value =
                                applicantName;
                        }

                        if (!string.IsNullOrWhiteSpace(
                            cardNumber))
                        {
                            command.Parameters.Add(
                                "@CardNumber",
                                MySqlDbType.VarChar,
                                50).Value =
                                cardNumber;
                        }

                        DataTable table =
                            new DataTable();

                        using (MySqlDataAdapter adapter =
                               new MySqlDataAdapter(
                                   command))
                        {
                            adapter.Fill(table);
                        }

                        gvApplications.DataSource =
                            table;

                        gvApplications.DataBind();

                        ViewState["ApplicationCount"] =
                            table.Rows.Count;
                    }
                }
            }
            catch (MySqlException ex)
            {
                gvApplications.DataSource =
                    null;

                gvApplications.DataBind();

                ShowDatabaseError(
                    "Citizen applications could not be loaded.",
                    ex);
            }
            catch (Exception ex)
            {
                gvApplications.DataSource =
                    null;

                gvApplications.DataBind();

                ShowApplicationError(
                    "Citizen applications could not be loaded.",
                    ex);
            }
        }


        // ---------------------------------------------------------
        // SEARCH
        // ---------------------------------------------------------

        protected void btnSearch_Click(
            object sender,
            EventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            ViewState["SortExpression"] =
                "DateSubmitted";

            ViewState["SortDirection"] =
                "DESC";

            LoadApplications();
        }


        // ---------------------------------------------------------
        // CLEAR SEARCH
        // ---------------------------------------------------------

        protected void btnClear_Click(
            object sender,
            EventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            ddlStatus.SelectedIndex = 0;

            txtSearchName.Text =
                string.Empty;

            txtSearchCard.Text =
                string.Empty;

            ViewState["SortExpression"] =
                "DateSubmitted";

            ViewState["SortDirection"] =
                "DESC";

            LoadStatistics();

            LoadApplications();
        }


        // ---------------------------------------------------------
        // GRID SORTING
        // ---------------------------------------------------------

        protected void gvApplications_Sorting(
            object sender,
            GridViewSortEventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            string requestedExpression =
                e.SortExpression;

            string currentExpression =
                Convert.ToString(
                    ViewState["SortExpression"]);

            string currentDirection =
                Convert.ToString(
                    ViewState["SortDirection"]);

            if (string.Equals(
                    currentExpression,
                    requestedExpression,
                    StringComparison.OrdinalIgnoreCase))
            {
                ViewState["SortDirection"] =
                    currentDirection == "ASC"
                    ? "DESC"
                    : "ASC";
            }
            else
            {
                ViewState["SortExpression"] =
                    requestedExpression;

                ViewState["SortDirection"] =
                    "ASC";
            }

            LoadApplications();
        }


        // ---------------------------------------------------------
        // SAFE SORT ORDER
        // ---------------------------------------------------------

        private string GetSafeOrderBy()
        {
            string sortExpression =
                Convert.ToString(
                    ViewState["SortExpression"]);

            string sortDirection =
                Convert.ToString(
                    ViewState["SortDirection"]);

            string databaseColumn;

            switch (
                (sortExpression ?? "")
                .Trim()
                .ToLowerInvariant())
            {
                case "application_id":

                    databaseColumn =
                        "application_id";

                    break;

                case "fullname":
                case "applicant_name":

                    databaseColumn =
                        "FullName";

                    break;

                case "ghanacard":
                case "id_number":

                    databaseColumn =
                        "GhanaCard";

                    break;

                case "purpose":

                    databaseColumn =
                        "Purpose";

                    break;

                case "status":

                    databaseColumn =
                        "Status";

                    break;

                case "datesubmitted":
                case "submitted_date":

                    databaseColumn =
                        "DateSubmitted";

                    break;

                default:

                    databaseColumn =
                        "DateSubmitted";

                    break;
            }

            string safeDirection =
                string.Equals(
                    sortDirection,
                    "ASC",
                    StringComparison.OrdinalIgnoreCase)
                ? "ASC"
                : "DESC";

            return
                "`" +
                databaseColumn +
                "` " +
                safeDirection;
        }


        // ---------------------------------------------------------
        // GRID ROW COMMAND
        // ---------------------------------------------------------

        protected void gvApplications_RowCommand(
            object sender,
            GridViewCommandEventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            if (!string.Equals(
                    e.CommandName,
                    "ViewApplication",
                    StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            string applicationId =
                ResolveApplicationId(
                    e.CommandArgument);

            if (string.IsNullOrWhiteSpace(
                applicationId))
            {
                ShowApplicationMessage(
                    "The selected application could not be identified.");

                return;
            }

            LoadApplicationDetails(
                applicationId);
        }


        // ---------------------------------------------------------
        // RESOLVE APPLICATION ID
        // ---------------------------------------------------------

        private string ResolveApplicationId(
            object commandArgument)
        {
            string argument =
                Convert.ToString(
                    commandArgument).Trim();

            if (string.IsNullOrWhiteSpace(
                argument))
            {
                return string.Empty;
            }

            foreach (DataKey key in
                     gvApplications.DataKeys)
            {
                if (key == null ||
                    key.Value == null)
                {
                    continue;
                }

                string keyValue =
                    Convert.ToString(
                        key.Value).Trim();

                if (string.Equals(
                        keyValue,
                        argument,
                        StringComparison.OrdinalIgnoreCase))
                {
                    return keyValue;
                }
            }

            int rowIndex;

            if (int.TryParse(
                    argument,
                    out rowIndex))
            {
                if (rowIndex >= 0 &&
                    rowIndex <
                    gvApplications.DataKeys.Count)
                {
                    object keyValue =
                        gvApplications
                            .DataKeys[rowIndex]
                            .Value;

                    return
                        Convert.ToString(
                            keyValue).Trim();
                }
            }

            return argument;
        }


        // ---------------------------------------------------------
        // LOAD COMPLETE APPLICATION
        // ---------------------------------------------------------

        private void LoadApplicationDetails(
            string applicationId)
        {
            if (string.IsNullOrWhiteSpace(
                applicationId))
            {
                ShowApplicationMessage(
                    "Application ID is missing.");

                return;
            }

            try
            {
                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();

                    const string sql = @"
                        SELECT
                            application_id,
                            FullName,
                            Gender,
                            DateOfBirth,
                            MaritalStatus,
                            PlaceOfBirth,
                            GPSAddress,
                            Email,
                            Phone,
                            Profession,
                            NextOfKinName,
                            NextOfKinPhone,
                            NationalIDType,
                            GhanaCard,
                            IDIssueDate,
                            IDIssueLocation,
                            Purpose,
                            EmployerName,
                            EmploymentPosition,
                            EmployerAddress,
                            InstitutionName,
                            ProgrammeName,
                            StudentID,
                            DestinationCountry,
                            VisaType,
                            TravelDate,
                            OtherPurpose,
                            Status,
                            DateSubmitted,
                            ReviewedBy,
                            ReviewedAt,
                            ReviewNotes,
                            RejectionReason

                        FROM applications

                        WHERE application_id =
                              @ApplicationId

                        LIMIT 1;";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               sql,
                               connection))
                    {
                        command.Parameters.Add(
                            "@ApplicationId",
                            MySqlDbType.VarChar,
                            50).Value =
                            applicationId.Trim();

                        using (MySqlDataReader reader =
                               command.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowApplicationMessage(
                                    "The selected application could not be found.");

                                return;
                            }

                            PopulateApplicationModal(
                                reader);
                        }
                    }
                }

                // Store the currently opened application.
                ViewState["CurrentApplicationId"] =
                    applicationId;

                // Load previously saved verification.
                LoadExistingVerification(
                    applicationId);

                LoadIdentityDocumentPanel(
                    applicationId,
                    false);

                // Prepare approval/rejection controls.
                PrepareReviewControls();

                OpenModal();
            }
            catch (MySqlException ex)
            {
                ShowDatabaseError(
                    "The application review could not be opened.",
                    ex);
            }
            catch (Exception ex)
            {
                ShowApplicationError(
                    "The application review could not be opened.",
                    ex);
            }
        }


        // ---------------------------------------------------------
        // POPULATE EXISTING MODAL
        // ---------------------------------------------------------

        private void PopulateApplicationModal(
            MySqlDataReader reader)
        {
            string applicationId =
                GetReaderString(
                    reader,
                    "application_id");

            string fullName =
                GetReaderString(
                    reader,
                    "FullName");

            string gender =
                GetReaderString(
                    reader,
                    "Gender");

            string dob =
                GetReaderDate(
                    reader,
                    "DateOfBirth",
                    "dd MMM yyyy");

            string maritalStatus =
                GetReaderString(
                    reader,
                    "MaritalStatus");

            string placeOfBirth =
                GetReaderString(
                    reader,
                    "PlaceOfBirth");

            string gpsAddress =
                GetReaderString(
                    reader,
                    "GPSAddress");

            string email =
                GetReaderString(
                    reader,
                    "Email");

            string phone =
                GetReaderString(
                    reader,
                    "Phone");

            string profession =
                GetReaderString(
                    reader,
                    "Profession");

            string nextOfKinName =
                GetReaderString(
                    reader,
                    "NextOfKinName");

            string nextOfKinPhone =
                GetReaderString(
                    reader,
                    "NextOfKinPhone");

            string idType =
                GetReaderString(
                    reader,
                    "NationalIDType");

            string idNumber =
                GetReaderString(
                    reader,
                    "GhanaCard");

            string idIssueDate =
                GetReaderDate(
                    reader,
                    "IDIssueDate",
                    "dd MMM yyyy");

            string idIssueLocation =
                GetReaderString(
                    reader,
                    "IDIssueLocation");

            string purpose =
                GetReaderString(
                    reader,
                    "Purpose");

            string employer =
                GetReaderString(
                    reader,
                    "EmployerName");

            string employmentPosition =
                GetReaderString(
                    reader,
                    "EmploymentPosition");

            string employerAddress =
                GetReaderString(
                    reader,
                    "EmployerAddress");

            string institution =
                GetReaderString(
                    reader,
                    "InstitutionName");

            string programme =
                GetReaderString(
                    reader,
                    "ProgrammeName");

            string studentId =
                GetReaderString(
                    reader,
                    "StudentID");

            string destination =
                GetReaderString(
                    reader,
                    "DestinationCountry");

            string visaType =
                GetReaderString(
                    reader,
                    "VisaType");

            string travelDate =
                GetReaderDate(
                    reader,
                    "TravelDate",
                    "dd MMM yyyy");

            string otherPurpose =
                GetReaderString(
                    reader,
                    "OtherPurpose");

            string status =
                GetReaderString(
                    reader,
                    "Status");

            string reviewedBy =
                GetReaderString(
                    reader,
                    "ReviewedBy");

            string reviewedAt =
                GetReaderDateTime(
                    reader,
                    "ReviewedAt",
                    "dd MMM yyyy HH:mm");

            string reviewNotes =
                GetReaderString(
                    reader,
                    "ReviewNotes");

            string rejectionReason =
                GetReaderString(
                    reader,
                    "RejectionReason");


            // -----------------------------------------------------
            // APPLICANT INFORMATION
            // -----------------------------------------------------

            lblModalApplicationId.Text =
                EncodeOrDefault(
                    applicationId);

            lblModalName.Text =
                EncodeOrDefault(
                    fullName);

            lblModalGender.Text =
                EncodeOrDefault(
                    gender);

            lblModalDob.Text =
                EncodeOrDefault(
                    dob);

            lblModalMarital.Text =
                EncodeOrDefault(
                    maritalStatus);

            lblModalBirthPlace.Text =
                EncodeOrDefault(
                    placeOfBirth);

            lblModalProfession.Text =
                EncodeOrDefault(
                    profession);

            lblModalGps.Text =
                EncodeOrDefault(
                    gpsAddress);

            lblModalEmail.Text =
                EncodeOrDefault(
                    email);

            lblModalPhone.Text =
                EncodeOrDefault(
                    phone);


            // -----------------------------------------------------
            // IDENTITY
            // -----------------------------------------------------

            lblModalIdType.Text =
                EncodeOrDefault(
                    idType);
            ViewState["CurrentIdType"] = idType;
            btnVerifyIdentity.Visible = idType.Equals(
                "Ghana Card",
                StringComparison.OrdinalIgnoreCase);

            lblModalIdNumber.Text =
                EncodeOrDefault(
                    idNumber);

            lblModalIdIssueDate.Text =
                EncodeOrDefault(
                    idIssueDate);

            lblModalIdIssueLocation.Text =
                EncodeOrDefault(
                    idIssueLocation);


            // -----------------------------------------------------
            // NEXT OF KIN
            // -----------------------------------------------------

            lblModalKinName.Text =
                EncodeOrDefault(
                    nextOfKinName);

            lblModalKinPhone.Text =
                EncodeOrDefault(
                    nextOfKinPhone);


            // -----------------------------------------------------
            // PURPOSE
            // -----------------------------------------------------

            lblModalPurpose.Text =
                EncodeOrDefault(
                    purpose);

            pnlEmployment.Visible =
                false;

            pnlEducation.Visible =
                false;

            pnlTravel.Visible =
                false;

            pnlOther.Visible =
                false;

            string normalizedPurpose =
                (purpose ?? "")
                .Trim()
                .ToLowerInvariant();


            if (normalizedPurpose.Contains(
                "employment"))
            {
                pnlEmployment.Visible =
                    true;

                lblModalEmployer.Text =
                    EncodeOrDefault(
                        employer);

                lblModalEmploymentPosition.Text =
                    EncodeOrDefault(
                        employmentPosition);

                lblModalEmployerAddress.Text =
                    EncodeOrDefault(
                        employerAddress);
            }
            else if (
                normalizedPurpose.Contains(
                    "education"))
            {
                pnlEducation.Visible =
                    true;

                lblModalInstitution.Text =
                    EncodeOrDefault(
                        institution);

                lblModalProgramme.Text =
                    EncodeOrDefault(
                        programme);

                lblModalStudentId.Text =
                    EncodeOrDefault(
                        studentId);
            }
            else if (
                normalizedPurpose.Contains(
                    "travel") ||
                normalizedPurpose.Contains(
                    "visa"))
            {
                pnlTravel.Visible =
                    true;

                lblModalDestination.Text =
                    EncodeOrDefault(
                        destination);

                lblModalVisaType.Text =
                    EncodeOrDefault(
                        visaType);

                lblModalTravelDate.Text =
                    EncodeOrDefault(
                        travelDate);
            }
            else
            {
                pnlOther.Visible =
                    true;

                lblModalOtherPurpose.Text =
                    EncodeOrDefault(
                        otherPurpose);
            }


            // -----------------------------------------------------
            // VERIFICATION APPLICANT INFORMATION
            // -----------------------------------------------------

            lblVerificationCardNumber.Text =
                EncodeOrDefault(
                    idNumber);

            lblVerificationApplicantName.Text =
                EncodeOrDefault(
                    fullName);

            lblVerificationApplicantDob.Text =
                EncodeOrDefault(
                    dob);

            lblVerificationApplicantGender.Text =
                EncodeOrDefault(
                    gender);


            // -----------------------------------------------------
            // EXISTING REVIEW INFORMATION
            // -----------------------------------------------------

            SetDynamicControlText(
                "txtReviewNotes",
                reviewNotes);

            SetDynamicControlText(
                "txtAdditionalNotes",
                reviewNotes);

            SetDynamicControlText(
                "ddlRejectionReason",
                rejectionReason);

            SetDynamicControlText(
                "txtRejectionReason",
                rejectionReason);

            SetDynamicControlText(
                "lblReviewedBy",
                reviewedBy);

            SetDynamicControlText(
                "lblReviewedAt",
                reviewedAt);

            SetDynamicControlText(
                "lblModalReviewNotes",
                reviewNotes);

            SetDynamicControlText(
                "lblModalRejectionReason",
                rejectionReason);

            // Store current status for approval/rejection logic.
            ViewState["CurrentApplicationStatus"] =
                status;
        }


        // ---------------------------------------------------------
        // GET DATABASE STRING
        // ---------------------------------------------------------

        private string GetReaderString(
            MySqlDataReader reader,
            string columnName)
        {
            try
            {
                int ordinal =
                    reader.GetOrdinal(
                        columnName);

                if (reader.IsDBNull(
                    ordinal))
                {
                    return string.Empty;
                }

                return
                    Convert.ToString(
                        reader.GetValue(
                            ordinal))
                    .Trim();
            }
            catch
            {
                return string.Empty;
            }
        }


        // ---------------------------------------------------------
        // GET DATABASE DATE
        // ---------------------------------------------------------

        private string GetReaderDate(
            MySqlDataReader reader,
            string columnName,
            string format)
        {
            try
            {
                int ordinal =
                    reader.GetOrdinal(
                        columnName);

                if (reader.IsDBNull(
                    ordinal))
                {
                    return string.Empty;
                }

                DateTime value;

                if (reader.GetValue(
                    ordinal) is DateTime)
                {
                    value =
                        (DateTime)
                            reader.GetValue(
                                ordinal);
                }
                else if (!DateTime.TryParse(
                    reader.GetValue(
                        ordinal).ToString(),
                    out value))
                {
                    return string.Empty;
                }

                return value.ToString(
                    format);
            }
            catch
            {
                return string.Empty;
            }
        }


        // ---------------------------------------------------------
        // GET DATABASE DATETIME
        // ---------------------------------------------------------

        private string GetReaderDateTime(
            MySqlDataReader reader,
            string columnName,
            string format)
        {
            return GetReaderDate(
                reader,
                columnName,
                format);
        }


        // ---------------------------------------------------------
        // HTML ENCODE
        // ---------------------------------------------------------

        private string EncodeOrDefault(
            string value)
        {
            if (string.IsNullOrWhiteSpace(
                value))
            {
                return "Not available";
            }

            return
                Server.HtmlEncode(
                    value.Trim());
        }


        // ---------------------------------------------------------
        // STATUS CSS
        // ---------------------------------------------------------

        protected string GetStatusCss(
            object status)
        {
            string value =
                Convert.ToString(
                    status)
                .Trim()
                .ToLowerInvariant();

            switch (value)
            {
                case "approved":

                    return "status-approved";

                case "rejected":

                    return "status-rejected";

                case "pending":
                case "pending approval":

                    return "status-pending";

                default:

                    return "status-pending";
            }
        }


        // ---------------------------------------------------------
        // BACKWARD COMPATIBILITY
        // ---------------------------------------------------------

        protected string GetStatusCssClass(
            object status)
        {
            return GetStatusCss(status);
        }


        // ---------------------------------------------------------
        // GRID ROW DATA BOUND
        // ---------------------------------------------------------

        protected void gvApplications_RowDataBound(
            object sender,
            GridViewRowEventArgs e)
        {
            if (e.Row.RowType !=
                DataControlRowType.DataRow)
            {
                return;
            }

            Label statusLabel =
                e.Row.FindControl(
                    "lblStatus") as Label;

            if (statusLabel == null)
                return;

            string status =
                statusLabel.Text?.Trim() ?? "";

            if (status.Equals(
                    "Pending",
                    StringComparison.OrdinalIgnoreCase) ||
                status.Equals(
                    "Pending Approval",
                    StringComparison.OrdinalIgnoreCase))
            {
                statusLabel.CssClass =
                    "status-badge status-pending";
            }
            else if (
                status.Equals(
                    "Approved",
                    StringComparison.OrdinalIgnoreCase))
            {
                statusLabel.CssClass =
                    "status-badge status-approved";
            }
            else if (
                status.Equals(
                    "Rejected",
                    StringComparison.OrdinalIgnoreCase))
            {
                statusLabel.CssClass =
                    "status-badge status-rejected";
            }
            else
            {
                statusLabel.CssClass =
                    "status-badge";
            }
        }


        // ---------------------------------------------------------
        // GHANA CARD VERIFICATION
        // ---------------------------------------------------------

        protected void btnVerifyIdentity_Click(
            object sender,
            EventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            string applicationId =
                Convert.ToString(
                    ViewState["CurrentApplicationId"])
                .Trim();

            if (string.IsNullOrWhiteSpace(
                applicationId))
            {
                ShowApplicationMessage(
                    "Please open an application before comparing local records.");

                return;
            }

            if (!Convert.ToString(ViewState["CurrentIdType"]).Equals(
                    "Ghana Card",
                    StringComparison.OrdinalIgnoreCase))
            {
                ShowApplicationMessage(
                    "Local record comparison is available only for Ghana Card applications.");
                OpenModal();
                return;
            }

            PerformIdentityVerification(
                applicationId);

            PrepareReviewControls();

            OpenModal();
        }


        // ---------------------------------------------------------
        // PERFORM CONTROLLED IDENTITY VERIFICATION
        // ---------------------------------------------------------

        private void PerformIdentityVerification(
            string applicationId)
        {
            try
            {
                string applicantName = "";
                string applicantCard = "";
                string applicantGender = "";
                DateTime applicantDob;
                bool applicantDobAvailable = false;

                string idType = "";

                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();

                    const string applicationSql = @"
                        SELECT
                            FullName,
                            Gender,
                            DateOfBirth,
                            NationalIDType,
                            GhanaCard

                        FROM applications

                        WHERE application_id =
                              @ApplicationId

                        LIMIT 1;";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               applicationSql,
                               connection))
                    {
                        command.Parameters.Add(
                            "@ApplicationId",
                            MySqlDbType.VarChar,
                            50).Value =
                            applicationId;

                        using (MySqlDataReader reader =
                               command.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowApplicationMessage(
                                    "The application could not be found.");

                                return;
                            }

                            applicantName =
                                GetReaderString(
                                    reader,
                                    "FullName");

                            applicantGender =
                                GetReaderString(
                                    reader,
                                    "Gender");

                            applicantCard =
                                GetReaderString(
                                    reader,
                                    "GhanaCard");

                            idType =
                                GetReaderString(
                                    reader,
                                    "NationalIDType");

                            applicantDob =
                                GetReaderDateValue(
                                    reader,
                                    "DateOfBirth",
                                    out applicantDobAvailable);
                        }
                    }
                }

                // -------------------------------------------------
                // ONLY GHANA CARD CAN USE THE GHANA CARD REGISTRY
                // -------------------------------------------------

                if (!idType.Equals(
                        "Ghana Card",
                        StringComparison.OrdinalIgnoreCase))
                {
                    ResetVerificationDisplay();

                    lblVerificationCardNumber.Text =
                        EncodeOrDefault(
                            applicantCard);

                    lblVerificationApplicantName.Text =
                        EncodeOrDefault(
                            applicantName);

                    lblVerificationApplicantGender.Text =
                        EncodeOrDefault(
                            applicantGender);

                    lblVerificationApplicantDob.Text =
                        applicantDobAvailable
                        ? applicantDob.ToString(
                            "dd MMM yyyy")
                        : "Not available";

                    lblVerificationOverall.Text =
                        "LOCAL COMPARISON NOT AVAILABLE";

                    lblVerificationMessage.Text =
                        "This local record comparison is available only for Ghana Card applications.";

                    lblVerificationSystemMessage.Text =
                        "No local Ghana Card comparison was performed because this application uses " +
                        EncodeOrDefault(idType) +
                        ".";

                    pnlVerificationResult.Visible = false;
                    lblVerificationSystemMessage.Visible = true;

                    return;
                }

                if (string.IsNullOrWhiteSpace(
                    applicantCard))
                {
                    ResetVerificationDisplay();

                    lblVerificationOverall.Text =
                        "LOCAL COMPARISON UNAVAILABLE";

                    lblVerificationMessage.Text =
                        "The application does not contain a Ghana Card number for comparison.";

                    lblVerificationSystemMessage.Text =
                        "Review the submitted identity document manually. This comparison is not official identity verification.";

                    pnlVerificationResult.Visible = false;
                    lblVerificationSystemMessage.Visible = true;

                    SaveFailedVerification(
                        applicationId,
                        applicantName,
                        applicantDob,
                        applicantDobAvailable,
                        applicantGender,
                        applicantCard);

                    return;
                }

                // -------------------------------------------------
                // SEARCH CONTROLLED REGISTRY
                //
                // IMPORTANT:
                // The ghana_card_registry table uses snake_case
                // column names, confirmed from DESCRIBE:
                //
                //   registry_id
                //   ghana_card_number
                //   full_name
                //   date_of_birth
                //   gender
                //   verification_status   (default 'ACTIVE')
                //   created_at
                //
                // There is NO "Status" column in this table -
                // it is "verification_status". This block was
                // previously written using the wrong PascalCase
                // names (GhanaCardNumber, FullName, DateOfBirth,
                // Gender, Status), which caused:
                //
                //   Unknown column 'GhanaCardNumber' in 'field list'
                //
                // The identity_verifications table (used later
                // in SaveIdentityVerification / LoadExistingVerification)
                // DOES use PascalCase and is untouched - that part
                // was already correct.
                // -------------------------------------------------

                string registryName = "";
                string registryGender = "";

                // FIXED: Initialise the variable so it is always assigned.
                DateTime registryDob = DateTime.MinValue;

                bool registryDobAvailable = false;

                bool cardMatch = false;
                bool nameMatch = false;
                bool dobMatch = false;
                bool genderMatch = false;

                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();

                    const string registrySql = @"
                        SELECT
                            ghana_card_number,
                            full_name,
                            date_of_birth,
                            gender,
                            verification_status

                        FROM ghana_card_registry

                        WHERE ghana_card_number =
                              @GhanaCardNumber

                        LIMIT 1;";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               registrySql,
                               connection))
                    {
                        command.Parameters.Add(
                            "@GhanaCardNumber",
                            MySqlDbType.VarChar,
                            50).Value =
                            applicantCard.Trim();

                        using (MySqlDataReader reader =
                               command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string registryCard =
                                    GetReaderString(
                                        reader,
                                        "ghana_card_number");

                                registryName =
                                    GetReaderString(
                                        reader,
                                        "full_name");

                                registryGender =
                                    GetReaderString(
                                        reader,
                                        "gender");

                                registryDob =
                                    GetReaderDateValue(
                                        reader,
                                        "date_of_birth",
                                        out registryDobAvailable);

                                string registryStatus =
                                    GetReaderString(
                                        reader,
                                        "verification_status");

                                cardMatch =
                                    !string.IsNullOrWhiteSpace(
                                        registryCard) &&
                                    registryCard.Equals(
                                        applicantCard,
                                        StringComparison.OrdinalIgnoreCase) &&
                                    registryStatus.Equals(
                                        "ACTIVE",
                                        StringComparison.OrdinalIgnoreCase);

                                nameMatch =
                                    NormalizeForComparison(
                                        applicantName) ==
                                    NormalizeForComparison(
                                        registryName);

                                dobMatch =
                                    applicantDobAvailable &&
                                    registryDobAvailable &&
                                    applicantDob.Date ==
                                    registryDob.Date;

                                genderMatch =
                                    NormalizeForComparison(
                                        applicantGender) ==
                                    NormalizeForComparison(
                                        registryGender);
                            }
                            else
                            {
                                registryName =
                                    "No registry record found";

                                registryGender =
                                    "No registry record found";

                                registryDobAvailable =
                                    false;
                            }
                        }
                    }
                }

                bool overallMatch =
                    cardMatch &&
                    nameMatch &&
                    dobMatch &&
                    genderMatch;


                // -------------------------------------------------
                // DISPLAY RESULTS
                // -------------------------------------------------

                lblVerificationCardNumber.Text =
                    EncodeOrDefault(
                        applicantCard);

                lblVerificationApplicantName.Text =
                    EncodeOrDefault(
                        applicantName);

                lblVerificationApplicantGender.Text =
                    EncodeOrDefault(
                        applicantGender);

                lblVerificationApplicantDob.Text =
                    applicantDobAvailable
                    ? applicantDob.ToString(
                        "dd MMM yyyy")
                    : "Not available";

                lblVerificationRegistryName.Text =
                    EncodeOrDefault(
                        registryName);

                lblVerificationRegistryGender.Text =
                    EncodeOrDefault(
                        registryGender);

                lblVerificationRegistryDob.Text =
                    registryDobAvailable
                    ? registryDob.ToString(
                        "dd MMM yyyy")
                    : "Not available";

                lblVerificationNameResult.Text =
                    nameMatch
                    ? "✓ Match"
                    : "✗ Mismatch";

                lblVerificationDobResult.Text =
                    dobMatch
                    ? "✓ Match"
                    : "✗ Mismatch";

                lblVerificationGenderResult.Text =
                    genderMatch
                    ? "✓ Match"
                    : "✗ Mismatch";


                if (overallMatch)
                {
                    lblVerificationOverall.Text =
                        "✓ LOCAL RECORD FIELDS MATCH";

                    lblVerificationMessage.Text =
                        "The entered Ghana Card number, name, date of birth and gender match a local project record. This is not official identity verification.";

                    lblVerificationSystemMessage.Text =
                        "Local record comparison only. The portal is not connected to NIA IVSP.";

                    if (verificationOverallValue != null)
                    {
                        verificationOverallValue.InnerText =
                            "LOCAL RECORD FIELDS MATCH";

                        verificationOverallValue.Attributes[
                            "class"] =
                            "verification-overall-value verification-success";
                    }
                }
                else
                {
                    lblVerificationOverall.Text =
                        "✗ LOCAL RECORD MISMATCH";

                    lblVerificationMessage.Text =
                        "One or more entered fields differ from the local project record. This result is not an official verification result.";

                    lblVerificationSystemMessage.Text =
                        "A local record mismatch is informational and does not replace manual document review.";

                    if (verificationOverallValue != null)
                    {
                        verificationOverallValue.InnerText =
                            "LOCAL RECORD MISMATCH";

                        verificationOverallValue.Attributes[
                            "class"] =
                            "verification-overall-value verification-failed";
                    }
                }

                lblVerificationTime.Text =
                    DateTime.Now.ToString(
                        "dd MMM yyyy HH:mm:ss");

                pnlVerificationResult.Visible = true;
                lblVerificationSystemMessage.Visible = true;

                // -------------------------------------------------
                // SAVE AUDIT RESULT
                // -------------------------------------------------

                SaveIdentityVerification(
                    applicationId,
                    applicantCard,
                    applicantName,
                    applicantDob,
                    applicantDobAvailable,
                    applicantGender,
                    registryName,
                    registryDob,
                    registryDobAvailable,
                    registryGender,
                    cardMatch,
                    nameMatch,
                    dobMatch,
                    genderMatch,
                    overallMatch);
            }
            catch (MySqlException ex)
            {
                ShowDatabaseError(
                    "The local record comparison could not be completed.",
                    ex);
            }
            catch (Exception ex)
            {
                ShowApplicationError(
                    "The local record comparison could not be completed.",
                    ex);
            }
        }


        // ---------------------------------------------------------
        // SAVE IDENTITY VERIFICATION
        // ---------------------------------------------------------

        private void SaveIdentityVerification(
            string applicationId,
            string applicantCard,
            string applicantName,
            DateTime applicantDob,
            bool applicantDobAvailable,
            string applicantGender,
            string registryName,
            DateTime registryDob,
            bool registryDobAvailable,
            string registryGender,
            bool cardMatch,
            bool nameMatch,
            bool dobMatch,
            bool genderMatch,
            bool overallMatch)
        {
            string officer =
                GetCurrentOfficerIdentity();

            using (MySqlConnection connection =
                   new MySqlConnection(connStr))
            {
                connection.Open();

                const string sql = @"
                    INSERT INTO identity_verifications
                    (
                        ApplicationReference,
                        GhanaCardNumber,
                        ApplicantName,
                        ApplicantDateOfBirth,
                        ApplicantGender,
                        RegistryName,
                        RegistryDateOfBirth,
                        RegistryGender,
                        GhanaCardMatch,
                        NameMatch,
                        DateOfBirthMatch,
                        GenderMatch,
                        OverallStatus,
                        VerifiedBy,
                        VerifiedAt
                    )
                    VALUES
                    (
                        @ApplicationReference,
                        @GhanaCardNumber,
                        @ApplicantName,
                        @ApplicantDateOfBirth,
                        @ApplicantGender,
                        @RegistryName,
                        @RegistryDateOfBirth,
                        @RegistryGender,
                        @GhanaCardMatch,
                        @NameMatch,
                        @DateOfBirthMatch,
                        @GenderMatch,
                        @OverallStatus,
                        @VerifiedBy,
                        NOW()
                    );";

                using (MySqlCommand command =
                       new MySqlCommand(
                           sql,
                           connection))
                {
                    command.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50).Value =
                        applicationId;

                    command.Parameters.Add(
                        "@GhanaCardNumber",
                        MySqlDbType.VarChar,
                        50).Value =
                        GetDatabaseValue(
                            applicantCard);

                    command.Parameters.Add(
                        "@ApplicantName",
                        MySqlDbType.VarChar,
                        150).Value =
                        GetDatabaseValue(
                            applicantName);

                    command.Parameters.Add(
                        "@ApplicantDateOfBirth",
                        MySqlDbType.Date).Value =
                        applicantDobAvailable
                        ? (object)applicantDob.Date
                        : DBNull.Value;

                    command.Parameters.Add(
                        "@ApplicantGender",
                        MySqlDbType.VarChar,
                        20).Value =
                        GetDatabaseValue(
                            applicantGender);

                    command.Parameters.Add(
                        "@RegistryName",
                        MySqlDbType.VarChar,
                        150).Value =
                        GetDatabaseValue(
                            registryName);

                    command.Parameters.Add(
                        "@RegistryDateOfBirth",
                        MySqlDbType.Date).Value =
                        registryDobAvailable
                        ? (object)registryDob.Date
                        : DBNull.Value;

                    command.Parameters.Add(
                        "@RegistryGender",
                        MySqlDbType.VarChar,
                        20).Value =
                        GetDatabaseValue(
                            registryGender);

                    command.Parameters.Add(
                        "@GhanaCardMatch",
                        MySqlDbType.Bit).Value =
                        cardMatch;

                    command.Parameters.Add(
                        "@NameMatch",
                        MySqlDbType.Bit).Value =
                        nameMatch;

                    command.Parameters.Add(
                        "@DateOfBirthMatch",
                        MySqlDbType.Bit).Value =
                        dobMatch;

                    command.Parameters.Add(
                        "@GenderMatch",
                        MySqlDbType.Bit).Value =
                        genderMatch;

                    command.Parameters.Add(
                        "@OverallStatus",
                        MySqlDbType.VarChar,
                        30).Value =
                        overallMatch
                        ? "LocalRecordMatch"
                        : "LocalRecordMismatch";

                    command.Parameters.Add(
                        "@VerifiedBy",
                        MySqlDbType.VarChar,
                        150).Value =
                        officer;

                    command.ExecuteNonQuery();
                }
            }
            LoadRecordedReviewSummary(applicationId);
        }


        // ---------------------------------------------------------
        // SAVE FAILED VERIFICATION
        // ---------------------------------------------------------

        private void SaveFailedVerification(
            string applicationId,
            string applicantName,
            DateTime applicantDob,
            bool applicantDobAvailable,
            string applicantGender,
            string applicantCard)
        {
            SaveIdentityVerification(
                applicationId,
                applicantCard,
                applicantName,
                applicantDob,
                applicantDobAvailable,
                applicantGender,
                "",
                DateTime.MinValue,
                false,
                "",
                false,
                false,
                false,
                false,
                false);
        }


        // ---------------------------------------------------------
        // LOAD EXISTING VERIFICATION
        // ---------------------------------------------------------

        private void LoadExistingVerification(
            string applicationId)
        {
            try
            {
                ResetVerificationDisplay();

                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();

                    const string sql = @"
                        SELECT
                            GhanaCardNumber,
                            ApplicantName,
                            ApplicantDateOfBirth,
                            ApplicantGender,
                            RegistryName,
                            RegistryDateOfBirth,
                            RegistryGender,
                            GhanaCardMatch,
                            NameMatch,
                            DateOfBirthMatch,
                            GenderMatch,
                            OverallStatus,
                            VerifiedBy,
                            VerifiedAt

                        FROM identity_verifications

                        WHERE ApplicationReference =
                              @ApplicationReference

                        ORDER BY VerificationID DESC

                        LIMIT 1;";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               sql,
                               connection))
                    {
                        command.Parameters.Add(
                            "@ApplicationReference",
                            MySqlDbType.VarChar,
                            50).Value =
                            applicationId;

                        using (MySqlDataReader reader =
                               command.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                return;
                            }

                            string card =
                                GetReaderString(
                                    reader,
                                    "GhanaCardNumber");

                            string applicantName =
                                GetReaderString(
                                    reader,
                                    "ApplicantName");

                            string applicantGender =
                                GetReaderString(
                                    reader,
                                    "ApplicantGender");

                            string applicantDob =
                                GetReaderDate(
                                    reader,
                                    "ApplicantDateOfBirth",
                                    "dd MMM yyyy");

                            string registryName =
                                GetReaderString(
                                    reader,
                                    "RegistryName");

                            string registryGender =
                                GetReaderString(
                                    reader,
                                    "RegistryGender");

                            string registryDob =
                                GetReaderDate(
                                    reader,
                                    "RegistryDateOfBirth",
                                    "dd MMM yyyy");

                            bool cardMatch =
                                GetReaderBoolean(
                                    reader,
                                    "GhanaCardMatch");

                            bool nameMatch =
                                GetReaderBoolean(
                                    reader,
                                    "NameMatch");

                            bool dobMatch =
                                GetReaderBoolean(
                                    reader,
                                    "DateOfBirthMatch");

                            bool genderMatch =
                                GetReaderBoolean(
                                    reader,
                                    "GenderMatch");

                            string overall =
                                GetReaderString(
                                    reader,
                                    "OverallStatus");

                            string verifiedBy =
                                GetReaderString(
                                    reader,
                                    "VerifiedBy");

                            string verifiedAt =
                                GetReaderDate(
                                    reader,
                                    "VerifiedAt",
                                    "dd MMM yyyy HH:mm:ss");


                            lblVerificationCardNumber.Text =
                                EncodeOrDefault(
                                    card);

                            lblVerificationApplicantName.Text =
                                EncodeOrDefault(
                                    applicantName);

                            lblVerificationApplicantDob.Text =
                                EncodeOrDefault(
                                    applicantDob);

                            lblVerificationApplicantGender.Text =
                                EncodeOrDefault(
                                    applicantGender);

                            lblVerificationRegistryName.Text =
                                EncodeOrDefault(
                                    registryName);

                            lblVerificationRegistryDob.Text =
                                EncodeOrDefault(
                                    registryDob);

                            lblVerificationRegistryGender.Text =
                                EncodeOrDefault(
                                    registryGender);

                            lblVerificationNameResult.Text =
                                nameMatch
                                ? "✓ Match"
                                : "✗ Mismatch";

                            lblVerificationDobResult.Text =
                                dobMatch
                                ? "✓ Match"
                                : "✗ Mismatch";

                            lblVerificationGenderResult.Text =
                                genderMatch
                                ? "✓ Match"
                                : "✗ Mismatch";

                            if (overall.Equals(
                                    "Verified",
                                    StringComparison.OrdinalIgnoreCase) ||
                                overall.Equals(
                                    "LocalRecordMatch",
                                    StringComparison.OrdinalIgnoreCase))
                            {
                                lblVerificationOverall.Text =
                                    "✓ LOCAL RECORD FIELDS MATCH";

                                if (verificationOverallValue != null)
                                {
                                    verificationOverallValue.InnerText =
                                        "LOCAL RECORD FIELDS MATCH";

                                    verificationOverallValue.Attributes[
                                        "class"] =
                                        "verification-overall-value verification-success";
                                }
                            }
                            else
                            {
                                lblVerificationOverall.Text =
                                    "✗ LOCAL RECORD MISMATCH";

                                if (verificationOverallValue != null)
                                {
                                    verificationOverallValue.InnerText =
                                        "LOCAL RECORD MISMATCH";

                                    verificationOverallValue.Attributes[
                                        "class"] =
                                        "verification-overall-value verification-failed";
                                }
                            }

                            lblVerificationMessage.Text =
                                "Previous local record comparison loaded; it is not official identity verification.";

                            lblVerificationSystemMessage.Text =
                                "Compared by: " +
                                EncodeOrDefault(
                                    verifiedBy);

                            lblVerificationTime.Text =
                                EncodeOrDefault(
                                    verifiedAt);

                            pnlVerificationResult.Visible = true;
                            lblVerificationSystemMessage.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                // Do not prevent the application modal from opening
                // if a previous verification record cannot be loaded.
            }
        }


        // ---------------------------------------------------------
        // RESET VERIFICATION DISPLAY
        // ---------------------------------------------------------

        private void ResetVerificationDisplay()
        {
            lblVerificationRegistryName.Text =
                "Not verified";

            lblVerificationRegistryDob.Text =
                "Not verified";

            lblVerificationRegistryGender.Text =
                "Not verified";

            lblVerificationNameResult.Text =
                "Not verified";

            lblVerificationDobResult.Text =
                "Not verified";

            lblVerificationGenderResult.Text =
                "Not verified";

            lblVerificationOverall.Text =
                "Not verified";

            lblVerificationMessage.Text =
                string.Empty;

            lblVerificationTime.Text =
                string.Empty;

            lblVerificationSystemMessage.Text =
                string.Empty;

            pnlVerificationResult.Visible = false;
            lblVerificationSystemMessage.Visible = false;

            if (verificationOverallValue != null)
            {
                verificationOverallValue.InnerText =
                    "NOT VERIFIED";

                verificationOverallValue.Attributes[
                    "class"] =
                    "verification-overall-value";
            }
        }


        private int GetCurrentOfficerUserId()
        {
            int userId;
            if (!int.TryParse(
                    Convert.ToString(Session["UserID"]),
                    out userId) ||
                userId <= 0)
                throw new InvalidOperationException(
                    "The authenticated officer account reference is missing.");

            return userId;
        }

        private bool LockPendingApplication(
            MySqlConnection connection,
            MySqlTransaction transaction,
            string applicationId)
        {
            // Same actor-before-application lock order as the local workspace.
            // Recheck the current role inside the mutation transaction, not just Page_Load.
            using (MySqlCommand actor = new MySqlCommand(
                "SELECT Role, IsActive, FirstName, LastName, Email FROM users WHERE UserID=@Actor FOR UPDATE;",
                connection, transaction))
            {
                actor.Parameters.AddWithValue("@Actor", GetCurrentOfficerUserId());
                using (MySqlDataReader reader = actor.ExecuteReader())
                {
                    if (!reader.Read() || !Convert.ToBoolean(reader["IsActive"])) return false;
                    string role = StaffAccess.NormalizeRole(Convert.ToString(reader["Role"]));
                    if (role != "policeofficer" && role != "officer" && role != "police" && role != "vetting")
                        return false;
                    authenticatedOfficerName = (Convert.ToString(reader["FirstName"]) + " " +
                        Convert.ToString(reader["LastName"])).Trim();
                    if (authenticatedOfficerName.Length == 0)
                        authenticatedOfficerName = Convert.ToString(reader["Email"]).Trim();
                    if (authenticatedOfficerName.Length == 0)
                        authenticatedOfficerName = "Account #" + authenticatedOfficerUserId;
                }
            }
            using (MySqlCommand command = new MySqlCommand(
                "SELECT Status FROM applications WHERE application_id=@Id LIMIT 1 FOR UPDATE;",
                connection, transaction))
            {
                command.Parameters.Add("@Id", MySqlDbType.VarChar, 50).Value = applicationId;
                string status = Convert.ToString(command.ExecuteScalar()).Trim();
                return status.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
                    status.Equals("Pending Approval", StringComparison.OrdinalIgnoreCase);
            }
        }

        private void InsertAuditLog(
            MySqlConnection connection,
            MySqlTransaction transaction,
            string actionType,
            string details)
        {
            const string sql = @"
                INSERT INTO account_audit_logs
                    (ActorUserID, TargetUserID, ActionType, Details)
                VALUES
                    (@ActorUserID, NULL, @ActionType, @Details);";

            using (MySqlCommand command =
                   new MySqlCommand(sql, connection, transaction))
            {
                command.Parameters.Add(
                    "@ActorUserID",
                    MySqlDbType.Int32).Value =
                    GetCurrentOfficerUserId();
                command.Parameters.Add(
                    "@ActionType",
                    MySqlDbType.VarChar,
                    60).Value = actionType;
                command.Parameters.Add(
                    "@Details",
                    MySqlDbType.Text).Value = details;
                command.ExecuteNonQuery();
            }
        }

        // ---------------------------------------------------------
        // PREPARE REVIEW CONTROLS
        // ---------------------------------------------------------

        private void LoadIdentityDocumentPanel(
            string applicationId,
            bool preserveSelection)
        {
            string selectedDocument =
                preserveSelection
                    ? ddlDocumentReviewType.SelectedValue
                    : string.Empty;

            ddlDocumentReviewType.Items.Clear();
            ddlDocumentReviewType.Items.Add(
                new ListItem("Select a submitted document", ""));

            string idType =
                Convert.ToString(ViewState["CurrentIdType"]).Trim();

            lnkPassportPhoto.Visible = false;
            lnkGhanaCardFront.Visible = false;
            lnkGhanaCardBack.Visible = false;
            lnkIdentityDocument.Visible = false;
            lnkIdentityDocumentBack.Visible = false;

            AddReviewDocument(
                applicationId,
                "PASSPORT_PHOTO",
                "Passport photograph",
                lnkPassportPhoto,
                "Open passport photograph");

            if (idType.Equals(
                    "Ghana Card",
                    StringComparison.OrdinalIgnoreCase))
            {
                AddReviewDocument(
                    applicationId,
                    "GHANA_CARD_FRONT",
                    "Ghana Card — front",
                    lnkGhanaCardFront,
                    "View Ghana Card front");
                AddReviewDocument(
                    applicationId,
                    "GHANA_CARD_BACK",
                    "Ghana Card — back",
                    lnkGhanaCardBack,
                    "View Ghana Card back");
            }
            else if (idType.Equals(
                         "Passport",
                         StringComparison.OrdinalIgnoreCase))
            {
                AddReviewDocument(
                    applicationId,
                    "PASSPORT_BIO_PAGE",
                    "Passport bio-data page",
                    lnkIdentityDocument,
                    "View passport bio-data page");
            }
            else if (idType.Equals(
                         "Voter ID",
                         StringComparison.OrdinalIgnoreCase))
            {
                AddReviewDocument(
                    applicationId,
                    "VOTER_ID_FRONT",
                    "Voter ID — front",
                    lnkIdentityDocument,
                    "View Voter ID front");
                AddReviewDocument(applicationId, "VOTER_ID_BACK", "Voter ID — back",
                    lnkIdentityDocumentBack, "View Voter ID back");
            }
            else if (idType.Equals("Driver's Licence", StringComparison.OrdinalIgnoreCase))
            {
                AddReviewDocument(applicationId, "DRIVERS_LICENCE_FRONT", "Driver's Licence — front",
                    lnkIdentityDocument, "View Driver's Licence front");
                AddReviewDocument(applicationId, "DRIVERS_LICENCE_BACK", "Driver's Licence — back",
                    lnkIdentityDocumentBack, "View Driver's Licence back");
            }

            if (!string.IsNullOrWhiteSpace(selectedDocument) &&
                ddlDocumentReviewType.Items.FindByValue(selectedDocument) != null)
            {
                ddlDocumentReviewType.SelectedValue = selectedDocument;
            }

            LoadIdentityReviewHistory(applicationId);
        }

        private void AddReviewDocument(
            string applicationId,
            string documentType,
            string displayName,
            HyperLink link,
            string linkText)
        {
            if (!StoredApplicationDocumentExists(
                    applicationId,
                    documentType))
                return;

            ddlDocumentReviewType.Items.Add(
                new ListItem(displayName, documentType));
            SetDocumentLink(
                applicationId,
                documentType,
                linkText,
                link);
        }

        private void SetDocumentLink(
            string applicationId,
            string documentType,
            string linkText,
            HyperLink link)
        {
            if (!StoredApplicationDocumentExists(
                    applicationId,
                    documentType))
                return;

            link.Text = linkText;
            link.NavigateUrl =
                ResolveUrl("~/ApplicationDocument.ashx") +
                "?id=" + HttpUtility.UrlEncode(applicationId) +
                "&type=" + HttpUtility.UrlEncode(documentType);
            link.Attributes["rel"] = "noopener noreferrer";
            link.Visible = true;
        }

        private bool StoredApplicationDocumentExists(
            string applicationId,
            string documentType)
        {
            string prefix = GetDocumentPrefix(documentType);
            if (string.IsNullOrWhiteSpace(prefix) ||
                !IsSafeApplicationReference(applicationId))
                return false;

            try
            {
                string folder = Path.Combine(
                    Server.MapPath("~/App_Data/Applications/"),
                    applicationId);
                return FindDocumentFile(folder, prefix) != null;
            }
            catch
            {
                return false;
            }
        }

        private string FindApplicationDocumentPath(
            string applicationId,
            string documentType)
        {
            string prefix = GetDocumentPrefix(documentType);
            if (string.IsNullOrWhiteSpace(prefix) ||
                !IsSafeApplicationReference(applicationId))
                return null;

            string folder = Path.Combine(
                Server.MapPath("~/App_Data/Applications/"),
                applicationId);
            return FindDocumentFile(folder, prefix);
        }

        private static string FindDocumentFile(
            string folder,
            string prefix)
        {
            if (!Directory.Exists(folder))
                return null;

            string[] files = Directory.GetFiles(
                folder,
                prefix + ".*",
                SearchOption.TopDirectoryOnly);

            foreach (string file in files)
            {
                string extension = Path.GetExtension(file).ToLowerInvariant();
                if (extension == ".jpg" ||
                    extension == ".jpeg" ||
                    extension == ".png" ||
                    extension == ".pdf")
                    return file;
            }

            return null;
        }

        private static string GetDocumentPrefix(string documentType)
        {
            return PoliceBackgroundCheckSystem.Helpers.ApplicationDocumentCatalog.Prefix(Convert.ToString(documentType).ToUpperInvariant());
        }

        private static bool IsSafeApplicationReference(string applicationId)
        {
            if (string.IsNullOrWhiteSpace(applicationId) ||
                applicationId.Length > 50)
                return false;

            foreach (char character in applicationId)
            {
                if (!char.IsLetterOrDigit(character) &&
                    character != '-' &&
                    character != '_')
                    return false;
            }

            return true;
        }

        private void LoadIdentityReviewHistory(string applicationId)
        {
            DataTable table = new DataTable();
            table.Columns.Add("DocumentType", typeof(string));
            table.Columns.Add("Decision", typeof(string));
            table.Columns.Add("ReviewReason", typeof(string));
            table.Columns.Add("ReviewerUserID", typeof(int));
            table.Columns.Add("ReviewerName", typeof(string));
            table.Columns.Add("ReviewedAt", typeof(DateTime));
            table.Columns.Add("StorageSource", typeof(string));
            table.Columns.Add("DocumentTypeDisplay", typeof(string));
            table.Columns.Add("DecisionDisplay", typeof(string));
            table.Columns.Add("ReviewedAtDisplay", typeof(string));
            try
            {
                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();
                    foreach (var review in IndividualDocumentReviewStore.Load(connection, null, applicationId))
                    {
                        if (review.WholeSet) continue;
                        table.Rows.Add(review.DocumentType, review.Decision, review.ReviewReason,
                            review.ReviewerUserID, review.ReviewerName, review.ReviewedAt,
                            review.Legacy ? "Legacy history" : "Existing verification log",
                            GetDocumentTypeDisplay(review.DocumentType),
                            GetDocumentDecisionDisplay(review.Decision),
                            review.ReviewedAt.ToString("dd MMM yyyy HH:mm:ss"));
                    }
                }
                gvIdentityReviewHistory.EmptyDataText = "No document review decisions have been recorded.";
                lblDocumentReviewMessage.Text = string.Empty;
            }
            catch (Exception ex)
            {
                table.Rows.Clear();
                System.Diagnostics.Trace.TraceError(
                    "Identity document history could not be loaded ({0}).",
                    ex.GetType().Name);
                lblDocumentReviewMessage.Text =
                    "Document review history is unavailable. Approval remains blocked if review storage cannot be read.";
                gvIdentityReviewHistory.EmptyDataText = "Document review history unavailable.";
            }

            gvIdentityReviewHistory.DataSource = table;
            gvIdentityReviewHistory.DataBind();
            LoadRecordedReviewSummary(applicationId);
        }

        private void LoadRecordedReviewSummary(string applicationId)
        {
            // Read persisted actors/times, never the current visitor or a display-time timestamp.
            const string sql = @"
                SELECT Reviewer, ReviewTime, Notes, ReviewSource, ReviewPriority, RecordOrder FROM (
                    SELECT ReviewedBy AS Reviewer, ReviewedAt AS ReviewTime,
                           ReviewNotes AS Notes, 'Application decision' AS ReviewSource,
                           3 AS ReviewPriority, 0 AS RecordOrder
                    FROM applications WHERE application_id=@Id
                    UNION ALL
                    SELECT VerifiedBy, VerifiedAt,
                           'Informational local comparison; not official NIA verification.',
                           'Local record comparison', 1, VerificationID
                    FROM identity_verifications WHERE ApplicationReference=@Id
                ) recorded WHERE ReviewTime IS NOT NULL
                ORDER BY ReviewTime DESC, ReviewPriority DESC, RecordOrder DESC LIMIT 1;";
            try
            {
                using (MySqlConnection connection = new MySqlConnection(connStr))
                using (MySqlCommand command = new MySqlCommand(sql, connection))
                {
                    command.Parameters.Add("@Id", MySqlDbType.VarChar, 50).Value = applicationId;
                    connection.Open();
                    DataTable summary = new DataTable();
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                        adapter.Fill(summary);
                    foreach (var review in IndividualDocumentReviewStore.Load(connection, null, applicationId))
                    {
                        summary.Rows.Add(review.ReviewerName, review.ReviewedAt,
                            GetDocumentDecisionDisplay(review.Decision) + ". " + review.ReviewReason,
                            review.WholeSet ? "Local whole-set document review" :
                                "Document review: " + review.DocumentType,
                            2, review.Order);
                    }
                    if (summary.Rows.Count == 0)
                    {
                        lblReviewedBy.Text = "Not reviewed yet";
                        lblReviewedAt.Text = "No recorded review date";
                        lblModalReviewNotes.Text = "No review has been recorded.";
                        return;
                    }
                    DataRow reader = summary.Select("", "ReviewTime DESC, ReviewPriority DESC, RecordOrder DESC")[0];
                        string reviewer = Convert.ToString(reader["Reviewer"]).Trim();
                        lblReviewedBy.Text = Server.HtmlEncode(
                            reviewer.Length == 0 ? "Reviewer not recorded" : reviewer);
                        lblReviewedAt.Text = Convert.ToDateTime(reader["ReviewTime"])
                            .ToString("dd MMM yyyy HH:mm:ss");
                        string source = Convert.ToString(reader["ReviewSource"]);
                        const string documentPrefix = "Document review: ";
                        if (source.StartsWith(documentPrefix, StringComparison.Ordinal))
                            source = "Document review — " +
                                GetDocumentTypeDisplay(source.Substring(documentPrefix.Length));
                        lblModalReviewNotes.Text = Server.HtmlEncode(
                            source + ": " +
                            Convert.ToString(reader["Notes"]));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Recorded review summary could not load ({0}).", ex.GetType().Name);
                lblReviewedBy.Text = "Review history unavailable";
                lblReviewedAt.Text = "Review history unavailable";
                lblModalReviewNotes.Text = "The recorded review could not be read. Contact the database administrator.";
            }
        }

        private static string GetDocumentTypeDisplay(object value)
        {
            return PoliceBackgroundCheckSystem.Helpers.ApplicationDocumentCatalog.Label(Convert.ToString(value).ToUpperInvariant());
        }

        private static string GetDocumentDecisionDisplay(object value)
        {
            switch (Convert.ToString(value).ToUpperInvariant())
            {
                case "ACCEPTED":
                    return "Accepted";
                case "REJECTED":
                    return "Rejected";
                case "FURTHER_REVIEW":
                    return "Flagged — further review";
                default:
                    return "Unknown";
            }
        }

        private string[] GetRequiredDocumentTypes(string idType)
        {
            return PoliceBackgroundCheckSystem.Helpers.ApplicationDocumentCatalog.RequiredTypes(idType);
        }

        protected void btnSaveDocumentReview_Click(
            object sender,
            EventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;
            if (!String.Equals(Request.HttpMethod, "POST", StringComparison.Ordinal))
                return;

            string applicationId =
                Convert.ToString(
                    ViewState["CurrentApplicationId"]).Trim();
            string documentType =
                ddlDocumentReviewType.SelectedValue;
            string decision =
                ddlDocumentReviewDecision.SelectedValue;
            string reason =
                txtDocumentReviewReason.Text.Trim();

            if (string.IsNullOrWhiteSpace(applicationId))
            {
                lblDocumentReviewMessage.Text =
                    "Open an application before recording a document decision.";
                OpenModal();
                return;
            }

            if (decision != "ACCEPTED" &&
                decision != "REJECTED" &&
                decision != "FURTHER_REVIEW")
            {
                lblDocumentReviewMessage.Text =
                    "Select a valid document review decision.";
                OpenModal();
                return;
            }

            if (reason.Length < 5 || reason.Length > 1000)
            {
                lblDocumentReviewMessage.Text =
                    "Enter a review reason between 5 and 1,000 characters.";
                OpenModal();
                return;
            }

            int reviewerUserId;
            if (!int.TryParse(
                    Convert.ToString(Session["UserID"]),
                    out reviewerUserId) ||
                reviewerUserId <= 0)
            {
                lblDocumentReviewMessage.Text =
                    "Your officer session is missing its account reference. Sign in again.";
                OpenModal();
                return;
            }

            MySqlTransaction transaction = null;
            try
            {
                string status = GetApplicationStatus(applicationId);
                if (!status.Equals("Pending", StringComparison.OrdinalIgnoreCase) &&
                    !status.Equals("Pending Approval", StringComparison.OrdinalIgnoreCase))
                {
                    lblDocumentReviewMessage.Text =
                        "Document decisions can only be recorded for pending applications.";
                    OpenModal();
                    return;
                }

                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();
                    transaction = connection.BeginTransaction();
                    if (!LockPendingApplication(connection, transaction, applicationId))
                        throw new InvalidOperationException(
                            "The application is no longer pending review.");

                    string idType;
                    string workflowStatus;
                    int storedApplicationId;
                    using (MySqlCommand command = new MySqlCommand(
                        "SELECT ApplicationID, NationalIDType, Status FROM applications WHERE application_id=@Id LIMIT 1;",
                        connection,
                        transaction))
                    {
                        command.Parameters.Add(
                            "@Id",
                            MySqlDbType.VarChar,
                            50).Value = applicationId;
                        using (MySqlDataReader reader = command.ExecuteReader())
                        {
                            if (!reader.Read()) throw new InvalidOperationException("Application unavailable.");
                            storedApplicationId = Convert.ToInt32(reader["ApplicationID"]);
                            idType = Convert.ToString(reader["NationalIDType"]).Trim();
                            workflowStatus = Convert.ToString(reader["Status"]);
                        }
                    }

                    string[] requiredTypes =
                        GetRequiredDocumentTypes(idType);
                    if (Array.IndexOf(requiredTypes, documentType) < 0 ||
                        FindApplicationDocumentPath(
                            applicationId,
                            documentType) == null)
                    {
                        transaction.Rollback();
                        lblDocumentReviewMessage.Text =
                            "The selected required identity document is not available for review.";
                        OpenModal();
                        return;
                    }

                    string officer = GetCurrentOfficerIdentity();
                    string note = IndividualDocumentReviewStore.Encode(documentType, decision, reason, reviewerUserId);
                    const string reviewSql = @"
                        INSERT INTO verification_log
                            (ApplicationID, OfficerName, VerificationDate, IsVerified, Notes)
                        VALUES (@ApplicationID, @Reviewer, NOW(), @Verified, @Notes);";

                    using (MySqlCommand command = new MySqlCommand(
                        reviewSql,
                        connection,
                        transaction))
                    {
                        command.Parameters.AddWithValue("@ApplicationID", storedApplicationId);
                        command.Parameters.AddWithValue("@Reviewer", officer.Length > 100 ? officer.Substring(0, 100) : officer);
                        command.Parameters.AddWithValue("@Verified", decision == "ACCEPTED" ? 1 : 0);
                        command.Parameters.Add("@Notes", MySqlDbType.Text).Value = note;
                        command.ExecuteNonQuery();
                    }

                    const string auditSql = @"
                        INSERT INTO account_audit_logs
                            (ActorUserID, TargetUserID, ActionType, Details, CreatedAt)
                        VALUES
                            (@ActorUserID, NULL, 'IDENTITY_DOCUMENT_REVIEWED', @Details, NOW());";

                    using (MySqlCommand command = new MySqlCommand(
                        auditSql,
                        connection,
                        transaction))
                    {
                        command.Parameters.Add(
                            "@ActorUserID",
                            MySqlDbType.Int32).Value = reviewerUserId;
                        command.Parameters.Add(
                            "@Details",
                            MySqlDbType.Text).Value =
                            "Application " + applicationId +
                            "; reviewer " + officer + "; " + note;
                        command.ExecuteNonQuery();
                    }

                    AdminWorkflowService.AppendWorkflow(connection, transaction, storedApplicationId,
                        reviewerUserId, "Document" + decision, workflowStatus, workflowStatus, note);
                    transaction.Commit();
                    transaction = null;
                }

                ddlDocumentReviewDecision.SelectedIndex = 0;
                txtDocumentReviewReason.Text = string.Empty;
                LoadIdentityDocumentPanel(applicationId, false);
                PrepareReviewControls();
                lblDocumentReviewMessage.Text =
                    "The decision was recorded in the review history.";
                OpenModal();
            }
            catch (MySqlException ex)
            {
                if (transaction != null)
                {
                    try { transaction.Rollback(); }
                    catch { }
                }

                System.Diagnostics.Trace.TraceError(
                    "Document review could not be saved (MySQL error {0}).",
                    ex.Number);
                lblDocumentReviewMessage.Text =
                    "The document decision was not saved. Ask the database administrator to check the existing review tables.";
                OpenModal();
            }
            catch (Exception ex)
            {
                if (transaction != null)
                {
                    try { transaction.Rollback(); }
                    catch { }
                }

                System.Diagnostics.Trace.TraceError(
                    "Document review could not be saved ({0}).",
                    ex.GetType().Name);
                lblDocumentReviewMessage.Text =
                    "The document decision could not be saved. Please try again.";
                OpenModal();
            }
        }

        private bool AreRequiredIdentityDocumentsAccepted(
            string applicationId)
        {
            using (MySqlConnection connection =
                   new MySqlConnection(connStr))
            {
                connection.Open();
                return AreRequiredIdentityDocumentsAccepted(connection, null, applicationId);
            }
        }

        private bool AreRequiredIdentityDocumentsAccepted(
            MySqlConnection connection, MySqlTransaction transaction, string applicationId)
        {
            string idType;
            using (MySqlCommand command = new MySqlCommand(
                "SELECT NationalIDType FROM applications WHERE application_id=@Id LIMIT 1;",
                connection, transaction))
            {
                command.Parameters.Add("@Id", MySqlDbType.VarChar, 50).Value = applicationId;
                idType = Convert.ToString(command.ExecuteScalar()).Trim();
            }
            return IndividualDocumentReviewStore.CanApprove(GetRequiredDocumentTypes(idType),
                type => StoredApplicationDocumentExists(applicationId, type),
                IndividualDocumentReviewStore.Load(connection, transaction, applicationId));
        }

        private void PrepareReviewControls()
        {
            string status =
                Convert.ToString(
                    ViewState["CurrentApplicationStatus"])
                .Trim();

            bool pending =
                status.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("Pending Approval", StringComparison.OrdinalIgnoreCase);

            string applicationId =
                Convert.ToString(
                    ViewState["CurrentApplicationId"])
                .Trim();

            bool documentsAccepted = false;

            if (pending && !string.IsNullOrWhiteSpace(applicationId))
            {
                try
                {
                    documentsAccepted =
                        AreRequiredIdentityDocumentsAccepted(applicationId);
                }
                catch
                {
                    documentsAccepted = false;
                }
            }

            lblDocumentApprovalStatus.Text =
                !pending
                    ? string.Empty
                    : documentsAccepted
                        ? "Every required document has a latest accepted officer review. This is not official NIA IVSP verification."
                        : "Approval is blocked until every required document is present and its latest officer review is accepted.";

            SetDynamicControlVisible(
                "pnlApproval",
                pending && documentsAccepted);

            // Rejection remains available for every pending application.
            SetDynamicControlVisible("pnlRejection", pending);

            // Also protect the actual action buttons when they exist in the ASPX.
            SetDynamicControlVisible(
                "btnApproveApplication",
                pending && documentsAccepted);
            SetDynamicControlVisible("btnRejectApplication", pending);
        }


        // ---------------------------------------------------------
        // APPROVE APPLICATION
        // ---------------------------------------------------------

        protected void btnApproveApplication_Click(
            object sender,
            EventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            string applicationId =
                Convert.ToString(
                    ViewState["CurrentApplicationId"])
                .Trim();

            if (string.IsNullOrWhiteSpace(
                applicationId))
            {
                ShowApplicationMessage(
                    "Please open an application before approving it.");

                return;
            }

            string reviewNotes =
                GetDynamicControlText(
                    "txtReviewNotes");

            if (string.IsNullOrWhiteSpace(
                reviewNotes))
            {
                reviewNotes =
                    GetDynamicControlText(
                        "txtAdditionalNotes");
            }

            try
            {
                // -------------------------------------------------
                // CHECK CURRENT STATUS
                // -------------------------------------------------

                string currentStatus =
                    GetApplicationStatus(
                        applicationId);

                if (!currentStatus.Equals(
                        "Pending",
                        StringComparison.OrdinalIgnoreCase) &&
                    !currentStatus.Equals(
                        "Pending Approval",
                        StringComparison.OrdinalIgnoreCase))
                {
                    ShowApplicationMessage(
                        "Only pending applications can be approved.");

                    return;
                }

                // -------------------------------------------------
                // CHECK THE LATEST MANUAL REVIEW OF EACH REQUIRED DOCUMENT
                // -------------------------------------------------

                bool documentsAccepted =
                    AreRequiredIdentityDocumentsAccepted(
                        applicationId);

                if (!documentsAccepted)
                {
                    ShowApplicationMessage(
                        "Approval requires every mandatory document and accepted individual reviews or a local whole-set Verified review. A latest whole-set Flag/Reject or a newer individual Flag/Reject blocks approval.");

                    OpenModal();

                    return;
                }

                string officer =
                    GetCurrentOfficerIdentity();

                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();
                    using (MySqlTransaction transaction =
                           connection.BeginTransaction())
                    {
                    if (!LockPendingApplication(connection, transaction, applicationId) ||
                        !AreRequiredIdentityDocumentsAccepted(connection, transaction, applicationId))
                        throw new InvalidOperationException(
                            "The application is no longer pending or the required document reviews are incomplete.");
                    DataRow workflowApp = AdminWorkflowService.LockApplication(connection, transaction, applicationId);

                    const string sql = @"
                        UPDATE applications

                        SET
                            Status = 'Approved',
                            ReviewedBy = @ReviewedBy,
                            ReviewedAt = NOW(),
                            ReviewNotes = @ReviewNotes,
                            RejectionReason = NULL

                        WHERE application_id =
                              @ApplicationId

                        AND LOWER(TRIM(COALESCE(Status, '')))
                            IN ('pending', 'pending approval');";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               sql,
                               connection,
                               transaction))
                    {
                        command.Parameters.Add(
                            "@ReviewedBy",
                            MySqlDbType.VarChar,
                            150).Value =
                            officer;

                        command.Parameters.Add(
                            "@ReviewNotes",
                            MySqlDbType.Text).Value =
                            GetDatabaseValue(
                                reviewNotes);

                        command.Parameters.Add(
                            "@ApplicationId",
                            MySqlDbType.VarChar,
                            50).Value =
                            applicationId;

                        int affected =
                            command.ExecuteNonQuery();

                        if (affected != 1)
                        {
                            transaction.Rollback();
                            ShowApplicationMessage(
                                "The application could not be approved. It may already have been reviewed.");

                            return;
                        }
                    }

                    InsertAuditLog(
                        connection,
                        transaction,
                        "APPLICATION_APPROVED",
                        "Application " + applicationId + " approved.");
                    int workflowActor = AdminWorkflowService.SessionActor(Context);
                    AdminWorkflowService.AppendWorkflow(connection, transaction,
                        Convert.ToInt32(workflowApp["ApplicationID"]), workflowActor, "ApplicationApproved",
                        Convert.ToString(workflowApp["Status"]), "Approved", reviewNotes);
                    AdminWorkflowService.EndAssignment(connection, transaction,
                        Convert.ToInt32(workflowApp["ApplicationID"]), workflowActor);
                    transaction.Commit();
                    }
                }

                ViewState["CurrentApplicationStatus"] =
                    "Approved";

                LoadRecordedReviewSummary(applicationId);
                SetDynamicControlText("lblModalReviewNotes", reviewNotes);
                SetDynamicControlText("lblModalRejectionReason", string.Empty);
                PrepareReviewControls();

                LoadStatistics();

                LoadApplications();

                bool emailSent;
                string emailError;

                SendDecisionEmail(
                    applicationId,
                    "Approved",
                    reviewNotes,
                    string.Empty,
                    out emailSent,
                    out emailError);

                if (emailSent)
                {
                    ShowApplicationMessage(
                        "Application " +
                        applicationId +
                        " has been approved successfully. The citizen has been notified by email.");
                }
                else
                {
                    ShowApplicationMessage(
                        "Application " +
                        applicationId +
                        " has been approved successfully, but the citizen email could not be sent.\n\n" +
                        emailError);
                }
            }
            catch (MySqlException ex)
            {
                ShowDatabaseError(
                    "The application could not be approved.",
                    ex);

                OpenModal();
            }
            catch (Exception ex)
            {
                ShowApplicationError(
                    "The application could not be approved.",
                    ex);

                OpenModal();
            }
        }


        // ---------------------------------------------------------
        // REJECT APPLICATION
        // ---------------------------------------------------------

        protected void btnRejectApplication_Click(
            object sender,
            EventArgs e)
        {
            if (!RequireOfficerAuthentication())
                return;

            string applicationId =
                Convert.ToString(
                    ViewState["CurrentApplicationId"])
                .Trim();

            if (string.IsNullOrWhiteSpace(
                applicationId))
            {
                ShowApplicationMessage(
                    "Please open an application before rejecting it.");

                return;
            }

            string rejectionReason = string.Empty;

            string selectedRejectionReason =
                GetDynamicControlText(
                    "ddlRejectionReason");

            string customRejectionReason =
                GetDynamicControlText(
                    "txtRejectionReason");

            if (string.Equals(
                    selectedRejectionReason,
                    "Custom reason",
                    StringComparison.OrdinalIgnoreCase))
            {
                rejectionReason = customRejectionReason;
            }
            else
            {
                rejectionReason = selectedRejectionReason;
            }

            if (string.IsNullOrWhiteSpace(rejectionReason))
            {
                rejectionReason =
                    GetDynamicControlText(
                        "txtCustomRejectionReason");
            }

            string additionalNotes =
                GetDynamicControlText(
                    "TextBox1");

            if (string.IsNullOrWhiteSpace(
                additionalNotes))
            {
                additionalNotes =
                    GetDynamicControlText(
                        "txtAdditionalNotes");
            }

            if (string.IsNullOrWhiteSpace(
                additionalNotes))
            {
                additionalNotes =
                    GetDynamicControlText(
                        "txtReviewNotes");
            }

            if (string.IsNullOrWhiteSpace(
                rejectionReason))
            {
                ShowApplicationMessage(
                    "Please select or enter a rejection reason.");

                OpenModal();

                return;
            }

            try
            {
                string currentStatus =
                    GetApplicationStatus(
                        applicationId);

                if (!currentStatus.Equals(
                        "Pending",
                        StringComparison.OrdinalIgnoreCase) &&
                    !currentStatus.Equals(
                        "Pending Approval",
                        StringComparison.OrdinalIgnoreCase))
                {
                    ShowApplicationMessage(
                        "Only pending applications can be rejected.");

                    return;
                }

                string officer =
                    GetCurrentOfficerIdentity();

                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();
                    using (MySqlTransaction transaction =
                           connection.BeginTransaction())
                    {
                    if (!LockPendingApplication(connection, transaction, applicationId))
                        throw new InvalidOperationException(
                            "The application is no longer pending review.");
                    DataRow workflowApp = AdminWorkflowService.LockApplication(connection, transaction, applicationId);

                    const string sql = @"
                        UPDATE applications

                        SET
                            Status = 'Rejected',
                            ReviewedBy = @ReviewedBy,
                            ReviewedAt = NOW(),
                            ReviewNotes = @ReviewNotes,
                            RejectionReason = @RejectionReason

                        WHERE application_id =
                              @ApplicationId

                        AND LOWER(TRIM(COALESCE(Status, '')))
                            IN ('pending', 'pending approval');";

                    using (MySqlCommand command =
                           new MySqlCommand(
                               sql,
                               connection,
                               transaction))
                    {
                        command.Parameters.Add(
                            "@ReviewedBy",
                            MySqlDbType.VarChar,
                            150).Value =
                            officer;

                        command.Parameters.Add(
                            "@ReviewNotes",
                            MySqlDbType.Text).Value =
                            GetDatabaseValue(
                                additionalNotes);

                        command.Parameters.Add(
                            "@RejectionReason",
                            MySqlDbType.VarChar,
                            255).Value =
                            rejectionReason;

                        command.Parameters.Add(
                            "@ApplicationId",
                            MySqlDbType.VarChar,
                            50).Value =
                            applicationId;

                        int affected =
                            command.ExecuteNonQuery();

                        if (affected != 1)
                        {
                            transaction.Rollback();
                            ShowApplicationMessage(
                                "The application could not be rejected. It may already have been reviewed.");

                            return;
                        }
                    }

                    InsertAuditLog(
                        connection,
                        transaction,
                        "APPLICATION_REJECTED",
                        "Application " + applicationId + " rejected.");
                    int workflowActor = AdminWorkflowService.SessionActor(Context);
                    AdminWorkflowService.AppendWorkflow(connection, transaction,
                        Convert.ToInt32(workflowApp["ApplicationID"]), workflowActor, "ApplicationRejected",
                        Convert.ToString(workflowApp["Status"]), "Rejected", rejectionReason);
                    AdminWorkflowService.EndAssignment(connection, transaction,
                        Convert.ToInt32(workflowApp["ApplicationID"]), workflowActor);
                    transaction.Commit();
                    }
                }

                ViewState["CurrentApplicationStatus"] =
                    "Rejected";

                LoadRecordedReviewSummary(applicationId);
                SetDynamicControlText("lblModalReviewNotes", additionalNotes);
                SetDynamicControlText("lblModalRejectionReason", rejectionReason);
                PrepareReviewControls();

                LoadStatistics();

                LoadApplications();

                bool emailSent;
                string emailError;

                SendDecisionEmail(
                    applicationId,
                    "Rejected",
                    additionalNotes,
                    rejectionReason,
                    out emailSent,
                    out emailError);

                if (emailSent)
                {
                    ShowApplicationMessage(
                        "Application " +
                        applicationId +
                        " has been rejected successfully. The citizen has been notified by email.");
                }
                else
                {
                    ShowApplicationMessage(
                        "Application " +
                        applicationId +
                        " has been rejected successfully, but the citizen email could not be sent.\n\n" +
                        emailError);
                }
            }
            catch (MySqlException ex)
            {
                ShowDatabaseError(
                    "The application could not be rejected.",
                    ex);

                OpenModal();
            }
            catch (Exception ex)
            {
                ShowApplicationError(
                    "The application could not be rejected.",
                    ex);

                OpenModal();
            }
        }


        // ---------------------------------------------------------
        // SEND CITIZEN DECISION EMAIL
        // ---------------------------------------------------------

        private void SendDecisionEmail(
            string applicationId,
            string decision,
            string reviewNotes,
            string rejectionReason,
            out bool emailSent,
            out string emailError)
        {
            emailSent = false;
            emailError = string.Empty;

            try
            {
                string citizenName;
                string citizenEmail;
                GetCitizenContact(
                    applicationId,
                    out citizenName,
                    out citizenEmail);

                if (string.IsNullOrWhiteSpace(citizenEmail))
                {
                    emailError =
                        "No citizen email address was found for this application.";
                    return;
                }

                string smtpHost =
                    ConfigurationManager.AppSettings["EmailSmtpHost"];
                string smtpPortText =
                    ConfigurationManager.AppSettings["EmailSmtpPort"];
                string smtpUsername =
                    ConfigurationManager.AppSettings["EmailSmtpUsername"];
                string smtpPassword =
                    ConfigurationManager.AppSettings["EmailSmtpPassword"];
                string fromAddress =
                    ConfigurationManager.AppSettings["EmailFromAddress"];
                string fromName =
                    ConfigurationManager.AppSettings["EmailFromName"];
                string enableSslText =
                    ConfigurationManager.AppSettings["EmailEnableSsl"];

                if (string.IsNullOrWhiteSpace(smtpHost) ||
                    string.IsNullOrWhiteSpace(smtpUsername) ||
                    string.IsNullOrWhiteSpace(smtpPassword) ||
                    string.IsNullOrWhiteSpace(fromAddress))
                {
                    emailError =
                        "SMTP email settings are missing from Web.config.";
                    return;
                }

                int smtpPort = 587;
                int parsedPort;
                if (int.TryParse(smtpPortText, out parsedPort) && parsedPort > 0)
                {
                    smtpPort = parsedPort;
                }

                bool enableSsl = true;
                bool parsedSsl;
                if (bool.TryParse(enableSslText, out parsedSsl))
                {
                    enableSsl = parsedSsl;
                }

                string safeName =
                    string.IsNullOrWhiteSpace(citizenName)
                    ? "Citizen"
                    : citizenName.Trim();

                string subject =
                    "Ghana Police Background Check - Application " +
                    applicationId + " " + decision;

                StringBuilder body =
                    new StringBuilder();

                body.AppendLine("Dear " + safeName + ",");
                body.AppendLine();
                body.AppendLine(
                    "Your Ghana Police Background Check application has been " +
                    decision.ToLowerInvariant() + ".");
                body.AppendLine();
                body.AppendLine(
                    "Application ID: " + applicationId);
                body.AppendLine(
                    "Decision: " + decision);

                if (decision.Equals(
                        "Approved",
                        StringComparison.OrdinalIgnoreCase))
                {
                    body.AppendLine();
                    body.AppendLine(
                        "Your application has completed the required manual document review and police review.");
                    body.AppendLine();
                    body.AppendLine(
                        "The next step is payment of the GHS 150 processing fee.");
                    body.AppendLine(
                        "You will be directed to the payment page through the citizen portal.");
                }
                else
                {
                    body.AppendLine();
                    body.AppendLine(
                        "Reason for rejection: " +
                        (string.IsNullOrWhiteSpace(rejectionReason)
                            ? "Not specified"
                            : rejectionReason.Trim()));
                }

                if (!string.IsNullOrWhiteSpace(reviewNotes))
                {
                    body.AppendLine();
                    body.AppendLine(
                        "Officer review notes: " + reviewNotes.Trim());
                }

                body.AppendLine();
                body.AppendLine(
                    "This is an automated notification from the Ghana Police Background Check System.");
                body.AppendLine(
                    "Please do not reply directly to this email.");

                using (MailMessage message =
                       new MailMessage())
                {
                    message.From =
                        new MailAddress(
                            fromAddress.Trim(),
                            string.IsNullOrWhiteSpace(fromName)
                                ? "Ghana Police Background Check System"
                                : fromName.Trim());

                    message.To.Add(
                        new MailAddress(citizenEmail.Trim()));

                    message.Subject = subject;
                    message.Body = body.ToString();
                    message.IsBodyHtml = false;

                    using (SmtpClient smtp =
                           new SmtpClient(
                               smtpHost.Trim(),
                               smtpPort))
                    {
                        smtp.EnableSsl = enableSsl;
                        smtp.UseDefaultCredentials = false;
                        smtp.Credentials =
                            new NetworkCredential(
                                smtpUsername.Trim(),
                                smtpPassword);
                        smtp.Send(message);
                    }
                }

                emailSent = true;
            }
            catch (SmtpException ex)
            {
                emailError =
                    "SMTP error: " + ex.Message;
            }
            catch (FormatException ex)
            {
                emailError =
                    "Invalid email address or email setting: " + ex.Message;
            }
            catch (Exception ex)
            {
                emailError =
                    "Email error: " + ex.Message;
            }
        }


        // ---------------------------------------------------------
        // GET CITIZEN CONTACT DETAILS
        // ---------------------------------------------------------

        private void GetCitizenContact(
            string applicationId,
            out string citizenName,
            out string citizenEmail)
        {
            citizenName = string.Empty;
            citizenEmail = string.Empty;

            using (MySqlConnection connection =
                   new MySqlConnection(connStr))
            {
                connection.Open();

                const string sql = @"
                    SELECT
                        FullName,
                        Email
                    FROM applications
                    WHERE application_id =
                          @ApplicationId
                    LIMIT 1;";

                using (MySqlCommand command =
                       new MySqlCommand(
                           sql,
                           connection))
                {
                    command.Parameters.Add(
                        "@ApplicationId",
                        MySqlDbType.VarChar,
                        50).Value =
                        applicationId.Trim();

                    using (MySqlDataReader reader =
                           command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            throw new InvalidOperationException(
                                "The application could not be found when preparing the citizen email.");
                        }

                        citizenName =
                            GetReaderString(
                                reader,
                                "FullName");

                        citizenEmail =
                            GetReaderString(
                                reader,
                                "Email");
                    }
                }
            }
        }


        // ---------------------------------------------------------
        // GET APPLICATION STATUS
        // ---------------------------------------------------------

        private string GetApplicationStatus(
            string applicationId)
        {
            using (MySqlConnection connection =
                   new MySqlConnection(connStr))
            {
                connection.Open();

                const string sql = @"
                    SELECT Status
                    FROM applications
                    WHERE application_id =
                          @ApplicationId
                    LIMIT 1;";

                using (MySqlCommand command =
                       new MySqlCommand(
                           sql,
                           connection))
                {
                    command.Parameters.Add(
                        "@ApplicationId",
                        MySqlDbType.VarChar,
                        50).Value =
                        applicationId;

                    object result =
                        command.ExecuteScalar();

                    return
                        Convert.ToString(
                            result).Trim();
                }
            }
        }


        // ---------------------------------------------------------
        // DATABASE NULL VALUE
        // ---------------------------------------------------------

        private object GetDatabaseValue(
            string value)
        {
            if (string.IsNullOrWhiteSpace(
                value))
            {
                return DBNull.Value;
            }

            return value.Trim();
        }


        // ---------------------------------------------------------
        // NORMALIZE IDENTITY VALUES
        // ---------------------------------------------------------

        private string NormalizeForComparison(
            string value)
        {
            if (string.IsNullOrWhiteSpace(
                value))
            {
                return string.Empty;
            }

            return
                value.Trim()
                     .Replace(" ", "")
                     .Replace(".", "")
                     .Replace(",", "")
                     .Replace("-", "")
                     .ToUpperInvariant();
        }


        // ---------------------------------------------------------
        // GET DATE VALUE
        // ---------------------------------------------------------

        private DateTime GetReaderDateValue(
            MySqlDataReader reader,
            string columnName,
            out bool available)
        {
            available = false;

            try
            {
                int ordinal =
                    reader.GetOrdinal(
                        columnName);

                if (reader.IsDBNull(
                    ordinal))
                {
                    return DateTime.MinValue;
                }

                DateTime value;

                if (reader.GetValue(
                    ordinal) is DateTime)
                {
                    value =
                        (DateTime)
                            reader.GetValue(
                                ordinal);
                }
                else if (!DateTime.TryParse(
                    reader.GetValue(
                        ordinal).ToString(),
                    out value))
                {
                    return DateTime.MinValue;
                }

                available = true;

                return value;
            }
            catch
            {
                return DateTime.MinValue;
            }
        }


        // ---------------------------------------------------------
        // GET BOOLEAN
        // ---------------------------------------------------------

        private bool GetReaderBoolean(
            MySqlDataReader reader,
            string columnName)
        {
            try
            {
                int ordinal =
                    reader.GetOrdinal(
                        columnName);

                if (reader.IsDBNull(
                    ordinal))
                {
                    return false;
                }

                object value =
                    reader.GetValue(
                        ordinal);

                if (value is bool)
                {
                    return (bool)value;
                }

                int number;

                if (int.TryParse(
                    value.ToString(),
                    out number))
                {
                    return number == 1;
                }

                bool booleanValue;

                if (bool.TryParse(
                    value.ToString(),
                    out booleanValue))
                {
                    return booleanValue;
                }

                return false;
            }
            catch
            {
                return false;
            }
        }


        // ---------------------------------------------------------
        // DYNAMIC CONTROL LOOKUP
        // ---------------------------------------------------------

        private Control FindControlRecursive(
            Control root,
            string id)
        {
            if (root == null)
                return null;

            if (root.ID == id)
                return root;

            foreach (Control child in root.Controls)
            {
                Control result =
                    FindControlRecursive(
                        child,
                        id);

                if (result != null)
                    return result;
            }

            return null;
        }


        // ---------------------------------------------------------
        // GET DYNAMIC CONTROL TEXT
        // ---------------------------------------------------------

        private string GetDynamicControlText(
            string controlId)
        {
            Control control =
                FindControlRecursive(
                    this,
                    controlId);

            if (control == null)
                return string.Empty;

            TextBox textBox =
                control as TextBox;

            if (textBox != null)
            {
                return textBox.Text.Trim();
            }

            DropDownList dropDown =
                control as DropDownList;

            if (dropDown != null)
            {
                if (!string.IsNullOrWhiteSpace(
                    dropDown.SelectedValue))
                {
                    return
                        dropDown.SelectedValue.Trim();
                }

                return
                    dropDown.SelectedItem != null
                    ? dropDown.SelectedItem.Text.Trim()
                    : string.Empty;
            }

            Label label =
                control as Label;

            if (label != null)
            {
                return
                    HttpUtility.HtmlDecode(
                        label.Text).Trim();
            }

            HtmlInputGenericControl input =
                control as HtmlInputGenericControl;

            if (input != null)
            {
                return
                    Convert.ToString(
                        input.Value).Trim();
            }

            return string.Empty;
        }


        // ---------------------------------------------------------
        // SET DYNAMIC CONTROL TEXT
        // ---------------------------------------------------------

        private void SetDynamicControlText(
            string controlId,
            string value)
        {
            Control control =
                FindControlRecursive(
                    this,
                    controlId);

            if (control == null)
                return;

            TextBox textBox =
                control as TextBox;

            if (textBox != null)
            {
                textBox.Text =
                    value ?? "";

                return;
            }

            DropDownList dropDown =
                control as DropDownList;

            if (dropDown != null)
            {
                if (!string.IsNullOrWhiteSpace(
                    value))
                {
                    ListItem item =
                        dropDown.Items.FindByValue(
                            value);

                    if (item == null)
                    {
                        item =
                            dropDown.Items.FindByText(
                                value);
                    }

                    if (item != null)
                    {
                        dropDown.ClearSelection();
                        item.Selected = true;
                    }
                }

                return;
            }

            Label label =
                control as Label;

            if (label != null)
            {
                label.Text =
                    EncodeOrDefault(
                        value);

                return;
            }

            HtmlInputGenericControl input =
                control as HtmlInputGenericControl;

            if (input != null)
            {
                input.Value =
                    value ?? "";
            }
        }


        // ---------------------------------------------------------
        // SET DYNAMIC CONTROL VISIBILITY
        // ---------------------------------------------------------

        private void SetDynamicControlVisible(
            string controlId,
            bool visible)
        {
            Control control =
                FindControlRecursive(
                    this,
                    controlId);

            if (control == null)
                return;

            control.Visible =
                visible;
        }


        // ---------------------------------------------------------
        // OPEN MODAL
        // ---------------------------------------------------------

        private void OpenModal()
        {
            // Re-open the SAME application modal after a server postback.
            // This is required for Verify Identity because verification is
            // performed server-side and the result must be shown in the
            // existing View Application modal.
            string script = @"
                window.setTimeout(function () {

                    var modal =
                        document.getElementById('applicationModal');

                    if (modal) {

                        modal.classList.add('show');
                        document.body.style.overflow = 'hidden';

                    }

                }, 100);
            ";

            // Site.Master normally contains the ScriptManager.
            // The fallback also works if this page is ever used without one.
            if (ScriptManager.GetCurrent(Page) != null)
            {
                ScriptManager.RegisterStartupScript(
                    this,
                    GetType(),
                    "OpenApplicationModal",
                    script,
                    true);
            }
            else
            {
                Page.ClientScript.RegisterStartupScript(
                    GetType(),
                    "OpenApplicationModal",
                    script,
                    true);
            }
        }


        // ---------------------------------------------------------
        // APPLICATION MESSAGE
        // ---------------------------------------------------------

        private void ShowApplicationMessage(
            string message)
        {
            string safeMessage =
                HttpUtility.JavaScriptStringEncode(
                    message);

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                "alert('" +
                safeMessage +
                "');",
                true);
        }


        // ---------------------------------------------------------
        // DATABASE ERROR
        // ---------------------------------------------------------

        private void ShowDatabaseError(
            string userMessage,
            MySqlException ex)
        {
            System.Diagnostics.Trace.TraceError(
                "Vetting operation failed (MySQL error {0}).",
                ex.Number);

            string safeMessage =
                HttpUtility.JavaScriptStringEncode(
                    userMessage);

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                "alert('" +
                safeMessage +
                "');",
                true);
        }


        // ---------------------------------------------------------
        // GENERAL ERROR
        // ---------------------------------------------------------

        private void ShowApplicationError(
            string userMessage,
            Exception ex)
        {
            System.Diagnostics.Trace.TraceError(
                "Vetting operation failed ({0}).",
                ex.GetType().Name);

            string safeMessage =
                HttpUtility.JavaScriptStringEncode(
                    userMessage);

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                "alert('" +
                safeMessage +
                "');",
                true);
        }
    }
}