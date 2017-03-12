<%@ WebHandler Language="C#" Class="RENameHandler" %>

using System;
using System.IO;
using System.Web;
using System.Web.Services;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using System.Configuration;

public class RENameHandler : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    
    public void ProcessRequest (HttpContext context) {
        if (context.Session["user"] != null)
        {
            if (!String.IsNullOrEmpty(context.Request.QueryString["newname"]) 
                && !String.IsNullOrEmpty(context.Request.QueryString["savename"]))
            {
                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                MongoCollection mco = mydb.GetCollection("uploadedinfo");
                string fileName = context.Request.QueryString["newname"];
                string which = context.Request.QueryString["savename"];                
                var query = Query.EQ("saveName", which);
                var update = MongoDB.Driver.Builders.Update.Set("originName", fileName);
                mco.Update(query,update);
                
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}