using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace PoliceBackgroundCheckSystem
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        void Application_PreRequestHandlerExecute(object sender, EventArgs e)
        {
            System.Web.UI.Page page =
                Context.CurrentHandler as System.Web.UI.Page;

            if (page != null && page.Session != null)
                page.PreInit += SetSessionBoundViewStateUserKey;
        }

        private static void SetSessionBoundViewStateUserKey(
            object sender,
            EventArgs e)
        {
            System.Web.UI.Page page =
                sender as System.Web.UI.Page;

            if (page != null && page.Session != null)
            {
                // Reading SessionID alone does not persist an empty anonymous
                // session. Store a value before rendering the first form so its
                // postback uses the same session ID and ViewState MAC key.
                if (page.Session["ViewStateSessionInitialized"] == null)
                    page.Session["ViewStateSessionInitialized"] = true;

                page.ViewStateUserKey = page.Session.SessionID;

                // Do not restore a cached form signed for an expired session.
                page.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                page.Response.Cache.SetNoStore();
                page.Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
                page.Response.Cache.SetRevalidation(HttpCacheRevalidation.AllCaches);
            }
        }
    }
}