using System;
using System.Configuration;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class SubmitApplication : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString;

        // ============================================================
        // PAGE LOAD
        // ============================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            if (!IsPostBack)
            {
                if (successPanel != null)
                {
                    successPanel.Attributes["class"] = "success-panel";
                    successPanel.Style["display"] = "none";
                }

                if (errorMessage != null)
                {
                    errorMessage.Attributes["class"] =
                        "message-box message-error";

                    errorMessage.InnerHtml = "";
                    errorMessage.Style["display"] = "none";
                }

                HtmlInputGenericControl emailInput =
                    FindControlRecursive(this, "email") as HtmlInputGenericControl;
                if (emailInput != null)
                {
                    emailInput.Value = GetSessionEmail() ?? String.Empty;
                    emailInput.Attributes["readonly"] = "readonly";
                }

                string today =
                    DateTime.Now.ToString("yyyy-MM-dd");

                HtmlInputGenericControl dob =
                    FindControlRecursive(this, "dateOfBirth")
                    as HtmlInputGenericControl;

                if (dob != null)
                {
                    dob.Attributes["max"] = today;
                }

                HtmlInputGenericControl issueDate =
                    FindControlRecursive(this, "idIssueDate")
                    as HtmlInputGenericControl;

                if (issueDate != null)
                {
                    issueDate.Attributes["max"] = today;
                }

                HtmlInputGenericControl travelDate =
                    FindControlRecursive(this, "travelDate")
                    as HtmlInputGenericControl;

                if (travelDate != null)
                {
                    travelDate.Attributes["min"] = today;
                }

                // Load the citizen's latest application service status.
                // This only affects the new Payment/Certificate service area.
                LoadCitizenServices();
            }
        }

        // ============================================================
        // MAIN SUBMISSION
        // ============================================================

        protected void btnSubmitApplication_ServerClick(
            object sender,
            EventArgs e)
        {
            string applicationId = null;
            string documentFolder = null;

            try
            {
                if (!IsUserLoggedIn() || !IsCitizenRole())
                {
                    ShowError(
                        "Sign in with a citizen account to submit an application."
                    );

                    return;
                }

                string email = GetSessionEmail();
                if (String.IsNullOrWhiteSpace(email))
                {
                    ShowError("Your session has expired. Please sign in again.");
                    return;
                }

                string fullName = GetFormValue("fullName");
                string gender = GetFormValue("gender");
                string dateOfBirth = GetFormValue("dateOfBirth");
                string maritalStatus = GetFormValue("maritalStatus");
                string placeOfBirth = GetFormValue("placeOfBirth");
                string gpsAddress = GetFormValue("gpsAddress");
                string phone = GetFormValue("phone");
                string profession = GetFormValue("profession");
                string nextOfKinName = GetFormValue("nextOfKinName");
                string nextOfKinPhone = GetFormValue("nextOfKinPhone");
                string nationalIdType = GetFormValue("nationalIdType");
                string nationalIdNumber = GetFormValue("nationalIdNumber");
                string idIssueDate = GetFormValue("idIssueDate");
                string idIssueLocation = GetFormValue("idIssueLocation");
                string purpose = GetFormValue("applicationPurpose");
                string employerName = GetFormValue("employerName");
                string employmentPosition = GetFormValue("employmentPosition");
                string employerAddress = GetFormValue("employerAddress");
                string institutionName = GetFormValue("institutionName");
                string programmeName = GetFormValue("programmeName");
                string studentId = GetFormValue("studentId");
                string destinationCountry = GetFormValue("destinationCountry");
                string visaType = GetFormValue("visaType");
                string travelDate = GetFormValue("travelDate");
                string otherPurpose = GetFormValue("otherPurpose");
                string declarationAccepted = GetFormValue("declarationAccepted");

                string validationError =
                    ValidateApplication(
                        fullName,
                        gender,
                        dateOfBirth,
                        maritalStatus,
                        placeOfBirth,
                        gpsAddress,
                        email,
                        phone,
                        profession,
                        nextOfKinName,
                        nextOfKinPhone,
                        nationalIdType,
                        nationalIdNumber,
                        idIssueDate,
                        purpose,
                        employerName,
                        employmentPosition,
                        employerAddress,
                        institutionName,
                        programmeName,
                        studentId,
                        destinationCountry,
                        visaType,
                        travelDate,
                        otherPurpose,
                        declarationAccepted
                    );

                if (!string.IsNullOrWhiteSpace(validationError))
                {
                    ShowError(validationError);
                    return;
                }

                HttpPostedFile passportPhoto =
                    Request.Files["passportPhoto"];

                HttpPostedFile ghanaCardFront =
                    Request.Files["ghanaCardFront"];

                HttpPostedFile ghanaCardBack =
                    Request.Files["ghanaCardBack"];

                HttpPostedFile identityDocument =
                    Request.Files["identityDocument"];
                HttpPostedFile identityDocumentBack =
                    Request.Files["identityDocumentBack"];

                if (passportPhoto == null ||
                    passportPhoto.ContentLength <= 0)
                {
                    ShowError(
                        "Please select your passport photograph."
                    );

                    return;
                }

                string passportError =
                    ValidateUploadedFile(
                        passportPhoto,
                        true
                    );

                if (!string.IsNullOrWhiteSpace(passportError))
                {
                    ShowError(passportError);
                    return;
                }

                bool isGhanaCard =
                    nationalIdType.Equals(
                        "Ghana Card",
                        StringComparison.OrdinalIgnoreCase
                    );
                bool requiresOtherIdDocument =
                    nationalIdType.Equals(
                        "Passport",
                        StringComparison.OrdinalIgnoreCase
                    ) ||
                    nationalIdType.Equals(
                        "Voter ID",
                        StringComparison.OrdinalIgnoreCase
                    ) ||
                    nationalIdType.Equals(
                        "Driver's Licence",
                        StringComparison.OrdinalIgnoreCase
                    );

                if (isGhanaCard)
                {
                    if (ghanaCardFront == null ||
                        ghanaCardFront.ContentLength <= 0)
                    {
                        ShowError(
                            "Please upload the front of your Ghana Card."
                        );

                        return;
                    }

                    if (ghanaCardBack == null ||
                        ghanaCardBack.ContentLength <= 0)
                    {
                        ShowError(
                            "Please upload the back of your Ghana Card."
                        );

                        return;
                    }
                }

                if (ghanaCardFront != null &&
                    ghanaCardFront.ContentLength > 0)
                {
                    string frontError =
                        ValidateUploadedFile(
                            ghanaCardFront,
                            false
                        );

                    if (!string.IsNullOrWhiteSpace(frontError))
                    {
                        ShowError(frontError);
                        return;
                    }
                }

                if (ghanaCardBack != null &&
                    ghanaCardBack.ContentLength > 0)
                {
                    string backError =
                        ValidateUploadedFile(
                            ghanaCardBack,
                            false
                        );

                    if (!string.IsNullOrWhiteSpace(backError))
                    {
                        ShowError(backError);
                        return;
                    }
                }

                if (requiresOtherIdDocument)
                {
                    if (identityDocument == null ||
                        identityDocument.ContentLength <= 0)
                    {
                        ShowError(
                            nationalIdType.Equals(
                                "Passport",
                                StringComparison.OrdinalIgnoreCase)
                                ? "Please upload the passport bio-data page."
                                : "Please upload the front of your " + nationalIdType + ".");
                        return;
                    }
                    if (!nationalIdType.Equals("Passport", StringComparison.OrdinalIgnoreCase))
                    {
                        if (identityDocumentBack == null || identityDocumentBack.ContentLength <= 0)
                        {
                            ShowError("Please upload the back of your " + nationalIdType + ".");
                            return;
                        }
                        string backIdentityError = ValidateUploadedFile(identityDocumentBack, false);
                        if (!string.IsNullOrWhiteSpace(backIdentityError))
                        {
                            ShowError(backIdentityError);
                            return;
                        }
                    }

                    string identityDocumentError =
                        ValidateUploadedFile(
                            identityDocument,
                            false);

                    if (!string.IsNullOrWhiteSpace(identityDocumentError))
                    {
                        ShowError(identityDocumentError);
                        return;
                    }
                }

                applicationId =
                    GenerateApplicationId();

                DateTime dobValue =
                    DateTime.Parse(dateOfBirth).Date;

                DateTime idIssueDateValue =
                    DateTime.Parse(idIssueDate).Date;

                object travelDateValue =
                    DBNull.Value;

                if (!string.IsNullOrWhiteSpace(travelDate))
                {
                    DateTime parsedTravelDate;

                    if (DateTime.TryParse(
                        travelDate,
                        out parsedTravelDate))
                    {
                        travelDateValue =
                            parsedTravelDate.Date;
                    }
                }

                using (MySqlConnection connection =
                    new MySqlConnection(connStr))
                {
                    connection.Open();

                    using (MySqlTransaction transaction =
                        connection.BeginTransaction())
                    {
                        try
                        {
                            const string insertQuery = @"
                                INSERT INTO applications
                                (
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
                                    DateSubmitted
                                )
                                VALUES
                                (
                                    @application_id,
                                    @FullName,
                                    @Gender,
                                    @DateOfBirth,
                                    @MaritalStatus,
                                    @PlaceOfBirth,
                                    @GPSAddress,
                                    @Email,
                                    @Phone,
                                    @Profession,
                                    @NextOfKinName,
                                    @NextOfKinPhone,
                                    @NationalIDType,
                                    @GhanaCard,
                                    @IDIssueDate,
                                    @IDIssueLocation,
                                    @Purpose,
                                    @EmployerName,
                                    @EmploymentPosition,
                                    @EmployerAddress,
                                    @InstitutionName,
                                    @ProgrammeName,
                                    @StudentID,
                                    @DestinationCountry,
                                    @VisaType,
                                    @TravelDate,
                                    @OtherPurpose,
                                    @Status,
                                    @DateSubmitted
                                );";

                            using (MySqlCommand command =
                                new MySqlCommand(
                                    insertQuery,
                                    connection,
                                    transaction))
                            {
                                command.Parameters.Add(
                                    "@application_id",
                                    MySqlDbType.VarChar,
                                    50
                                ).Value = applicationId;

                                command.Parameters.Add(
                                    "@FullName",
                                    MySqlDbType.VarChar,
                                    150
                                ).Value = fullName;

                                command.Parameters.Add(
                                    "@Gender",
                                    MySqlDbType.VarChar,
                                    20
                                ).Value = gender;

                                command.Parameters.Add(
                                    "@DateOfBirth",
                                    MySqlDbType.Date
                                ).Value = dobValue;

                                command.Parameters.Add(
                                    "@MaritalStatus",
                                    MySqlDbType.VarChar,
                                    50
                                ).Value = maritalStatus;

                                command.Parameters.Add(
                                    "@PlaceOfBirth",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = placeOfBirth;

                                command.Parameters.Add(
                                    "@GPSAddress",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = gpsAddress;

                                command.Parameters.Add(
                                    "@Email",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = email;

                                command.Parameters.Add(
                                    "@Phone",
                                    MySqlDbType.VarChar,
                                    30
                                ).Value = phone;

                                command.Parameters.Add(
                                    "@Profession",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = profession;

                                command.Parameters.Add(
                                    "@NextOfKinName",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = nextOfKinName;

                                command.Parameters.Add(
                                    "@NextOfKinPhone",
                                    MySqlDbType.VarChar,
                                    30
                                ).Value = nextOfKinPhone;

                                command.Parameters.Add(
                                    "@NationalIDType",
                                    MySqlDbType.VarChar,
                                    50
                                ).Value = nationalIdType;

                                command.Parameters.Add(
                                    "@GhanaCard",
                                    MySqlDbType.VarChar,
                                    50
                                ).Value = nationalIdNumber;

                                command.Parameters.Add(
                                    "@IDIssueDate",
                                    MySqlDbType.Date
                                ).Value = idIssueDateValue;

                                command.Parameters.Add(
                                    "@IDIssueLocation",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = idIssueLocation;

                                command.Parameters.Add(
                                    "@Purpose",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value = purpose;

                                command.Parameters.Add(
                                    "@EmployerName",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value =
                                    GetDatabaseValue(employerName);

                                command.Parameters.Add(
                                    "@EmploymentPosition",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value =
                                    GetDatabaseValue(employmentPosition);

                                command.Parameters.Add(
                                    "@EmployerAddress",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value =
                                    GetDatabaseValue(employerAddress);

                                command.Parameters.Add(
                                    "@InstitutionName",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value =
                                    GetDatabaseValue(institutionName);

                                command.Parameters.Add(
                                    "@ProgrammeName",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value =
                                    GetDatabaseValue(programmeName);

                                command.Parameters.Add(
                                    "@StudentID",
                                    MySqlDbType.VarChar,
                                    100
                                ).Value =
                                    GetDatabaseValue(studentId);

                                command.Parameters.Add(
                                    "@DestinationCountry",
                                    MySqlDbType.VarChar,
                                    255
                                ).Value =
                                    GetDatabaseValue(destinationCountry);

                                command.Parameters.Add(
                                    "@VisaType",
                                    MySqlDbType.VarChar,
                                    100
                                ).Value =
                                    GetDatabaseValue(visaType);

                                command.Parameters.Add(
                                    "@TravelDate",
                                    MySqlDbType.Date
                                ).Value =
                                    travelDateValue;

                                command.Parameters.Add(
                                    "@OtherPurpose",
                                    MySqlDbType.VarChar,
                                    500
                                ).Value =
                                    GetDatabaseValue(otherPurpose);

                                command.Parameters.Add(
                                    "@Status",
                                    MySqlDbType.VarChar,
                                    50
                                ).Value = "Pending";

                                command.Parameters.Add(
                                    "@DateSubmitted",
                                    MySqlDbType.DateTime
                                ).Value = DateTime.Now;

                                int rowsAffected =
                                    command.ExecuteNonQuery();

                                if (rowsAffected != 1)
                                {
                                    throw new Exception(
                                        "The application could not be saved."
                                    );
                                }
                                AdminWorkflowService.AppendWorkflow(connection, transaction,
                                    checked((int)command.LastInsertedId), AdminWorkflowService.SessionActor(Context),
                                    "ApplicationSubmitted", null, "Pending", "Application submitted by the authenticated applicant.");
                            }

                            transaction.Commit();
                        }
                        catch
                        {
                            try
                            {
                                transaction.Rollback();
                            }
                            catch
                            {
                            }

                            throw;
                        }
                    }
                }

                try
                {
                    documentFolder =
                        SaveApplicationDocuments(
                            applicationId,
                            passportPhoto,
                            isGhanaCard ? ghanaCardFront : null,
                            isGhanaCard ? ghanaCardBack : null,
                            requiresOtherIdDocument ? identityDocument : null,
                            requiresOtherIdDocument && !nationalIdType.Equals("Passport", StringComparison.OrdinalIgnoreCase)
                                ? identityDocumentBack : null
                        );
                }
                catch (Exception documentException)
                {
                    System.Diagnostics.Trace.TraceError(
                        "Application document storage failed ({0}).",
                        documentException.GetType().Name);
                    ShowError(
                        "Your application was saved with Application ID " +
                        applicationId +
                        ", but there was a problem saving one or more " +
                        "uploaded documents. Please contact the administrator."
                    );

                    return;
                }

                RecordApplicationSubmission(applicationId);
                ShowSuccess(applicationId);
            }
            catch (MySqlException ex)
            {
                string message;

                switch (ex.Number)
                {
                    case 1062:
                        message =
                            "This application could not be submitted because " +
                            "a duplicate application reference was generated. " +
                            "Please try again.";
                        break;

                    case 1146:
                        message =
                            "The applications table could not be found in the " +
                            "connected database. Please check the database name.";
                        break;

                    case 1054:
                        message =
                            "The database structure does not match the application " +
                            "system. Please verify the applications table columns.";
                        break;

                    case 1045:
                        message =
                            "The system could not connect to the MySQL database. " +
                            "Please make sure XAMPP MySQL is running.";
                        break;

                    default:
                        message =
                            "The application could not be submitted. Please try again later.";
                        break;
                }

                System.Diagnostics.Trace.TraceError(
                    "Application submission failed (MySQL error {0}).",
                    ex.Number);
                ShowError(message);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Application submission failed ({0}).",
                    ex.GetType().Name);
                ShowError(
                    "An unexpected error occurred while submitting your application. Please try again."
                );
            }
        }

        // ============================================================
        // CHECK LOGIN
        // ============================================================

        private bool IsUserLoggedIn()
        {
            bool authenticated;
            int userId;

            return Boolean.TryParse(
                    Convert.ToString(Session["IsAuthenticated"]),
                    out authenticated) &&
                authenticated &&
                Int32.TryParse(
                    Convert.ToString(Session["UserID"]),
                    out userId) &&
                userId > 0 &&
                !String.IsNullOrWhiteSpace(GetSessionEmail());
        }

        // ============================================================
        // GET FORM VALUE
        // ============================================================

        private string GetFormValue(string fieldName)
        {
            string value =
                Request.Form[fieldName];

            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            return value.Trim();
        }

        // ============================================================
        // DATABASE NULL VALUE
        // ============================================================

        private object GetDatabaseValue(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return DBNull.Value;
            }

            return value.Trim();
        }

        // ============================================================
        // VALIDATE APPLICATION
        // ============================================================

        private string ValidateApplication(
            string fullName,
            string gender,
            string dateOfBirth,
            string maritalStatus,
            string placeOfBirth,
            string gpsAddress,
            string email,
            string phone,
            string profession,
            string nextOfKinName,
            string nextOfKinPhone,
            string nationalIdType,
            string nationalIdNumber,
            string idIssueDate,
            string purpose,
            string employerName,
            string employmentPosition,
            string employerAddress,
            string institutionName,
            string programmeName,
            string studentId,
            string destinationCountry,
            string visaType,
            string travelDate,
            string otherPurpose,
            string declarationAccepted)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "Full name is required.";

            if (fullName.Length > 150)
                return "Full name cannot exceed 150 characters.";

            if (string.IsNullOrWhiteSpace(gender))
                return "Please select your gender.";

            if (string.IsNullOrWhiteSpace(dateOfBirth))
                return "Date of birth is required.";

            DateTime parsedDob;

            if (!DateTime.TryParse(
                dateOfBirth,
                out parsedDob))
            {
                return "Please enter a valid date of birth.";
            }

            if (parsedDob.Date > DateTime.Today)
                return "Date of birth cannot be in the future.";

            if (string.IsNullOrWhiteSpace(maritalStatus))
                return "Please select your marital status.";

            if (string.IsNullOrWhiteSpace(placeOfBirth))
                return "Place of birth is required.";

            if (string.IsNullOrWhiteSpace(gpsAddress))
                return "GhanaPost GPS address is required.";

            if (string.IsNullOrWhiteSpace(email))
                return "Email address is required.";

            if (!IsValidEmail(email))
                return "Please enter a valid email address.";

            if (string.IsNullOrWhiteSpace(phone))
                return "Mobile number is required.";

            string cleanPhone =
                phone.Replace(" ", "")
                     .Replace("-", "");

            if (!Regex.IsMatch(
                    cleanPhone,
                    @"^0(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return "Please enter a valid Ghana mobile number.";
            }

            if (string.IsNullOrWhiteSpace(profession))
                return "Profession / occupation is required.";

            if (string.IsNullOrWhiteSpace(nextOfKinName))
                return "Next of kin name is required.";

            if (string.IsNullOrWhiteSpace(nextOfKinPhone))
                return "Next of kin phone number is required.";

            string cleanKinPhone =
                nextOfKinPhone.Replace(" ", "")
                              .Replace("-", "");

            if (!Regex.IsMatch(
                    cleanKinPhone,
                    @"^0(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return
                    "Please enter a valid next of kin Ghana mobile number.";
            }

            if (string.IsNullOrWhiteSpace(nationalIdType))
                return "Please select a national ID type.";

            if (!nationalIdType.Equals(
                    "Ghana Card",
                    StringComparison.OrdinalIgnoreCase) &&
                !nationalIdType.Equals(
                    "Passport",
                    StringComparison.OrdinalIgnoreCase) &&
                !nationalIdType.Equals(
                    "Voter ID",
                    StringComparison.OrdinalIgnoreCase) &&
                !nationalIdType.Equals(
                    "Driver's Licence",
                    StringComparison.OrdinalIgnoreCase))
                return "Please select a supported national ID type.";

            if (string.IsNullOrWhiteSpace(nationalIdNumber))
                return "National ID / Passport number is required.";

            if (string.IsNullOrWhiteSpace(idIssueDate))
                return "ID issue date is required.";

            DateTime parsedIssueDate;

            if (!DateTime.TryParse(
                idIssueDate,
                out parsedIssueDate))
            {
                return "Please enter a valid ID issue date.";
            }

            if (parsedIssueDate.Date > DateTime.Today)
                return "ID issue date cannot be in the future.";

            if (string.IsNullOrWhiteSpace(purpose))
                return "Please select an application purpose.";

            if (purpose.Equals(
                    "Employment",
                    StringComparison.OrdinalIgnoreCase))
            {
                if (string.IsNullOrWhiteSpace(employerName))
                    return "Employer / organisation is required.";

                if (string.IsNullOrWhiteSpace(employmentPosition))
                    return "Employment position is required.";

                if (string.IsNullOrWhiteSpace(employerAddress))
                    return "Employer address is required.";
            }

            if (purpose.Equals(
                    "Education Background",
                    StringComparison.OrdinalIgnoreCase))
            {
                if (string.IsNullOrWhiteSpace(institutionName))
                    return "Educational institution is required.";

                if (string.IsNullOrWhiteSpace(programmeName))
                    return "Programme is required.";
            }

            if (purpose.Equals(
                    "Travel/Visa",
                    StringComparison.OrdinalIgnoreCase))
            {
                if (string.IsNullOrWhiteSpace(destinationCountry))
                    return "Destination country is required.";

                if (string.IsNullOrWhiteSpace(visaType))
                    return "Visa type is required.";

                if (string.IsNullOrWhiteSpace(travelDate))
                    return "Travel date is required.";

                DateTime parsedTravelDate;

                if (!DateTime.TryParse(
                    travelDate,
                    out parsedTravelDate))
                {
                    return "Please enter a valid travel date.";
                }

                if (parsedTravelDate.Date < DateTime.Today)
                    return "Travel date cannot be in the past.";
            }

            if (purpose.Equals(
                    "Other",
                    StringComparison.OrdinalIgnoreCase))
            {
                if (string.IsNullOrWhiteSpace(otherPurpose))
                    return
                        "Please explain the purpose of the application.";
            }

            if (string.IsNullOrWhiteSpace(declarationAccepted))
                return
                    "You must accept the declaration before submitting.";

            return string.Empty;
        }

        // ============================================================
        // EMAIL VALIDATION
        // ============================================================

        private bool IsValidEmail(string email)
        {
            try
            {
                var address =
                    new System.Net.Mail.MailAddress(email);

                return address.Address.Equals(
                    email,
                    StringComparison.OrdinalIgnoreCase
                );
            }
            catch
            {
                return false;
            }
        }

        // ============================================================
        // VALIDATE UPLOADED FILE
        // ============================================================

        private string ValidateUploadedFile(
            HttpPostedFile file,
            bool passportPhoto)
        {
            if (file == null ||
                file.ContentLength <= 0)
            {
                return passportPhoto
                    ? "Passport photograph is required."
                    : "The selected document is empty.";
            }

            const int maxFileSize =
                5 * 1024 * 1024;

            if (file.ContentLength > maxFileSize)
            {
                return
                    "The file \"" +
                    Path.GetFileName(file.FileName) +
                    "\" exceeds the maximum size of 5 MB.";
            }

            string extension =
                Path.GetExtension(file.FileName)
                    .ToLowerInvariant();

            if (passportPhoto)
            {
                if (extension != ".jpg" &&
                    extension != ".jpeg" &&
                    extension != ".png")
                {
                    return
                        "Passport photograph must be JPG, JPEG, or PNG.";
                }
            }
            else
            {
                if (extension != ".jpg" &&
                    extension != ".jpeg" &&
                    extension != ".png" &&
                    extension != ".pdf")
                {
                    return
                        "Identity documents must be JPG, JPEG, PNG, or PDF.";
                }
            }

            if (!HasExpectedFileSignature(file, extension))
            {
                return "The selected file content does not match its file type.";
            }

            return string.Empty;
        }

        private bool HasExpectedFileSignature(
            HttpPostedFile file,
            string extension)
        {
            Stream stream = file.InputStream;
            if (stream == null || !stream.CanSeek)
                return false;

            long originalPosition = stream.Position;
            byte[] header = new byte[8];
            int bytesRead = 0;

            try
            {
                stream.Position = 0;
                while (bytesRead < header.Length)
                {
                    int read = stream.Read(
                        header,
                        bytesRead,
                        header.Length - bytesRead);
                    if (read <= 0)
                        break;
                    bytesRead += read;
                }

                if (extension == ".jpg" || extension == ".jpeg")
                {
                    return bytesRead >= 3 &&
                        header[0] == 0xFF &&
                        header[1] == 0xD8 &&
                        header[2] == 0xFF;
                }

                if (extension == ".png")
                {
                    return bytesRead >= 8 &&
                        header[0] == 0x89 &&
                        header[1] == 0x50 &&
                        header[2] == 0x4E &&
                        header[3] == 0x47 &&
                        header[4] == 0x0D &&
                        header[5] == 0x0A &&
                        header[6] == 0x1A &&
                        header[7] == 0x0A;
                }

                if (extension == ".pdf")
                {
                    return bytesRead >= 5 &&
                        header[0] == 0x25 &&
                        header[1] == 0x50 &&
                        header[2] == 0x44 &&
                        header[3] == 0x46 &&
                        header[4] == 0x2D;
                }

                return false;
            }
            finally
            {
                stream.Position = originalPosition;
            }
        }

        // ============================================================
        // GENERATE APPLICATION ID
        // ============================================================

        private string GenerateApplicationId()
        {
            return
                "GPRS-" +
                DateTime.Now.ToString("yyyyMMdd") +
                "-" +
                Guid.NewGuid()
                    .ToString("N")
                    .Substring(0, 6)
                    .ToUpperInvariant();
        }

        // ============================================================
        // SAVE APPLICATION DOCUMENTS
        // ============================================================

        private string SaveApplicationDocuments(
            string applicationId,
            HttpPostedFile passportPhoto,
            HttpPostedFile ghanaCardFront,
            HttpPostedFile ghanaCardBack,
            HttpPostedFile identityDocument,
            HttpPostedFile identityDocumentBack)
        {
            string rootFolder =
                Server.MapPath(
                    "~/App_Data/Applications/"
                );

            if (string.IsNullOrWhiteSpace(rootFolder))
            {
                throw new Exception(
                    "Application storage folder could not be located."
                );
            }

            string applicationFolder =
                Path.Combine(
                    rootFolder,
                    MakeSafeFileName(applicationId)
                );

            Directory.CreateDirectory(
                applicationFolder
            );

            SaveUploadedFile(
                passportPhoto,
                applicationFolder,
                "PassportPhoto"
            );

            if (ghanaCardFront != null &&
                ghanaCardFront.ContentLength > 0)
            {
                SaveUploadedFile(
                    ghanaCardFront,
                    applicationFolder,
                    "GhanaCardFront"
                );
            }

            if (ghanaCardBack != null &&
                ghanaCardBack.ContentLength > 0)
            {
                SaveUploadedFile(
                    ghanaCardBack,
                    applicationFolder,
                    "GhanaCardBack"
                );
            }

            if (identityDocument != null &&
                identityDocument.ContentLength > 0)
            {
                SaveUploadedFile(
                    identityDocument,
                    applicationFolder,
                    "IdentityDocument"
                );
            }

            if (identityDocumentBack != null && identityDocumentBack.ContentLength > 0)
                SaveUploadedFile(identityDocumentBack, applicationFolder, "IdentityDocumentBack");

            return applicationFolder;
        }

        private void RecordApplicationSubmission(string applicationId)
        {
            int userId;
            if (!int.TryParse(
                    Convert.ToString(Session["UserID"]),
                    out userId) ||
                userId <= 0)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Application submission audit could not be associated with an account.");
                return;
            }

            const string sql = @"
                INSERT INTO account_audit_logs
                    (ActorUserID, TargetUserID, ActionType, Details)
                VALUES
                    (@UserID, @UserID, 'APPLICATION_SUBMITTED', @Details);";

            try
            {
                using (MySqlConnection connection =
                       new MySqlConnection(connStr))
                {
                    connection.Open();
                    using (MySqlCommand command =
                           new MySqlCommand(sql, connection))
                    {
                        command.Parameters.Add(
                            "@UserID",
                            MySqlDbType.Int32).Value = userId;
                        command.Parameters.Add(
                            "@Details",
                            MySqlDbType.Text).Value =
                            "Application " + applicationId + " submitted.";
                        command.ExecuteNonQuery();
                    }
                }
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Application submission audit could not be written (MySQL error {0}).",
                    ex.Number);
            }
        }

        // ============================================================
        // SAVE ONE FILE
        // ============================================================

        private void SaveUploadedFile(
            HttpPostedFile file,
            string folder,
            string filePrefix)
        {
            if (file == null ||
                file.ContentLength <= 0)
            {
                return;
            }

            string extension =
                Path.GetExtension(file.FileName)
                    .ToLowerInvariant();

            string safeFileName =
                filePrefix +
                extension;

            string fullPath =
                Path.Combine(
                    folder,
                    safeFileName
                );

            file.SaveAs(fullPath);
        }

        // ============================================================
        // SAFE FILE NAME
        // ============================================================

        private string MakeSafeFileName(string value)
        {
            foreach (char character in
                Path.GetInvalidFileNameChars())
            {
                value =
                    value.Replace(
                        character.ToString(),
                        "_"
                    );
            }

            return value;
        }

        // ============================================================
        // SHOW ERROR
        // ============================================================

        private void ShowError(string message)
        {
            if (errorMessage != null)
            {
                errorMessage.InnerHtml =
                    HttpUtility.HtmlEncode(message)
                    .Replace(
                        Environment.NewLine,
                        "<br />"
                    );

                errorMessage.Attributes["class"] =
                    "message-box message-error show";

                errorMessage.Style["display"] =
                    "block";
            }
            else
            {
                string safeMessage =
                    HttpUtility.JavaScriptStringEncode(
                        message
                    );

                ClientScript.RegisterStartupScript(
                    GetType(),
                    "ApplicationError",
                    "alert('" +
                    safeMessage +
                    "');",
                    true
                );
            }
        }

        // ============================================================
        // SHOW SUCCESS
        // ============================================================

        private void ShowSuccess(string applicationId)
        {
            if (applicationFormContainer != null)
            {
                applicationFormContainer.Visible =
                    false;
            }

            if (errorMessage != null)
            {
                errorMessage.Attributes["class"] =
                    "message-box message-error";

                errorMessage.InnerHtml = "";
                errorMessage.Style["display"] =
                    "none";
            }

            if (successPanel != null)
            {
                successPanel.Attributes["class"] =
                    "success-panel show";

                successPanel.Style["display"] =
                    "block";
            }

            if (generatedApplicationId != null)
            {
                generatedApplicationId.InnerText =
                    applicationId;
            }

            // Show the new service area for the newly submitted application.
            LoadCitizenServices(applicationId);
        }

        // ============================================================
        // PAYMENT / CERTIFICATE SERVICE WORKFLOW
        // ============================================================

        private void LoadCitizenServices()
        {
            string applicationId = GetLatestCitizenApplicationId();

            if (!string.IsNullOrWhiteSpace(applicationId))
            {
                LoadCitizenServices(applicationId);
            }
            else
            {
                HideCitizenServices();
            }
        }

        private void LoadCitizenServices(string applicationId)
        {
            if (string.IsNullOrWhiteSpace(applicationId))
            {
                HideCitizenServices();
                return;
            }

            if (pnlCitizenServices == null)
            {
                return;
            }

            string status = GetApplicationStatusForCitizen(applicationId);

            if (string.IsNullOrWhiteSpace(status))
            {
                HideCitizenServices();
                return;
            }

            if (lblServiceApplicationId != null)
            {
                lblServiceApplicationId.InnerText = applicationId;
            }

            pnlCitizenServices.Visible = true;
            if (lblPaymentFee != null)
                lblPaymentFee.InnerText = Helpers.HubtelPaymentService.Fee.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture);

            bool approved =
                status.Equals(
                    "Approved",
                    StringComparison.OrdinalIgnoreCase
                );

            bool paymentVerified =
                IsPaymentVerified(applicationId);

            if (lblApplicationServiceStatus != null)
            {
                lblApplicationServiceStatus.InnerText =
                    status;
            }

            if (pnlPaymentService != null)
            {
                pnlPaymentService.Visible = true;
            }

            if (pnlCertificateService != null)
            {
                pnlCertificateService.Visible = true;
            }

            if (btnPayNow != null)
            {
                btnPayNow.Disabled = !approved || paymentVerified;
            }

            if (ddlPaymentMethod != null)
            {
                ddlPaymentMethod.Disabled =
                    !approved || paymentVerified;
            }

            if (lblPaymentStatus != null)
            {
                if (paymentVerified)
                {
                    lblPaymentStatus.InnerText =
                        "Payment verified";
                }
                else if (approved)
                {
                    lblPaymentStatus.InnerText =
                        "Payment available";
                }
                else
                {
                    lblPaymentStatus.InnerText =
                        "Locked - available after approval";
                }
            }

            if (lblPaymentDetails != null)
            {
                PaymentDetails payment =
                    GetPaymentDetails(applicationId);

                if (payment != null)
                {
                    if (btnPayNow != null && !paymentVerified)
                        btnPayNow.InnerText = payment.PaymentState == 2 ? "Retry payment" : "Check payment status";
                    if (ddlPaymentMethod != null && payment.PaymentState == 0 && !paymentVerified)
                        ddlPaymentMethod.Disabled = true;
                    if (lblPaymentStatus != null && !paymentVerified && approved)
                        lblPaymentStatus.InnerText = payment.PaymentState == 2 ? "Payment failed or cancelled" : "Awaiting Hubtel confirmation";
                    lblPaymentDetails.InnerText =
                        "Transaction: " +
                        payment.TransactionID +
                        " | Amount: GHS " +
                        payment.AmountPaid.ToString("0.00") +
                        " | " +
                        payment.PaymentDate.ToString("dd MMM yyyy HH:mm");
                }
                else
                {
                    lblPaymentDetails.InnerText = "";
                }
            }

            if (lblCertificateStatus != null)
            {
                if (paymentVerified)
                {
                    lblCertificateStatus.InnerText =
                        "Certificate available";
                }
                else
                {
                    lblCertificateStatus.InnerText =
                        "Locked - available after payment verification";
                }
            }

            if (btnCertificate != null)
            {
                btnCertificate.Disabled = !paymentVerified;
            }

            if (lblCertificateLink != null)
            {
                lblCertificateLink.HRef =
                    paymentVerified
                        ? GetCertificateUrl(applicationId)
                        : "#";

                lblCertificateLink.Attributes["aria-disabled"] =
                    paymentVerified ? "false" : "true";

                if (!paymentVerified)
                {
                    lblCertificateLink.Attributes["onclick"] =
                        "return false;";
                }
                else
                {
                    lblCertificateLink.Attributes.Remove("onclick");
                }
            }

            ApplyServiceCardClasses(
                approved,
                paymentVerified
            );
        }

        private void HideCitizenServices()
        {
            if (pnlCitizenServices != null)
            {
                pnlCitizenServices.Visible = false;
            }
        }

        private void ApplyServiceCardClasses(
            bool approved,
            bool paymentVerified)
        {
            if (pnlPaymentService != null)
            {
                pnlPaymentService.Attributes["class"] =
                    approved
                        ? "service-card unlocked"
                        : "service-card locked";

                if (paymentVerified)
                {
                    pnlPaymentService.Attributes["class"] =
                        "service-card paid";
                }
            }

            if (pnlCertificateService != null)
            {
                pnlCertificateService.Attributes["class"] =
                    paymentVerified
                        ? "service-card unlocked"
                        : "service-card locked";
            }
        }

        // ============================================================
        // PAYMENT BUTTON
        // ============================================================

        protected void btnPayNow_Click(
            object sender,
            EventArgs e)
        {
            try
            {
                if (!IsCitizenRole())
                {
                    ShowServiceError(
                        "Only a citizen account can make an application payment."
                    );

                    return;
                }

                string applicationId =
                    GetLatestCitizenApplicationId();

                if (string.IsNullOrWhiteSpace(applicationId))
                {
                    ShowServiceError(
                        "No application was found for your account."
                    );

                    return;
                }

                string status =
                    GetApplicationStatusForCitizen(applicationId);

                if (!status.Equals(
                    "Approved",
                    StringComparison.OrdinalIgnoreCase))
                {
                    ShowServiceError(
                        "Payment is locked until your application has been approved."
                    );

                    LoadCitizenServices(applicationId);
                    return;
                }

                if (IsPaymentVerified(applicationId))
                {
                    ShowServiceError(
                        "Payment has already been completed and verified for this application."
                    );

                    LoadCitizenServices(applicationId);
                    return;
                }

                string paymentMethod =
                    ddlPaymentMethod == null
                        ? "MoMo"
                        : ddlPaymentMethod.Value;

                if (string.IsNullOrWhiteSpace(paymentMethod))
                {
                    paymentMethod = "MTN MoMo";
                }

                if (!IsAllowedPaymentMethod(paymentMethod))
                {
                    ShowServiceError(
                        "Please select MTN MoMo, Telecel Cash, or AT Money."
                    );

                    return;
                }

                string paymentMessage = Helpers.HubtelPaymentService.BeginOrCheckPayment(
                    applicationId,
                    GetSessionEmail(),
                    paymentMethod
                );

                LoadCitizenServices(applicationId);

                ShowServiceSuccess(paymentMessage);
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Hubtel payment operation failed (MySQL error {0}).",
                    ex.Number);
                ShowServiceError("Payment could not be completed. Please try again later.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Hubtel payment operation failed ({0}).",
                    ex.GetType().Name);
                LoadCitizenServices();
                ShowServiceError(ex is ConfigurationErrorsException || ex is InvalidOperationException || ex is ArgumentException
                    ? ex.Message
                    : "Payment could not be confirmed. Check its status before attempting another payment.");
            }
        }

        // ============================================================
        // CERTIFICATE BUTTON
        // ============================================================

        protected void btnCertificate_Click(
            object sender,
            EventArgs e)
        {
            try
            {
                if (!IsCitizenRole())
                {
                    ShowServiceError(
                        "Only a citizen account can access the certificate service."
                    );

                    return;
                }

                string applicationId =
                    GetLatestCitizenApplicationId();

                if (string.IsNullOrWhiteSpace(applicationId))
                {
                    ShowServiceError(
                        "No application was found for your account."
                    );

                    return;
                }

                if (!IsPaymentVerified(applicationId))
                {
                    ShowServiceError(
                        "The certificate option is locked until your payment has been verified."
                    );

                    LoadCitizenServices(applicationId);
                    return;
                }

                // Create the certificate record only once.
                EnsureCertificateRecord(applicationId);

                Response.Redirect(
                    GetCertificateUrl(applicationId),
                    false
                );

                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Certificate page request failed ({0}).",
                    ex.GetType().Name);
                ShowServiceError("The certificate page could not be opened. Please try again.");
            }
        }

        // ============================================================
        // PAYMENT STATUS
        // ============================================================

        private bool IsPaymentVerified(string applicationId)
        {
            int internalApplicationId =
                GetInternalApplicationId(applicationId);

            if (internalApplicationId <= 0)
            {
                return false;
            }

            const string sql = @"
                SELECT COUNT(*)
                FROM payments
                WHERE ApplicationID = @ApplicationID
                  AND PaymentVerified = 1
                  AND TransactionID LIKE 'HBT-%';";

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
                    ).Value = internalApplicationId;

                    return Convert.ToInt32(
                        command.ExecuteScalar()
                    ) > 0;
                }
            }
        }

        private bool IsPaymentUnlocked(string applicationId)
        {
            string status =
                GetApplicationStatusForCitizen(applicationId);

            return status.Equals(
                "Approved",
                StringComparison.OrdinalIgnoreCase
            );
        }

        // ============================================================
        // PAYMENT DETAILS
        // ============================================================

        private PaymentDetails GetPaymentDetails(
            string applicationId)
        {
            int internalApplicationId =
                GetInternalApplicationId(applicationId);

            if (internalApplicationId <= 0)
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
                    ).Value = internalApplicationId;

                    using (MySqlDataReader reader =
                        command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        PaymentDetails details =
                            new PaymentDetails();

                        details.PaymentMethod =
                            reader["PaymentMethod"] == DBNull.Value
                                ? ""
                                : Convert.ToString(
                                    reader["PaymentMethod"]
                                );

                        details.TransactionID =
                            reader["TransactionID"] == DBNull.Value
                                ? ""
                                : Convert.ToString(
                                    reader["TransactionID"]
                                );

                        details.AmountPaid =
                            reader["AmountPaid"] == DBNull.Value
                                ? 0m
                                : Convert.ToDecimal(
                                    reader["AmountPaid"]
                                );

                        details.PaymentDate =
                            reader["PaymentDate"] == DBNull.Value
                                ? DateTime.MinValue
                                : Convert.ToDateTime(
                                    reader["PaymentDate"]
                                );

                        details.PaymentVerified =
                            reader["PaymentVerified"] != DBNull.Value &&
                            Convert.ToInt32(
                                reader["PaymentVerified"]
                            ) == 1;
                        details.PaymentState = Convert.ToInt32(reader["PaymentVerified"]);

                        return details;
                    }
                }
            }
        }

        // ============================================================
        // CERTIFICATE URL
        // ============================================================

        private string GetCertificateUrl(string applicationId)
        {
            return
                ResolveUrl(
                    "~/VettingDetails.aspx?applicationId=" +
                    HttpUtility.UrlEncode(applicationId)
                );
        }

        // ============================================================
        // CREATE CERTIFICATE RECORD
        // ============================================================

        private string EnsureCertificateRecord(string applicationId)
        {
            if (string.IsNullOrWhiteSpace(applicationId))
            {
                throw new Exception(
                    "The application reference is required."
                );
            }

            int internalApplicationId =
                GetInternalApplicationId(applicationId);

            if (internalApplicationId <= 0)
            {
                throw new Exception(
                    "The application could not be located."
                );
            }

            // Make sure the certificate can only be created after payment.
            if (!IsPaymentVerified(applicationId))
            {
                throw new Exception(
                    "The certificate cannot be issued until payment has been verified."
                );
            }

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
                    connection, workflowTransaction, Context, applicationId);
                using (MySqlCommand findCommand =
                    new MySqlCommand(findSql, connection, workflowTransaction))
                {
                    findCommand.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationId;

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
                    new MySqlCommand(insertSql, connection))
                {
                    insertCommand.Parameters.Add(
                        "@ApplicationReference",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationId;

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

                    insertCommand.Transaction = workflowTransaction;
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
                    "Application " + applicationId + "; certificate " + certificateReference);
                workflowTransaction.Commit();
                return certificateReference;
                }
            }
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

        // ============================================================
        // CITIZEN APPLICATION LOOKUP
        // ============================================================

        private string GetLatestCitizenApplicationId()
        {
            if (!IsCitizenRole())
            {
                return null;
            }

            string email =
                GetSessionEmail();

            if (string.IsNullOrWhiteSpace(email))
            {
                return null;
            }

            const string sql = @"
                SELECT application_id
                FROM applications
                WHERE Email = @Email
                ORDER BY DateSubmitted DESC, ApplicationID DESC
                LIMIT 1;";

            using (MySqlConnection connection =
                new MySqlConnection(connStr))
            {
                connection.Open();

                using (MySqlCommand command =
                    new MySqlCommand(sql, connection))
                {
                    command.Parameters.Add(
                        "@Email",
                        MySqlDbType.VarChar,
                        255
                    ).Value = email;

                    object result =
                        command.ExecuteScalar();

                    if (result == null ||
                        result == DBNull.Value)
                    {
                        return null;
                    }

                    return Convert.ToString(result);
                }
            }
        }

        private string GetApplicationStatusForCitizen(
            string applicationId)
        {
            if (!IsCitizenRole())
            {
                return string.Empty;
            }

            string email =
                GetSessionEmail();

            if (string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(applicationId))
            {
                return string.Empty;
            }

            const string sql = @"
                SELECT Status
                FROM applications
                WHERE application_id = @ApplicationID
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
                        "@ApplicationID",
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationId;

                    command.Parameters.Add(
                        "@Email",
                        MySqlDbType.VarChar,
                        255
                    ).Value = email;

                    object result =
                        command.ExecuteScalar();

                    if (result == null ||
                        result == DBNull.Value)
                    {
                        return string.Empty;
                    }

                    return Convert.ToString(result).Trim();
                }
            }
        }

        private int GetInternalApplicationId(
            string applicationId)
        {
            if (string.IsNullOrWhiteSpace(applicationId))
            {
                return 0;
            }

            const string sql = @"
                SELECT ApplicationID
                FROM applications
                WHERE application_id = @ApplicationID
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
                        MySqlDbType.VarChar,
                        50
                    ).Value = applicationId;

                    object result =
                        command.ExecuteScalar();

                    if (result == null ||
                        result == DBNull.Value)
                    {
                        return 0;
                    }

                    return Convert.ToInt32(result);
                }
            }
        }

        // ============================================================
        // SESSION / ROLE HELPERS
        // ============================================================

        private bool IsCitizenRole()
        {
            string role =
                Convert.ToString(
                    Session["Role"]
                );

            return
                role.Equals(
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

        private bool IsAllowedPaymentMethod(
            string paymentMethod)
        {
            return
                paymentMethod.Equals(
                    "MTN MoMo",
                    StringComparison.OrdinalIgnoreCase
                ) ||
                paymentMethod.Equals(
                    "Telecel Cash",
                    StringComparison.OrdinalIgnoreCase
                ) ||
                paymentMethod.Equals(
                    "AT Money",
                    StringComparison.OrdinalIgnoreCase
                ) ||
                false;
        }

        // ============================================================
        // SERVICE MESSAGES
        // ============================================================

        private void ShowServiceError(string message)
        {
            if (errorMessage != null)
            {
                errorMessage.InnerHtml =
                    HttpUtility.HtmlEncode(message);

                errorMessage.Attributes["class"] =
                    "message-box message-error show";

                errorMessage.Style["display"] =
                    "block";
            }
        }

        private void ShowServiceSuccess(string message)
        {
            if (errorMessage != null)
            {
                errorMessage.InnerHtml =
                    HttpUtility.HtmlEncode(message);

                errorMessage.Attributes["class"] =
                    "message-box message-success show";

                errorMessage.Style["display"] =
                    "block";
            }
        }

        // ============================================================
        // PAYMENT DETAILS MODEL
        // ============================================================

        private sealed class PaymentDetails
        {
            public string PaymentMethod { get; set; }
            public string TransactionID { get; set; }
            public decimal AmountPaid { get; set; }
            public DateTime PaymentDate { get; set; }
            public bool PaymentVerified { get; set; }
            public int PaymentState { get; set; }
        }

        // ============================================================
        // FIND SERVER CONTROL RECURSIVELY
        // ============================================================

        private Control FindControlRecursive(
            Control root,
            string id)
        {
            if (root == null)
            {
                return null;
            }

            if (root.ID == id)
            {
                return root;
            }

            foreach (Control child in root.Controls)
            {
                Control result =
                    FindControlRecursive(
                        child,
                        id
                    );

                if (result != null)
                {
                    return result;
                }
            }

            return null;
        }
    }
}
