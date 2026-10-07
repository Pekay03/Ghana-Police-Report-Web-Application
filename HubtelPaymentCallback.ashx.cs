using System;
using System.IO;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PoliceBackgroundCheckSystem.Helpers;

namespace PoliceBackgroundCheckSystem
{
    public sealed class HubtelPaymentCallback : IHttpHandler
    {
        public bool IsReusable { get { return false; } }
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.TrySkipIisCustomErrors = true;
            if (context.Request.HttpMethod != "POST")
            {
                context.Response.StatusCode = 405;
                context.Response.Headers["Allow"] = "POST";
                context.Response.Write("{\"error\":\"POST required\"}");
                return;
            }
            if (!context.Request.IsSecureConnection)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("{\"error\":\"HTTPS required\"}");
                return;
            }
            try
            {
                char[] buffer = new char[32769];
                int read;
                using (StreamReader reader = new StreamReader(context.Request.InputStream))
                    read = reader.ReadBlock(buffer, 0, buffer.Length);
                if (read > 32768) throw new ArgumentException("Callback too large.");
                JObject body = JObject.Parse(new string(buffer, 0, read));
                JObject data = body.GetValue("Data", StringComparison.OrdinalIgnoreCase) as JObject;
                string reference = Convert.ToString((data ?? body).GetValue("ClientReference", StringComparison.OrdinalIgnoreCase));
                // Never trust callback status, amount, or a browser query string.
                // Always confirm with Hubtel's authenticated status endpoint.
                string state = HubtelPaymentService.RefreshPayment(reference);
                context.Response.Write(JsonConvert.SerializeObject(new { accepted = true, verified = state == "Paid" }));
            }
            catch (ArgumentException)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("{\"error\":\"Invalid payment reference or request\"}");
            }
            catch (JsonException)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("{\"error\":\"Invalid JSON\"}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Hubtel callback verification failed ({0}).", ex.GetType().Name);
                context.Response.StatusCode = 503;
                context.Response.Write("{\"error\":\"Provider confirmation unavailable; retry callback later\"}");
            }
        }
    }
}
