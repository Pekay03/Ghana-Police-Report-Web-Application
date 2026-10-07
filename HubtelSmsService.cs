using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text.RegularExpressions;

namespace PoliceBackgroundCheckSystem.Helpers
{
    public static class HubtelSmsService
    {
        public static void SendVerificationCode(string phone, string code, int? userId = null)
        {
            if (String.IsNullOrWhiteSpace(code) || !Regex.IsMatch(code, @"^[0-9]{6}$"))
                throw new ArgumentException("A six-digit verification code is required.", "code");

            SendTracked(phone, "Police Background Check verification code: " +
                code + ". It expires in 5 minutes.", "PasswordReset", userId);
        }

        public static string SendRegistrationConfirmation(string phone, int? userId = null)
        {
            // A notification is not proof that the phone has been verified.
            return SendTracked(phone,
                "Your Police Background Check account has been created. Sign in to submit and track your application. Keep your password private.",
                "Registration", userId);
        }

        private static string SendTracked(string phone, string content, string type, int? userId)
        {
            string recipient = ToE164GhanaPhone(phone);
            // The durable pending record must exist before any provider request.
            long logId = PoliceBackgroundCheckSystem.SmsDeliveryTracking.Begin(recipient, type, userId);
            bool started = false;
            try
            {
                string messageId = SendMessage(recipient, content, out started);
                PoliceBackgroundCheckSystem.SmsDeliveryTracking.Submitted(logId, messageId);
                return messageId;
            }
            catch (Exception ex)
            {
                bool uncertain = started && !(ex is ProviderRejectedException);
                var web = ex.InnerException as WebException;
                var response = web == null ? null : web.Response as HttpWebResponse;
                if (response != null && (int)response.StatusCode >= 400 &&
                    (int)response.StatusCode < 500 && response.StatusCode != HttpStatusCode.RequestTimeout)
                    uncertain = false;
                string summary = uncertain ? "Provider outcome is uncertain; no automatic resend." :
                    ex is ConfigurationErrorsException ? "SMS configuration is missing or invalid." :
                    "The provider request was not accepted.";
                if (web != null) summary += " Transport: " + web.Status + ".";
                if (response != null) summary += " HTTP " + (int)response.StatusCode + ".";
                var rejection = ex as ProviderRejectedException;
                if (rejection != null) summary = "Hubtel rejected the SMS request (status " + rejection.ProviderStatus + ").";
                try { PoliceBackgroundCheckSystem.SmsDeliveryTracking.Failed(logId, uncertain, summary); }
                catch (Exception trackingError)
                {
                    System.Diagnostics.Trace.TraceError("SMS outcome recording failed ({0}).", trackingError.GetType().Name);
                    throw new InvalidOperationException("SMS outcome tracking failed. Acceptance/delivery is unconfirmed; do not automatically resend.", ex);
                }
                throw;
            }
        }

        private static string SendMessage(string phone, string content, out bool requestStarted)
        {
            requestStarted = false;
            string sendMessageUrl = ReadSetting(
                "HUBTEL_SMS_API_URL",
                "HubtelSmsApiUrl");
            string clientId = ReadSetting(
                "HUBTEL_SMS_CLIENT_ID",
                "HubtelSmsClientId");
            string clientSecret = ReadSetting(
                "HUBTEL_SMS_CLIENT_SECRET",
                "HubtelSmsClientSecret");
            string senderId = ReadSetting(
                "HUBTEL_SMS_SENDER_ID",
                "HubtelSmsSenderId");

            string recipient = ToE164GhanaPhone(phone);
            Uri endpoint = ValidateEndpoint(sendMessageUrl);
            if (senderId.Length > 15 || senderId.IndexOfAny(new[] { '\r', '\n' }) >= 0)
                throw new ConfigurationErrorsException("The Hubtel sender ID is invalid. Use the exact sender ID approved for your SMS account.");

            byte[] payload = Encoding.UTF8.GetBytes(
                JsonConvert.SerializeObject(new
                {
                    From = senderId,
                    To = recipient,
                    Content = content,
                    RegisteredDelivery = true
                }));

            HttpWebRequest request =
                (HttpWebRequest)WebRequest.Create(endpoint);
            request.Method = "POST";
            request.ContentType = "application/json";
            request.Accept = "application/json";
            request.Timeout = 15000;
            request.ReadWriteTimeout = 15000;
            request.AllowAutoRedirect = false;
            request.ContentLength = payload.Length;
            request.Headers[HttpRequestHeader.Authorization] =
                "Basic " + Convert.ToBase64String(
                    Encoding.UTF8.GetBytes(clientId + ":" + clientSecret));

            try
            {
                requestStarted = true;
                using (Stream requestStream = request.GetRequestStream())
                    requestStream.Write(payload, 0, payload.Length);

                using (HttpWebResponse response =
                    (HttpWebResponse)request.GetResponse())
                {
                    if (response.StatusCode != HttpStatusCode.Created &&
                        response.StatusCode != HttpStatusCode.OK)
                    {
                        throw new InvalidOperationException(
                            "Hubtel did not accept the SMS request (HTTP " +
                            ((int)response.StatusCode).ToString() +
                            ").");
                    }
                    string json;
                    using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                        json = reader.ReadToEnd();
                    // Accepted for delivery does not mean delivered to the handset.
                    return ParseAcknowledgement(json);
                }
            }
            catch (WebException ex)
            {
                HttpWebResponse errorResponse =
                    ex.Response as HttpWebResponse;
                string status = errorResponse == null
                    ? ex.Status.ToString()
                    : "HTTP " + ((int)errorResponse.StatusCode).ToString();

                if (errorResponse != null)
                    errorResponse.Close();

                throw new InvalidOperationException(
                    "Hubtel rejected or could not accept the SMS (" + status + "). " +
                    (errorResponse != null && (int)errorResponse.StatusCode == 401
                        ? "Check the SMS client ID and client secret."
                        : "Check the approved sender ID, SMS balance, gateway permissions and connection."),
                    ex);
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException("Hubtel returned an unreadable SMS acknowledgement; delivery has not been confirmed.", ex);
            }
        }

