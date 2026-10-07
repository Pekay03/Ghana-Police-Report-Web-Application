using System;
using System.Data;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;

namespace PoliceBackgroundCheckSystem
{
    internal static class SmsDeliveryTracking
    {
        internal static long Begin(string recipient, string type, int? userId)
        {
            using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
            {
                c.Open();
                using (var command = AdminWorkflowService.Command(c, null, @"INSERT INTO sms_delivery_logs
                    (UserID,PhoneNumber,MessageType,MessageReference,Provider,Status,CreatedAt)
                    VALUES (@User,@Phone,@Type,@Reference,'Hubtel','Pending',NOW(6));",
                    "@User", userId, "@Phone", recipient, "@Type", type, "@Reference", Guid.NewGuid().ToString("N")))
                {
                    command.ExecuteNonQuery();
                    return command.LastInsertedId;
                }
            }
        }

        internal static void Submitted(long logId, string messageId)
        {
            Update(logId, "Submitted", messageId, null);
        }

        internal static void Failed(long logId, bool uncertain, string safeError)
        {
            Update(logId, uncertain ? "Unknown" : "Failed", null, safeError);
        }

        private static void Update(long logId, string status, string messageId, string error)
        {
            // Only an authenticated provider receipt adapter may ever set Delivered.
            // No such adapter is enabled without confirming the Hubtel account/API contract.
            using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
            {
                c.Open();
                using (var command = AdminWorkflowService.Command(c, null, @"UPDATE sms_delivery_logs
                    SET Status=@Status,ProviderMessageID=@MessageID,
                        SentAt=CASE WHEN @Status='Submitted' THEN NOW(6) ELSE SentAt END,
                        ProviderResponse=@Summary,ErrorMessage=@Error
                    WHERE SmsLogID=@Log AND Status='Pending';",
                    "@Status", status, "@MessageID", messageId, "@Error", error,
                    "@Summary", JsonConvert.SerializeObject(new { Status = status, MessageId = messageId }),
                    "@Log", logId))
                    if (command.ExecuteNonQuery() != 1)
                        throw new InvalidOperationException("The SMS outcome could not be recorded. Do not automatically resend an uncertain request.");
            }
        }
    }
}
