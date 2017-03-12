<%@ WebHandler Language="C#" Class="FileDownloadHandler" %>

using System;
using System.Web;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using MongoDB.Bson;
using MongoDB.Driver.GridFS;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using System.Configuration;
public class FileDownloadHandler : IHttpHandler,System.Web.SessionState.IRequiresSessionState {
    
    public void ProcessRequest (HttpContext context) {
        if (context.Session["user"] != null)
        {
            if (!String.IsNullOrEmpty(context.Request.QueryString["downmd5s"]))
            {
                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");                
                MongoCollection mco = mydb.GetCollection("filesinfo");
                //System.Net.IPAddress ip = System.Net.IPAddress.Parse(context.Request.UserHostAddress);      //根据目标ip地址的获取ip对象
               // System.Net.IPHostEntry ihe = System.Net.Dns.GetHostEntry(ip);
                string downfilemd5 =context.Request.QueryString["downmd5s"];
                MongoGridFSSettings fsSetting = new MongoGridFSSettings() { Root = "file" };
                //通过文件名去数据库查值
                MongoGridFS fs = new MongoGridFS(mydb, fsSetting);
                //方法一，很简洁
                MemoryStream iee = new MemoryStream();
                using (ZipOutputStream s = new ZipOutputStream(iee))
                {

                    s.SetLevel(4);
                  
                        string[] temp = downfilemd5.Split('|');
                        for (int t = 0; t < temp.Length ; t++)
                        {
                            if (temp[t] != "")
                            {
                                MemoryStream ie = new MemoryStream();
                                var queryFile = Query.EQ("filename", temp[t]);
                                fs.Download(ie, queryFile);
                                var queryInfo = Query.EQ("saveName", temp[t]);
                                FileSave.SaveInfo info = mco.FindOneAs<FileSave.SaveInfo>(queryInfo);
                                ZipEntry entry = new ZipEntry(info.originName);
                                entry.DateTime = DateTime.Now;
                                s.PutNextEntry(entry);
                                s.Write(ie.GetBuffer(), 0, (int)ie.Length);
                            }
                        }
                    
                    
                    s.Finish();
                    context.Response.ContentType = "application/octet-stream";
                    //实现下载+文件名
                    context.Response.AddHeader("Content-Disposition", "attachment; filename=打包的文件.zip");
                    context.Response.OutputStream.Write(iee.GetBuffer(), 0, (int)iee.Length);
                    s.Close();
                    // Response.Flush();
                    context.Response.End();
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