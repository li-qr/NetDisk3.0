using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
/// <summary>
/// myConverter 的摘要说明
/// </summary>
public class myConverter
{
    static public string DataTable2Json(DataTable dt)
    {
        string json = "";
        json += "[";
        int j = 0;
        string[] name={"filename","size","retime","id"};
        foreach (DataRow dr in dt.Rows)
        {
            j++;
            json += "{";
            for (int i = 0; i < dr.ItemArray.Count(); i++)
            {
                json += "\""+name[i]+"\":\"" + dr[i].ToString() + "\"";
                if (i != dr.ItemArray.Count() - 1)
                {
                    json += ",";
                }
            }
            json += "}";
            if (j != dt.Rows.Count) { json += ","; }
        }
        json += "]";
        return json;
    }
}