        private static string ParseAcknowledgement(string json)
        {
            JObject acknowledgement = JObject.Parse(json);
            int status;
            string messageId = Convert.ToString(acknowledgement.GetValue("MessageId", StringComparison.OrdinalIgnoreCase));
            bool hasStatus = Int32.TryParse(Convert.ToString(acknowledgement.GetValue("Status", StringComparison.OrdinalIgnoreCase)), out status);
            if (hasStatus && status != 0) throw new ProviderRejectedException(status);
            if (!hasStatus || String.IsNullOrWhiteSpace(messageId) ||
                !Regex.IsMatch(messageId, @"^[A-Za-z0-9-]{1,100}$"))
                throw new InvalidOperationException(
                    "Hubtel did not acknowledge the SMS as accepted. Check the SMS balance, approved sender ID and API permissions.");
            return messageId;
        }

        private sealed class ProviderRejectedException : InvalidOperationException
        {
            internal readonly int ProviderStatus;
            internal ProviderRejectedException(int status)
                : base("Hubtel rejected the SMS request (status " + status + ").")
            { ProviderStatus = status; }
        }

        private static string ReadSetting(
            string environmentVariable,
            string appSetting)
        {
            string value =
                Environment.GetEnvironmentVariable(environmentVariable);

            if (String.IsNullOrWhiteSpace(value))
                value = ConfigurationManager.AppSettings[appSetting];

            if (String.IsNullOrWhiteSpace(value) ||
                value.StartsWith("SET_", StringComparison.OrdinalIgnoreCase))
            {
                throw new ConfigurationErrorsException(
                    "Hubtel SMS is not configured. Set " +
                    environmentVariable +
                    " or " +
                    appSetting +
                    " before sending registration or recovery messages.");
            }

            return value.Trim();
        }

        private static Uri ValidateEndpoint(string endpoint)
        {
            Uri uri;
            if (!Uri.TryCreate(endpoint, UriKind.Absolute, out uri) ||
                !String.Equals(uri.Scheme, Uri.UriSchemeHttps, StringComparison.OrdinalIgnoreCase) ||
                !String.Equals(uri.AbsolutePath, "/v1/messages/send", StringComparison.Ordinal))
            {
                throw new ConfigurationErrorsException(
                    "Hubtel SMS API URL must be an HTTPS Hubtel /v1/messages/send endpoint.");
            }

            string host = uri.Host.ToLowerInvariant();
            bool isHubtelHost =
                host == "smsc.hubtel.com" ||
                host == "sms-api.hubtel-test.com" ||
                host.EndsWith(".hubtel.com", StringComparison.Ordinal) ||
                host.EndsWith(".hubtel-test.com", StringComparison.Ordinal);

            if (!isHubtelHost)
            {
                throw new ConfigurationErrorsException(
                    "Hubtel SMS API URL must use an approved Hubtel host.");
            }

            return uri;
        }

        public static string ToE164GhanaPhone(string phone)
        {
            string number = Regex.Replace(phone ?? String.Empty, @"[\s()-]", "");
            if (Regex.IsMatch(number, @"^0[25][0-9]{8}$"))
                return "+233" + number.Substring(1);
            if (Regex.IsMatch(number, @"^\+?233[25][0-9]{8}$"))
                return number.StartsWith("+", StringComparison.Ordinal) ? number : "+" + number;

            throw new FormatException(
                "The registered phone number is not a valid Ghana mobile number.");
        }
    }
}