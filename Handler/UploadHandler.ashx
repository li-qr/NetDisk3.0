<%@ WebHandler Language="C#" Class="UploadHandler" %>

using System;
using System.Web;
using System.Web.Services;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.GridFS;
using MongoDB.Driver.Builders;
using System.Configuration;
public class UploadHandler : IHttpHandler,System.Web.SessionState.IRequiresSessionState {
    /// <summary>
    /// 上传文件夹
    /// </summary>
    private const string UPLOAD_FOLDER = "~/uploadedFiles/";

    public void ProcessRequest(HttpContext context)
    {
        if (context.Session["user"] == null)
        {
            context.Response.Clear();
            context.Response.Write("{\"error\":\"请登录后再上传！\"}");
            context.Response.End();
        }
        else
        {
            try
            {                
                MongoServer server = MongoServer.Create(ConfigurationManager.AppSettings["dbserver"]);
                MongoDatabase mydb = server.GetDatabase("centerdb");
                MongoCollection filesinfo = mydb.GetCollection("filesinfo");
                for (int run = 0; run < context.Request.Files.Count; run++)
                {
                    HttpPostedFileBase file = new HttpPostedFileWrapper(context.Request.Files[run]);
                    FileSave.SaveInfo info = new FileSave.SaveInfo();
                    info.persons_id = context.Session["user"].ToString();
                    info.uploadDate = DateTime.Now;
                    info.originName = file.FileName;
                    System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                    byte[] retVal = md5.ComputeHash(file.InputStream);
                    string md = "";
                    for (int i = 0; i < retVal.Length; i++)
                    {
                        md += retVal[i].ToString("x2");
                    }
                    info.MD5 = md;
                    info.fileSize = file.ContentLength;
                    info.fileFormate = file.ContentType;//Path.GetExtension(file.FileName);
                    string newFileName = string.Format("{0}", Guid.NewGuid());   //新文件名---组成形式：  GUID + 下划线 + 原文件名
                    //string fileAbsPath = context.Server.MapPath(UPLOAD_FOLDER) + newFileName;   //绝对路径
                    info.saveName = newFileName;
                    //info.savePath = fileAbsPath;
                    filesinfo.Insert<FileSave.SaveInfo>(info);
                    //file.SaveAs(fileAbsPath);
                    
                    MongoGridFSSettings fsSetting = new MongoGridFSSettings() { Root = "file" };
                    MongoGridFS fs = new MongoGridFS(mydb, fsSetting);
                    byte[] myData = new Byte[1024*1024];
                   
                    //调用Write、WriteByte、WriteLine函数时需要手动设置上传时间
                    //通过Metadata 添加附加信息
                    MongoGridFSCreateOptions option = new MongoGridFSCreateOptions();
                    option.UploadDate = info.uploadDate.AsDateTime;
                    //创建文件，文件并存储数据
                    using (MongoGridFSStream gfs = fs.Create(newFileName, option))
                    {
                        file.InputStream.Position = 0;
                        while(file.InputStream.Position<file.InputStream.Length)
                        {
                            int rcount = file.InputStream.Read(myData, 0,myData.Length);
                            gfs.Write(myData, 0,rcount);
                        }
                        gfs.Close();
                    }

                }
                server.Disconnect();
                context.Response.Clear();
                context.Response.Write("{\"success\":\"success\"}");
            }
            catch (Exception e)
            {
               
                context.Response.Clear();
                context.Response.Write("{\"error\":\"文件上传失败！\"}");
            }
            finally
            {
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