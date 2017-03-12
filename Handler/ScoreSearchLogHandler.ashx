<%@ WebHandler Language="C#" Class="ScoreSearchLogHandler" %>

using System;
using System.Web;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Configuration;

public class ScoreSearchLogHandler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        if (!String.IsNullOrEmpty(context.Request.QueryString["k"])) {
            String k = context.Request.QueryString["k"];
            MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
            MongoDatabase db = server.GetDatabase("centerdb");
            MongoCollection mco = db.GetCollection<Score_Search_Log>("score_search_log");
            Score_Search_Log sl = new Score_Search_Log();
            sl.ip = context.Request.ServerVariables.Get("Remote_Addr").ToString();
            sl.uploadDate = DateTime.Now;
            sl.key = k;
            mco.Insert(sl);
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}

class Score_Search_Log {
    public ObjectId _id;
    public string ip { set; get; }
    public string key { set; get; }
    public BsonDateTime uploadDate { set; get; }
}