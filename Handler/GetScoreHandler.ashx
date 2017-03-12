<%@ WebHandler Language="C#" Class="GetScoreHandler" %>

using System;
using System.Web;
using System.Net;
using System.IO;
using Newtonsoft.Json.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Configuration;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
public class GetScoreHandler : IHttpHandler,System.Web.SessionState.IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {
        if (!String.IsNullOrEmpty(context.Request.QueryString["key"]))
        {
            String key = context.Server.UrlDecode(context.Request.QueryString["key"]);
            MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
            MongoDatabase mydb = server.GetDatabase("centerdb");
            MongoCollection mco = mydb.GetCollection("students");

            if (isNumberic(key))
            {
                if (key.Length == 9)
                {
                    var q = Query.EQ("ID", key);
                    MongoCursor mc;
                    mc  = mco.FindAs<IN>(q);
                    if (mc.Size()!=0)
                    {                        
                        context.Response.Clear();
                        context.Response.Write(parseToJSON(mc));
                    }
                    else
                    {
                        context.Response.Clear();
                        context.Response.Write("error");
                    }
                }
                else if (key.Length == 7)
                {
                    var q = Query.Matches("ID", key + "+");
                    MongoCursor mc;
                    mc = mco.FindAs<IN>(q);
                    if (mc.Size() != 0)
                    {
                       
                        context.Response.Clear();
                        context.Response.Write(parseToJSON(mc));
                    }
                    else
                    {
                        context.Response.Clear();
                        context.Response.Write("error");
                    }
                }
                else
                {
                    context.Response.Clear();
                    context.Response.Write("error");
                }
            }
            else
            {
                var q = Query.EQ("name", key);
                MongoCursor mc;
                mc = mco.FindAs<IN>(q);
                if (mc.Size() != 0)
                {                   
                    context.Response.Clear();
                    context.Response.Write(parseToJSON(mc));
                }
                else
                {
                    context.Response.Clear();
                    context.Response.Write("error");
                }
            }
            server.Disconnect();

            context.Response.End();
        }
        else { 
        }
        
        
    }

    static string parseToJSON(MongoCursor mc) {
        string json = "";
        json += "[";
        int j = 0;        
        foreach (IN i in mc)
        {
            string info = i.info;
            string name = i.name;
            string id = i.ID;
            Boolean haveImg = (Boolean)i.haveImg;
            info = info.Substring(0, info.IndexOf("获得学位") - 74);
            String ids = info.Substring(info.IndexOf("身份证号") + 49, 14);
            info = info.Replace(ids, "**************");
            info = info.Replace("\"","\\\"");
            info = info.Replace("\n", "").Replace("\t", "").Replace("\r", "");
            Regex r = new Regex("http:.*?\"");
            Regex r1 = new Regex(@"width=\d+");
            Regex r2 = new Regex(@"height=\d+");
            if (haveImg)
            {
                info = r.Replace(info, "./StudentsPhoto/" + id + ".jpg\\\"");
                info = r1.Replace(info, "width=100%");
                info = r2.Replace(info, "height=100%");
            }
            else
            {
                info = r.Replace(info, "./StudentsPhoto/none.jpg\"");
                int aa = info.IndexOf("民族");
                info = info.Insert(info.IndexOf("民族") - 73, "<img src=\\\"./StudentsPhoto/none.jpg\\\" width=100% height=100% border=no>");
            }
            
            j++;
            json += "{";            
                json += "\"" + "id" + "\":\"" + id + "\",";
                json += "\"" + "info" + "\":\"" + info + "\"";
            json += "}";
            if (j != mc.Size()) { json += ","; }
        }
        json += "]";
        return json;        
    }
    
    static bool isNumberic(string message)
    {
        
        try
        {
            Convert.ToInt32(message);
            return true;
        }
        catch
        {
            return false;
        }
    }
   
    
    public bool IsReusable {
        get {
            return false;
        }
    }

}

class IN
{
    public ObjectId _id;//BsonType.ObjectId 这个对应了 MongoDB.Bson.ObjectId 
    public string ID { set; get; }
    public string name { set; get; }
    public string info { set; get; }
    public BsonBoolean haveImg { set; get; }
}