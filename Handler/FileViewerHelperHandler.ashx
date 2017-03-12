<%@ WebHandler Language="C#" Class="FileViewerHelperHandler" %>

using System;
using System.Web;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using MongoDB.Bson;
using MongoDB.Driver.GridFS;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using System.Configuration;
using Aspose.Cells;
using Aspose.Pdf;
//using Aspose.Slides;
using Aspose.Words;


public class FileViewerHelperHandler : IHttpHandler,System.Web.SessionState.IRequiresSessionState {
    
    public void ProcessRequest (HttpContext context) {
      //  if (context.Session["user"] != null)
       // {
            if (!String.IsNullOrEmpty(context.Request.QueryString["fil"]))
            {

                var types = new string[]{
                    "application/pdf",
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                    "application/msword",
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "application/vnd.ms-excel",
                    
                   // "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                   // "application/vnd.ms-powerpoint"
                };
                string downfilemd5 =context.Request.QueryString["fil"]; 
                bool cancov = false;

                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                MongoCollection mco = mydb.GetCollection("filesinfo");
                var queryInfo = Query.EQ("saveName", downfilemd5);
                FileSave.SaveInfo info = mco.FindOneAs<FileSave.SaveInfo>(queryInfo);
                if (info == null) { return; }
                for (int i = 0; i < types.Length; i++)
                {
                    if (types[i].Equals(info.fileFormate))
                    {
                        cancov = true;
                    }
                }

                if (!cancov)
                {
                    return;
                }
                
                MongoGridFSSettings fsSetting = new MongoGridFSSettings() { Root = "file" };
                MongoGridFS fs = new MongoGridFS(mydb, fsSetting);
                MemoryStream iee = new MemoryStream();
                MemoryStream ie = new MemoryStream();
                
                var queryFile = Query.EQ("filename", downfilemd5);
                fs.Download(ie, queryFile);

                if (info.fileFormate.Equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document") ||
                    info.fileFormate.Equals("application/msword")
                    )
                {
                    ie.Position = 0;
                    Document awd = new Document(ie);
                    awd.Save(iee, Aspose.Words.SaveFormat.Pdf);
                }

                if (info.fileFormate.Equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") ||
                    info.fileFormate.Equals("application/vnd.ms-excel"))
                {
                    ie.Position = 0;
                    Workbook wb = new Workbook(ie);
                    wb.Save(iee, Aspose.Cells.SaveFormat.Html);
                    context.Response.ContentType = "text/html";
                    //context.Response.AddHeader("Content-Disposition", "attachment; filename=" + info.saveName + ".html");
                    byte[] mdata = new Byte[1024 * 1024];
                    iee.Position = 0;
                    while (iee.Position < iee.Length)
                    {
                        int rcount = iee.Read(mdata, 0, mdata.Length);
                        context.Response.OutputStream.Write(mdata, 0, rcount);
                    }
                    context.Response.End();
                    return;
                }
                //if (info.fileFormate.Equals("application/vnd.openxmlformats-officedocument.presentationml.presentation") ||
                //    info.fileFormate.Equals("application/vnd.ms-powerpoint"))
                //{
                //    ie.Position = 0;
                //    Aspose.Slides.LoadOptions ld = new Aspose.Slides.LoadOptions();
                //    ld.LoadFormat = Aspose.Slides.LoadFormat.Ppt;
                //    Presentation pr = new Presentation(ie,ld);
                //    pr.Save(iee, Aspose.Slides.Export.SaveFormat.Pdf);
                //}
                if (info.fileFormate.Equals("application/pdf")) {
                    
                    ie.WriteTo(iee);
                }
                
                context.Response.ContentType = "application/pdf";
                context.Response.AddHeader("Content-Disposition", "attachment; filename="+info.saveName+".pdf");
                byte[] data = new Byte[1024*1024];
                iee.Position = 0;
                while (iee.Position < iee.Length)
                    {
                        int rcount = iee.Read(data, 0, data.Length);
                        context.Response.OutputStream.Write(data, 0, rcount);
                    }

                context.Response.End();
                return;
               // }
            }
            
       // }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}