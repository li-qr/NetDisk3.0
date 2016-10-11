using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Text.RegularExpressions;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

//添加对应mongodb的命名空间
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.GridFS;
using MongoDB.Driver.Builders;

/// <summary>
///DBconnect 的摘要说明
/// </summary>
public class DBconnect
{
    public DBconnect()
    {
        //
        //TODO: 在此处添加构造函数逻辑
        //
    }
    //查找数据库中自定的集合并存入DataTable中
    static public DataTable Connect(string IP, string Collection)//连接数据库
    {
        MongoServer server = MongoServer.Create(IP);//连接服务器
        MongoDatabase db = server.GetDatabase("centerdb");//连接到数据库
        //连接到数据集合user中
        MongoCollection<BsonDocument> collection = db.GetCollection<BsonDocument>(Collection);
        IMongoQuery query = Query.Exists("name");//建立查询条件
        MongoCursor<BsonDocument> mc = collection.Find(query);//将数据存入MongoCursor类mc中
        DataSet ds = new DataSet();
        DataTable dt = new DataTable();

        dt.Columns.AddRange(new DataColumn[] { new DataColumn("userid", typeof(string)),
            new DataColumn("key", typeof(string)),new DataColumn("name", typeof(string)),
        new DataColumn("tel", typeof(string)),new DataColumn("email", typeof(string))});
        foreach (BsonDocument bt in mc)
        {
            dt.Rows.Add(bt[1], bt[2], bt[3], bt[4], bt[5]);
        }
        //server.Shutdown();
        return dt;

    }

    //判断用户集合中是否存在指定的用户名，如果不存在就添加
    static public int Add(string IP, string[] user)//连接数据库
    {
        MongoServer server = MongoServer.Create(IP);//连接服务器
        MongoDatabase db = server.GetDatabase("centerdb");//连接到数据库
        //连接到数据集合user1中
        MongoCollection<BsonDocument> collection = db.GetCollection<BsonDocument>("registerinfo");
        IMongoQuery query = Query.EQ("userid", user[0]);//建立查询条件，判断user集合中用户名是否存在
        MongoCursor<BsonDocument> mc = collection.Find(query);//将数据存入MongoCursor类mc中
        if (mc.Count() != 0)
        {
            return 0; //response.Write("shanchushibai")
        }
        else//将用户名添加到集合user1中
        {
            BsonDocument doc = new BsonDocument { { "userid", user[0] }, { "key", user[1]},
            {"name",user[2]},{"tel",user[3]},{"email",user[4]}};
            collection.Insert(doc);
            return 1;
        }

        //server.Shutdown();
    }


    //将存入数据库的申请用户数据删除
    static public void Delete(string IP, string Collection, string name)//连接数据库
    {
        MongoServer server = MongoServer.Create(IP);//连接服务器
        MongoDatabase db = server.GetDatabase("centerdb");//连接到数据库
        //连接到数据集合user1中
        MongoCollection<BsonDocument> collection = db.GetCollection<BsonDocument>(Collection);
        IMongoQuery query = Query.EQ("userid", name);//建立查询条件
        collection.Remove(query);//删除user1集合中符合查询条件query的文档
        //server.Shutdown();
    }
}