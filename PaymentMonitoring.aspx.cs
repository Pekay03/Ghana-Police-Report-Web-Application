using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PoliceBackgroundCheckSystem
{
    public partial class PaymentMonitoring : Page
    {
        private readonly string connStr =
            ConfigurationManager
                .ConnectionStrings["PoliceReportDB"]
                .ConnectionString;

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
                LoadPayments();
            }
        }

        private bool IsAdmin()
        {
            string role = Convert.ToString(Session["Role"]);

            if (string.IsNullOrWhiteSpace(role))
            {
                return false;
            }

            role = role.Trim();

            return role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                || role.Equals("Administrator", StringComparison.OrdinalIgnoreCase)
                || role.Equals("SystemAdmin", StringComparison.OrdinalIgnoreCase);
        }

        private void LoadDashboard()
        {
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    LoadTotalAmount(conn);
                    LoadTotalPayments(conn);
                    LoadVerifiedPayments(conn);
                    LoadUnverifiedPayments(conn);
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private void LoadTotalAmount(MySqlConnection conn)
        {
            const string sql = @"
                SELECT COALESCE(SUM(AmountPaid), 0)
                FROM payments WHERE PaymentVerified=1 AND TransactionID LIKE 'HBT-%';";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                object result = cmd.ExecuteScalar();

                decimal totalAmount = 0m;

                if (result != null && result != DBNull.Value)
                {
                    totalAmount = Convert.ToDecimal(result);
                }

                lblTotalAmount.Text = totalAmount.ToString("N2");
            }
        }

        private void LoadTotalPayments(MySqlConnection conn)
        {
            const string sql = @"
                SELECT COUNT(*)
                FROM payments;";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                object result = cmd.ExecuteScalar();

                int totalPayments = 0;

                if (result != null && result != DBNull.Value)
                {
                    totalPayments = Convert.ToInt32(result);
                }

                lblTotalPayments.Text = totalPayments.ToString();
            }
        }

        private void LoadVerifiedPayments(MySqlConnection conn)
        {
            const string sql = @"
                SELECT COUNT(*)
                FROM payments
                WHERE PaymentVerified = 1 AND TransactionID LIKE 'HBT-%';";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                object result = cmd.ExecuteScalar();

                int verifiedPayments = 0;

                if (result != null && result != DBNull.Value)
                {
                    verifiedPayments = Convert.ToInt32(result);
                }

                lblVerifiedPayments.Text = verifiedPayments.ToString();
            }
        }

        private void LoadUnverifiedPayments(MySqlConnection conn)
        {
            const string sql = @"
                SELECT COUNT(*)
                FROM payments
                WHERE PaymentVerified <> 1 OR TransactionID NOT LIKE 'HBT-%';";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                object result = cmd.ExecuteScalar();

                int unverifiedPayments = 0;

                if (result != null && result != DBNull.Value)
                {
                    unverifiedPayments = Convert.ToInt32(result);
                }

                lblUnverifiedPayments.Text = unverifiedPayments.ToString();
            }
        }

        private void LoadPayments()
        {
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    string sql = @"
                        SELECT
                            p.PaymentID,
                            a.application_id,
                            a.FullName,
                            p.PaymentMethod,
                            p.TransactionID,
                            p.AmountPaid,
                            p.PaymentDate,
                            CASE WHEN p.TransactionID LIKE 'HBT-%' THEN p.PaymentVerified ELSE 0 END AS PaymentVerified
                        FROM payments p
                        INNER JOIN applications a
                            ON p.ApplicationID = a.ApplicationID
                        WHERE 1 = 1";

                    string search = txtSearch.Text.Trim();
                    string method = ddlMethod.SelectedValue;
                    string verification = ddlVerification.SelectedValue;

                    if (!string.IsNullOrWhiteSpace(search))
                    {
                        sql += @"
                            AND (
                                a.application_id LIKE @Search
                                OR a.FullName LIKE @Search
                                OR p.TransactionID LIKE @Search
                            )";
                    }

                    if (!string.IsNullOrWhiteSpace(method))
                    {
                        sql += @"
                            AND p.PaymentMethod = @PaymentMethod";
                    }

                    if (!string.IsNullOrWhiteSpace(verification))
                    {
                        sql += @"
                            AND ((@PaymentVerified=1 AND p.PaymentVerified=1 AND p.TransactionID LIKE 'HBT-%')
                              OR (@PaymentVerified=0 AND (p.PaymentVerified<>1 OR p.TransactionID NOT LIKE 'HBT-%')))";
                    }

                    sql += @"
                        ORDER BY
                            p.PaymentDate DESC,
                            p.PaymentID DESC;";

                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(search))
                        {
                            cmd.Parameters.AddWithValue(
                                "@Search",
                                "%" + search + "%");
                        }

                        if (!string.IsNullOrWhiteSpace(method))
                        {
                            cmd.Parameters.AddWithValue(
                                "@PaymentMethod",
                                method);
                        }

                        if (!string.IsNullOrWhiteSpace(verification))
                        {
                            cmd.Parameters.AddWithValue(
                                "@PaymentVerified",
                                Convert.ToInt32(verification));
                        }

                        using (MySqlDataAdapter adapter =
                               new MySqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();

                            adapter.Fill(dt);

                            gvPayments.DataSource = dt;
                            gvPayments.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            gvPayments.PageIndex = 0;

            LoadDashboard();
            LoadPayments();
        }

        protected void gvPayments_PageIndexChanging(
            object sender,
            GridViewPageEventArgs e)
        {
            gvPayments.PageIndex = e.NewPageIndex;

            LoadPayments();
        }

        // ------------------------------------------------------------
        // PAYMENT VERIFICATION DISPLAY HELPERS
        // These methods are called directly from PaymentMonitoring.aspx
        // ------------------------------------------------------------

        public string GetVerificationText(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return "Unverified";
            }

            int numericValue;

            if (int.TryParse(value.ToString(), out numericValue))
            {
                if (numericValue == 2) return "Failed/cancelled";
                return numericValue == 1
                    ? "Verified"
                    : "Unverified";
            }

            bool booleanValue;

            if (bool.TryParse(value.ToString(), out booleanValue))
            {
                return booleanValue
                    ? "Verified"
                    : "Unverified";
            }

            return "Unverified";
        }

        public string GetVerificationCss(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return "pm-pill unverified";
            }

            int numericValue;

            if (int.TryParse(value.ToString(), out numericValue))
            {
                return numericValue == 1
                    ? "pm-pill verified"
                    : "pm-pill unverified";
            }

            bool booleanValue;

            if (bool.TryParse(value.ToString(), out booleanValue))
            {
                return booleanValue
                    ? "pm-pill verified"
                    : "pm-pill unverified";
            }

            return "pm-pill unverified";
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}