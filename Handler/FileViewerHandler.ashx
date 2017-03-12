<%@ WebHandler Language="C#" Class="FileViewerHandler" %>

using System;
using System.Web;
using MongoDB.Driver;
using MongoDB.Driver.Builders;

public class FileViewerHandler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
       // if (context.Session["user"] != null) {
            if (!String.IsNullOrEmpty(context.Request.QueryString["fil"])) {

                string downfilemd5 = context.Request.QueryString["fil"];
                String ur = context.Request.Url.Authority;
                MongoServer server = MongoServer.Create(System.Configuration.ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                MongoCollection mco = mydb.GetCollection("filesinfo");
                var queryInfo = Query.EQ("saveName", downfilemd5);
                FileSave.SaveInfo info = mco.FindOneAs<FileSave.SaveInfo>(queryInfo);
                if (null == info) { return; }
                if (info.fileFormate.Equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document") ||
                    info.fileFormate.Equals("application/msword")  || info.fileFormate.Equals("application/pdf")||info.fileFormate.Equals("text/plain")) {
                        context.Response.Write("{\"durl\":\"http://"+ur+"/web/viewer.html?file="+context.Server.UrlEncode("http://"+ur+"/Handler/FileViewerHelperHandler.ashx?fil="+info.saveName)+"\"}");
                        context.Response.End();
                }
                if (info.fileFormate.Equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") ||
                    info.fileFormate.Equals("application/vnd.ms-excel")) {
                        context.Response.Write("{\"durl\":\"http://" + ur +"/Handler/FileViewerHelperHandler.ashx?fil=" + info.saveName + "\"}");
                        context.Response.End();
                }
                if(info.fileFormate.Equals("image/gif")||info.fileFormate.Equals("image/jpeg")||info.fileFormate.Equals("image/png")){
                    context.Response.Write("{\"durl\":\"http://" + ur + "/Handler/FileViewerHelperHandler.ashx?fil=" + info.saveName + "\"}");
                    context.Response.End();
                }
                
                
                
                
            }
      //  }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}