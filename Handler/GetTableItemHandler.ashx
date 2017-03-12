<%@ WebHandler Language="C#" Class="get_table_item" %>

using System;
using System.Web;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using MongoDB.Bson;
using MongoDB.Driver.GridFS;
using System.Configuration;
using System.Data;


public class get_table_item : IHttpHandler, System.Web.SessionState.IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {
        
            if (!String.IsNullOrEmpty(context.Request.QueryString["tableitem"]))
            {

               string key = HttpContext.Current.Server.UrlDecode(context.Request.QueryString["tableitem"].ToString());
                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                // MongoGridFSSettings fsSetting = new MongoGridFSSettings() { Root = "file" };
                //MongoGridFS fs = new MongoGridFS(mydb, fsSetting);
                MongoCollection mco = mydb.GetCollection("filesinfo");
                DataTable dt = new DataTable();
                dt.Columns.AddRange(new DataColumn[4] { new DataColumn("filename", typeof(string)), new DataColumn("size", typeof(string)), new DataColumn("retime", typeof(string)), new DataColumn("id", typeof(string)) });
               
                
                var query = Query.Matches("persons_id", ".+");
                if(context.Session["user"]!=null) {  query = Query.Matches("persons_id", context.Session["user"].ToString()); }              

                string[] b = key.Split(' ');
                for (int i = 0; i < b.Length; i++)
                {
                    if (b[i] != "")
                    {
                        query = Query.And(query, Query.Matches("originName", b[i] + "+"));
                    }
                }
                MongoCursor mc;
                mc = mco.FindAs<FileSave.SaveInfo>(query);
                foreach (FileSave.SaveInfo fileinfo in mc)
                {

                    int flag = 0;
                    int run;
                    for (run = 0; run < dt.Rows.Count; run++)
                    {
                        string s1 = fileinfo.originName;
                        string s2 = dt.Rows[run].ItemArray[0].ToString();
                        if (s1 == s2)
                        {
                            DateTime dt1 = Convert.ToDateTime(fileinfo.uploadDate);
                            DateTime dt2 = Convert.ToDateTime(dt.Rows[run].ItemArray[2]);
                            if (DateTime.Compare(dt1, dt2) > 0)
                            {
                                dt.Rows[run].Delete();
                                double len = (double)fileinfo.fileSize;
                                string[] sizes = { "B", "KB", "MB", "GB" };
                                int order = 0;
                                while (len > 1024 && order + 1 < sizes.Length) { order++; len = len / 1024; }
                                dt.Rows.Add(fileinfo.originName, String.Format("{0:F}", len) + sizes[order], fileinfo.uploadDate.AsDateTime, fileinfo.saveName);
                            }
                            flag = 1;
                        }

                    }
                    if (flag == 0)
                    {
                        double len = (double)fileinfo.fileSize;
                        string[] sizes = { "B", "KB", "MB", "GB" };
                        int order = 0;
                        while (len > 1024 && order + 1 < sizes.Length) { order++; len = len / 1024; }
                        dt.Rows.Add(fileinfo.originName, String.Format("{0:F}", len) + sizes[order], fileinfo.uploadDate.AsDateTime, fileinfo.saveName);
                    }

                }
                server.Disconnect();
                string result = myConverter.DataTable2Json(dt);
                //result =Newtonsoft.Json.JsonConvert.SerializeObject(dt);
                context.Response.Clear();
                context.Response.Write(result);
                context.Response.End();
                    
            }
        
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}