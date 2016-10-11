using System;
using System.Collections.Generic;
//using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using MongoDB.Bson;

public class Users : ApiController
{
    public class User
    {
        public ObjectId _id;//BsonType.ObjectId 这个对应了 MongoDB.Bson.ObjectId 
        public string key { set; get; }
        public string name { set; get; }
        public string email { set; get; }
    }
}
