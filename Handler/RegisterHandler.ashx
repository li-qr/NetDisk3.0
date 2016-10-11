<%@ WebHandler Language="C#" Class="RegisterHandler" %>

using System;
using System.Web;
using System.Configuration;
using System.Web.UI;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
public class RegisterHandler : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    
    public void ProcessRequest (HttpContext context) {

        if (!String.IsNullOrEmpty(context.Request.Form["name"]))
        {
            string dss = context.Request.Form["name"].ToString();
            MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
            MongoDatabase mydb = server.GetDatabase("centerdb");
            MongoCollection mycoll = mydb.GetCollection("personinfo");
            var query = new QueryDocument { { "email", context.Request.Form["name"].ToString() } };
            var result = mycoll.FindAs<UserControl>(query);
            if (result.Count() > 0)
            {
                server.Disconnect();
                context.Response.Clear();
                context.Response.Write("0");
                context.Response.End();
            }
            else
            {
                if (!String.IsNullOrEmpty(context.Request.Form["password"]))
                {
                    Users.User user = new Users.User();
                    user.name = context.Request.Form["nickname"].ToString();
                    user.email = context.Request.Form["name"].ToString();
                    user.key = context.Request.Form["password"].ToString();

                    try
                    {
                        mycoll.Insert<Users.User>(user);
                        context.Response.Clear();
                        context.Response.Write("1");
                    }
                    catch
                    {
                        context.Response.Clear();
                        context.Response.Write("2");
                    }
                    finally
                    {
                        server.Disconnect();
                        context.Response.End();
                    }
                }
                server.Disconnect();
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}