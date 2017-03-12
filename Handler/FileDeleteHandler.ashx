<%@ WebHandler Language="C#" Class="FileDeleteHandler" %>

using System;
using System.IO;
using System.Web;
using System.Web.Services;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using System.Configuration;

public class FileDeleteHandler : IHttpHandler, System.Web.SessionState.IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {
        if (context.Session["user"] != null)
        {
            if (!String.IsNullOrEmpty(context.Request.QueryString["deletenames"]))
            { 
                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                MongoCollection mco = mydb.GetCollection("filesinfo");
                string filesName = context.Request.QueryString["deletenames"];
                string[] temp = filesName.Split('|');
                for (int t = 0; t < temp.Length; t++) {
                    var query = Query.EQ("saveName", temp[t]);
                    mco.Remove(query);
                }
            }
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}