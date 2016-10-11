﻿<%@ WebHandler Language="C#" Class="UploadHandler" %>

using System;
using System.IO;
using System.Web;
using System.Web.Services;
using MongoDB.Bson;
using MongoDB.Driver;
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
                MongoCollection mycoll = mydb.GetCollection("uploadedinfo");
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
                    info.fileFormate = Path.GetExtension(file.FileName);
                    string newFileName = string.Format("{0}", Guid.NewGuid());   //新文件名---组成形式：  GUID + 下划线 + 原文件名
                    string fileAbsPath = context.Server.MapPath(UPLOAD_FOLDER) + newFileName;   //绝对路径
                    info.saveName = newFileName;
                    info.savePath = fileAbsPath;
                    mycoll.Insert<FileSave.SaveInfo>(info);
                    file.SaveAs(fileAbsPath);
                    server.Disconnect();
                    context.Response.Clear();
                    context.Response.Write("{\"success\":\"success\"}");

                }

            }
            catch (Exception)
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