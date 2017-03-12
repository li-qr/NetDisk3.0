<%@ WebHandler Language="C#" Class="ScoreLogHandler" %>

using System;
using System.Web;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Configuration;

public class ScoreLogHandler : IHttpHandler, System.Web.SessionState.IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {
        if (context.Session["visit"] == null) {
            context.Session["visit"] = true;
            MongoServer server= MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
            MongoDatabase db = server.GetDatabase("centerdb");
            MongoCollection mco = db.GetCollection<Score_Log>("score_log");
            Score_Log sl = new Score_Log();
            sl.agent = context.Request.UserAgent;
            sl.ip = context.Request.ServerVariables.Get("Remote_Addr").ToString();
            try { 
                sl.host = System.Net.Dns.GetHostEntry(sl.ip).HostName;
            }catch(Exception e){
             sl.host = "null";
            } 
            sl.uploadDate = DateTime.Now;
            sl.brower = context.Request.Browser.Browser;
            sl.platform = context.Request.Browser.Platform;
            mco.Insert(sl);
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}

class Score_Log {
    public ObjectId _id;//BsonType.ObjectId 这个对应了 MongoDB.Bson.ObjectId 
    public string ip { set; get; }
    public string host { set; get; }
    public BsonDateTime uploadDate { set; get; }
    public string agent { set; get; }
    public string brower { set; get; }
    public string platform { set; get; }
}