using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using MongoDB.Bson;
public class FileSave : ApiController
{
    public class SaveInfo {
        public ObjectId _id;
        public string persons_id{set;get;}
        public string saveName{set;get;}
        public string originName { set; get; }
        public string savePath { set; get; }
        public string fileFormate { set; get; }
        public BsonDouble fileSize { set; get; }
        public BsonDateTime uploadDate { set; get; }
        public string MD5 { set; get; }
    }
}
