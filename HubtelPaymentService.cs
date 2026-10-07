using System;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PoliceBackgroundCheckSystem.Helpers
{
    public static class HubtelPaymentService
    {
        // Existing integer column: 0 = unresolved, 1 = provider-confirmed paid,
        // 2 = definitively failed/cancelled. No schema migration is required.
        public const string ReferencePrefix = "HBT-";
        private static string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString; }
        }
        public static decimal Fee
        {
            get
            {
                decimal value;
                if (!Decimal.TryParse(Setting("HUBTEL_PAYMENT_FEE", "HubtelPaymentFee", "150.00"),
                    NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out value) ||
                    value <= 0 || value > 99999999.99m || Decimal.Round(value, 2) != value)
                    throw new ConfigurationErrorsException("The service payment fee must be a positive GHS amount with at most two decimal places.");
                return value;
            }
        }

        public static string BeginOrCheckPayment(string applicationId, string email, string method)
        {
            string channel = Channel(method);
            string reference = null;
            decimal amount = 0;
            string name = null, phone = null;
            bool created = false;
            // Serialise reservation on the application's row, including requests
            // arriving from different sessions. Never create a second unresolved debit.
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                using (MySqlTransaction transaction = connection.BeginTransaction())
                {
                    int applicationKey;
                    using (MySqlCommand command = new MySqlCommand(@"
                        SELECT a.ApplicationID, a.Status, a.FullName, u.Phone
                        FROM applications a JOIN users u ON u.Email=a.Email
                        WHERE a.application_id=@id AND a.Email=@email AND u.IsActive=1
                        LIMIT 1 FOR UPDATE;", connection, transaction))
                    {
                        command.Parameters.AddWithValue("@id", applicationId);
                        command.Parameters.AddWithValue("@email", email);
                        using (MySqlDataReader reader = command.ExecuteReader())
                        {
                            if (!reader.Read() || !String.Equals(Convert.ToString(reader["Status"]), "Approved", StringComparison.OrdinalIgnoreCase))
                                throw new InvalidOperationException("Payment requires your own approved application.");
                            applicationKey = Convert.ToInt32(reader["ApplicationID"]);
                            name = Convert.ToString(reader["FullName"]);
                            phone = Convert.ToString(reader["Phone"]);
                        }
                    }
                    using (MySqlCommand command = new MySqlCommand(@"
                        SELECT TransactionID, AmountPaid, PaymentVerified FROM payments
                        WHERE ApplicationID=@id AND TransactionID LIKE 'HBT-%'
                        ORDER BY PaymentID DESC LIMIT 1;", connection, transaction))
                    {
                        command.Parameters.AddWithValue("@id", applicationKey);
                        using (MySqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int state = Convert.ToInt32(reader["PaymentVerified"]);
                                if (state == 1)
                                    throw new InvalidOperationException("A Hubtel-confirmed payment is already recorded.");
                                if (state == 0)
                                {
                                    reference = Convert.ToString(reader["TransactionID"]);
                                    amount = Convert.ToDecimal(reader["AmountPaid"]);
                                }
                            }
                        }
                    }
                    if (reference == null)
                    {
                        ValidateNewPaymentConfiguration();
                        phone = HubtelSmsService.ToE164GhanaPhone(phone).Substring(1);
                        amount = Fee;
                        reference = ReferencePrefix + Guid.NewGuid().ToString("N");
                        using (MySqlCommand command = new MySqlCommand(@"
                            INSERT INTO payments
                            (ApplicationID, PaymentMethod, TransactionID, AmountPaid, PaymentDate, PaymentVerified)
                            VALUES (@id,@method,@ref,@amount,NOW(),0);", connection, transaction))
                        {
                            command.Parameters.AddWithValue("@id", applicationKey);
                            command.Parameters.AddWithValue("@method", method);
                            command.Parameters.AddWithValue("@ref", reference);
                            command.Parameters.AddWithValue("@amount", amount);
                            command.ExecuteNonQuery();
                        }
                        created = true;
                    }
                    transaction.Commit();
                }
            }
            if (!created)
            {
                string state = RefreshPayment(reference);
                if (state == "Paid") return "Hubtel has confirmed your payment. The certificate option is now available.";
                if (state == "Failed")
                    throw new InvalidOperationException("Hubtel reports that the payment failed or was cancelled. No payment is verified. Select Retry payment to make a new request.");
                return "Payment is awaiting Hubtel confirmation. Complete the prompt on your registered mobile-money wallet, then select Check payment status. Do not pay again.";
            }
            try
            {
                JObject response = RequestJson(new Uri("https://rmp.hubtel.com/merchantaccount/merchants/" +
                    Uri.EscapeDataString(Merchant()) + "/receive/mobilemoney"), "POST", new
                {
                    CustomerName = name,
                    CustomerMsisdn = phone,
                    CustomerEmail = email,
                    Channel = channel,
                    Amount = amount.ToString("0.00", CultureInfo.InvariantCulture),
                    PrimaryCallbackUrl = new Uri(PublicBase(), "HubtelPaymentCallback.ashx").AbsoluteUri,
                    Description = "Police background-check service: " + applicationId,
                    ClientReference = reference
                });
                string code = Text(response, "ResponseCode");
                if (code != "0000" && code != "0001")
                    throw new RequestRejectedException("Hubtel did not accept the wallet request (provider code " + SafeCode(code) + "). Check the merchant account, balance, channel permissions and registered wallet.");
                JObject data = Object(response, "Data");
                string echoed = data == null ? "" : Text(data, "ClientReference");
                if (echoed.Length > 0 && echoed != reference)
                    throw new InvalidOperationException("Hubtel returned a different payment reference. Payment remains unverified; check its status before retrying.");
                return "Hubtel accepted the payment request. Approve the prompt on your registered " +
                    method + " wallet. This is not yet a verified payment. Select Check payment status after completing it.";
            }
            catch (RequestRejectedException)
            {
                SetState(reference, 2);
                throw;
            }
            // Transport errors and timeouts are uncertain outcomes: keep the
            // reservation unresolved, rather than risking another wallet debit.
        }

        public static string RefreshPayment(string reference)
        {
            if (!Regex.IsMatch(reference ?? "", @"^HBT-[a-f0-9]{32}$"))
                throw new ArgumentException("The payment reference is invalid.");
            decimal expectedAmount;
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                using (MySqlCommand command = new MySqlCommand(
                    "SELECT AmountPaid, PaymentVerified FROM payments WHERE TransactionID=@ref LIMIT 1;", connection))
                {
                    command.Parameters.AddWithValue("@ref", reference);
                    using (MySqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read()) throw new ArgumentException("No payment matches this reference.");
                        expectedAmount = Convert.ToDecimal(reader["AmountPaid"]);
                        int state = Convert.ToInt32(reader["PaymentVerified"]);
                        if (state == 1) return "Paid"; // Idempotent callback.
                        if (state == 2) return "Failed";
                    }
                }
            }
            JObject response = RequestJson(new Uri("https://api-txnstatus.hubtel.com/transactions/" +
                Uri.EscapeDataString(Merchant()) + "/status?clientReference=" + Uri.EscapeDataString(reference)), "GET", null);
            if (Text(response, "ResponseCode") != "0000")
                throw new InvalidOperationException("Hubtel cannot yet confirm the transaction (provider code " +
                    SafeCode(Text(response, "ResponseCode")) + "). It remains unverified. Do not submit another payment.");
            JObject data = Object(response, "Data");
            if (data == null || Text(data, "ClientReference") != reference)
                throw new InvalidOperationException("Hubtel's status response does not match the stored payment reference.");
            string status = Text(data, "Status");
            if (String.Equals(status, "Paid", StringComparison.OrdinalIgnoreCase))
            {
                string providerId = ValidatePaidData(data, reference, expectedAmount);
                MarkPaid(reference, providerId, expectedAmount);
                return "Paid";
            }
            if (String.Equals(status, "Failed", StringComparison.OrdinalIgnoreCase) ||
                String.Equals(status, "Cancelled", StringComparison.OrdinalIgnoreCase) ||
                String.Equals(status, "Expired", StringComparison.OrdinalIgnoreCase) ||
                String.Equals(status, "Declined", StringComparison.OrdinalIgnoreCase) ||
                String.Equals(status, "Refunded", StringComparison.OrdinalIgnoreCase))
            {
                SetState(reference, 2);
                return "Failed";
            }
            // "Unpaid" is not proof of a terminal failure.
            return "Pending";
        }

        private static string ValidatePaidData(JObject data, string reference, decimal expectedAmount)
        {
            decimal providerAmount;
            if (data == null || Text(data, "ClientReference") != reference ||
                !String.Equals(Text(data, "Status"), "Paid", StringComparison.OrdinalIgnoreCase) ||
                !Decimal.TryParse(Text(data, "Amount"), NumberStyles.Number, CultureInfo.InvariantCulture, out providerAmount) ||
                providerAmount != expectedAmount ||
                !String.Equals(Text(data, "CurrencyCode"), "GHS", StringComparison.OrdinalIgnoreCase) ||
                !Regex.IsMatch(Text(data, "TransactionId"), @"^[A-Za-z0-9_-]{1,100}$"))
                throw new InvalidOperationException("Hubtel's payment status, reference, amount, currency or transaction identity does not match this payment. It remains unverified.");
            return Text(data, "TransactionId");
        }

        private static void MarkPaid(string reference, string providerId, decimal amount)
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                using (MySqlTransaction transaction = connection.BeginTransaction())
                {
                    using (MySqlCommand command = new MySqlCommand(@"
                        UPDATE payments SET PaymentVerified=1, PaymentDate=NOW()
                        WHERE TransactionID=@ref AND PaymentVerified=0 AND AmountPaid=@amount;", connection, transaction))
                    {
                        command.Parameters.AddWithValue("@ref", reference);
                        command.Parameters.AddWithValue("@amount", amount);
                        int changed = command.ExecuteNonQuery();
                        if (changed == 1)
                        {
                            // Persist the external provider ID alongside the client
                            // reference in the existing audit trail, without a migration.
                            using (MySqlCommand audit = new MySqlCommand(@"
                                INSERT INTO account_audit_logs
                                (ActorUserID, TargetUserID, ActionType, Details, CreatedAt)
                                SELECT NULL,u.UserID,'PAYMENT_VERIFIED',@detail,NOW()
                                FROM payments p
                                JOIN applications a ON a.ApplicationID=p.ApplicationID
                                JOIN users u ON u.Email=a.Email
                                WHERE p.TransactionID=@ref LIMIT 1;", connection, transaction))
                            {
                                audit.Parameters.AddWithValue("@ref", reference);
                                audit.Parameters.AddWithValue("@detail", "Payment " + reference + "; Hubtel transaction " + providerId +
                                    "; GHS " + amount.ToString("0.00", CultureInfo.InvariantCulture) +
                                    "; verified using authenticated transaction-status API.");
                                audit.ExecuteNonQuery();
                            }
                        }
                    }
                    transaction.Commit();
                }
            }
        }

        private static void SetState(string reference, int state)
        {
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                connection.Open();
                using (MySqlCommand command = new MySqlCommand(
                    "UPDATE payments SET PaymentVerified=@state WHERE TransactionID=@ref AND PaymentVerified=0;", connection))
                {
                    command.Parameters.AddWithValue("@state", state);
                    command.Parameters.AddWithValue("@ref", reference);
                    command.ExecuteNonQuery();
                }
            }
        }

        private static JObject RequestJson(Uri endpoint, string method, object payload)
        {
            string clientId = Setting("HUBTEL_PAYMENT_CLIENT_ID", "HubtelPaymentClientId", null);
            string secret = Setting("HUBTEL_PAYMENT_CLIENT_SECRET", "HubtelPaymentClientSecret", null);
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(endpoint);
            request.Method = method;
            request.Accept = "application/json";
            request.ContentType = "application/json";
            request.Timeout = 20000;
            request.ReadWriteTimeout = 20000;
            request.AllowAutoRedirect = false;
            request.Headers[HttpRequestHeader.Authorization] = "Basic " +
                Convert.ToBase64String(Encoding.UTF8.GetBytes(clientId + ":" + secret));
            try
            {
                if (payload != null)
                {
                    byte[] bytes = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(payload));
                    request.ContentLength = bytes.Length;
                    using (Stream stream = request.GetRequestStream()) stream.Write(bytes, 0, bytes.Length);
                }
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    if ((int)response.StatusCode < 200 || (int)response.StatusCode >= 300)
                        throw new InvalidOperationException("Hubtel did not acknowledge the payment operation.");
                    return JObject.Parse(reader.ReadToEnd());
                }
            }
            catch (WebException ex)
            {
                HttpWebResponse response = ex.Response as HttpWebResponse;
                int status = response == null ? 0 : (int)response.StatusCode;
                if (response != null) response.Close();
                string message = "Hubtel payment request could not be confirmed (" +
                    (status == 0 ? ex.Status.ToString() : "HTTP " + status) +
                    "). Check merchant credentials, API/server-IP permissions and connectivity. Do not pay again while the outcome is unresolved.";
                if (method == "POST" && (status == 400 || status == 401 || status == 403 || status == 422))
                    throw new RequestRejectedException(message);
                throw new InvalidOperationException(message, ex);
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException("Hubtel returned an invalid payment response. The outcome is unresolved; check status before retrying.", ex);
            }
        }

        private static string Channel(string method)
        {
            switch (method)
            {
                case "MTN MoMo": return "mtn-gh";
                case "Telecel Cash": return "vodafone-gh";
                case "AT Money": return "tigo-gh";
                default: throw new ArgumentException("Select MTN MoMo, Telecel Cash or AT Money.");
            }
        }
        private static void ValidateNewPaymentConfiguration()
        {
            bool enabled;
            if (!Boolean.TryParse(Setting("HUBTEL_PAYMENTS_ENABLED", "HubtelPaymentsEnabled", "false"), out enabled) || !enabled)
                throw new ConfigurationErrorsException("Live Hubtel payments have not been enabled by the service operator. No wallet request was sent.");
            Merchant(); PublicBase();
            Setting("HUBTEL_PAYMENT_CLIENT_ID", "HubtelPaymentClientId", null);
            Setting("HUBTEL_PAYMENT_CLIENT_SECRET", "HubtelPaymentClientSecret", null);
        }
        private static string Merchant()
        {
            string value = Setting("HUBTEL_MERCHANT_ACCOUNT_NUMBER", "HubtelMerchantAccountNumber", null);
            if (!Regex.IsMatch(value, @"^[A-Za-z0-9_-]{1,40}$"))
                throw new ConfigurationErrorsException("The Hubtel merchant POS sales ID is invalid.");
            return value;
        }
        private static Uri PublicBase()
        {
            Uri value;
            if (!Uri.TryCreate(Setting("PUBLIC_APPLICATION_BASE_URL", "PublicApplicationBaseUrl", null), UriKind.Absolute, out value) ||
                value.Scheme != "https" || value.IsLoopback || value.UserInfo.Length > 0 ||
                value.Query.Length > 0 || value.Fragment.Length > 0 || !value.AbsolutePath.EndsWith("/", StringComparison.Ordinal))
                throw new ConfigurationErrorsException("The public application base URL must be the deployed HTTPS application address ending in '/'.");
            return value;
        }
        private static string Setting(string environment, string key, string fallback)
        {
            string value = Environment.GetEnvironmentVariable(environment);
            if (String.IsNullOrWhiteSpace(value)) value = ConfigurationManager.AppSettings[key];
            if (String.IsNullOrWhiteSpace(value)) value = fallback;
            if (String.IsNullOrWhiteSpace(value) || value.StartsWith("SET_", StringComparison.OrdinalIgnoreCase))
                throw new ConfigurationErrorsException("Hubtel payments are not configured. Set " + environment + " privately, or enter " + key + " in Hubtel.Private.config.");
            return value.Trim();
        }
        private static string Text(JObject value, string name)
        {
            JToken token = value.GetValue(name, StringComparison.OrdinalIgnoreCase);
            return token == null ? "" : Convert.ToString(token, CultureInfo.InvariantCulture);
        }
        private static JObject Object(JObject value, string name)
        {
            return value.GetValue(name, StringComparison.OrdinalIgnoreCase) as JObject;
        }
        private static string SafeCode(string code)
        {
            return Regex.IsMatch(code ?? "", @"^[A-Za-z0-9_-]{1,16}$") ? code : "unreadable";
        }
        private sealed class RequestRejectedException : InvalidOperationException
        {
            public RequestRejectedException(string message) : base(message) { }
        }
    }
}
