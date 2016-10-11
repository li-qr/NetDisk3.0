<%@ WebHandler Language="C#" Class="LogHandler" %>

using System;
using System.Web;
using System.Configuration;
using System.Web.UI;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
public class LogHandler : IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
    
    public void ProcessRequest (HttpContext context) {
        if (!String.IsNullOrEmpty(context.Request.Form["action"]))
        {

            int action = -1;
            try
            {
                action = System.Convert.ToInt32(context.Request.Form["action"].ToString());
            }
            catch { }
            if (action == 0)
            {
                string dss = context.Request.Form["name"].ToString();
                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                MongoCollection mycoll = mydb.GetCollection("personinfo");
                var query = new QueryDocument { { "email", context.Request.Form["name"].ToString() } };
                var result = mycoll.FindAs<UserControl>(query);
                if (result.Count() > 0)
                {
                    context.Response.Clear();
                    BsonDocument bsdc = (BsonDocument)mycoll.FindOneAs<BsonDocument>(query);
                    string d = context.Request.Form["password"].ToString();
                    server.Disconnect();
                    if (context.Request.Form["password"].ToString() != bsdc[1].RawValue.ToString())
                    {
                        context.Response.Write("{\"code\":\"12\"}");//密码错误                       
                    }
                    else
                    {
                        context.Session.Remove("user");
                        context.Session.Remove("group"); //管理员 ？普通用户
                        context.Session["user"] = bsdc[0].RawValue.ToString();
                        context.Session["name"] = bsdc[2].RawValue.ToString();
                        context.Response.Write("{\"code\":\"10\",\"msg\":\"" + context.Session["name"].ToString() + "\"}");//登陆成功                        
                    }
                }
                else
                {
                    server.Disconnect();
                    context.Response.Write("{\"code\":\"11\"}");//用户名错误                    
                }
                context.Response.End();
            }
            else if (action == 1)
            {

                context.Session.Clear();
                context.Response.Clear();
                context.Response.Write("{\"code\":\"3\"}");
                context.Response.End();
            }
            else if (action == 2)
            {

                context.Response.Clear();
                if (context.Session["user"] == null)
                {
                    context.Response.Write("{\"code\":\"0\"}");
                }
                else { context.Response.Write("{\"code\":\"1\",\"msg\":\"" + context.Session["name"].ToString() + "\"}"); }
                context.Response.End();
            }
            else
            {

                context.Response.Clear();
                context.Response.Write("{\"code\":\"13\"}");
                context.Response.End();
            }

        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}