using System;
using System.Web.UI;

namespace PoliceBackgroundCheckSystem
{
    public partial class IdentityReviewPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            int actor;
            string reviewer;
            if (!StaffAccess.TryUser(Context, false, out actor, out reviewer))
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }
    }
}
