using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Sockets;
using System.Net;
using System.Threading;
using IntegrationSys.LogUtil;
using System.IO;
using System.Collections;
using Newtonsoft.Json;
using IntegrationSys.Equipment;

namespace IntegrationSys.Net
{
    /// <summary>
    /// 简单的数据交互 服务器端
    /// </summary>
    class LiteDataServer
    {
        public delegate void InplaceEventHandler(int index);
        public delegate void CompleteEventHandler(int index);
        public delegate void PickPlaceEventHandler();

        /// <summary>
        /// 产品到位  事件
        /// </summary>
        public event InplaceEventHandler InplaceEvent;
        /// <summary>
        /// 测试是完成事件
        /// </summary>
        public event CompleteEventHandler CompleteEvent;
        /// <summary>
        /// 产品离开  事件
        /// </summary>
        public event PickPlaceEventHandler PickPlaceEvent;

        private static LiteDataServer instance_;

        private LiteDataServer()
        { 
        }

        public static LiteDataServer Instance
        {
            get
            {
                if (instance_ == null)
                {
                    instance_ = new LiteDataServer();
                }

                return instance_;
            }
        }

        private TcpListener server;
        private bool exit = false;


       /// <summary>
       /// 服务器开始工作
       /// </summary>
        public void Start()
        {
            exit = false;

            IPAddress localAddr = IPAddress.Parse(NetUtil.LocalIp());
            server = new TcpListener(localAddr, NetUtil.PORT_LITE_DATA_SERVER);

            server.Start();

            while (!exit)
            {
                TcpClient client = server.AcceptTcpClient();
                ThreadPool.QueueUserWorkItem(new WaitCallback(ThreadProc), client);
            }
        }

        public void Stop()
        {
            exit = true;
            server.Stop();
        }



        /// <summary>
        /// 服务器端线程池，接收客户端的信息并处理
        /// </summary>
        /// <param name="state"></param>
        private void ThreadProc(Object state)
        {
            TcpClient client = (TcpClient)state;

            NetworkStream stream = client.GetStream();
            Byte[] bytes = new Byte[1024];
            int len = stream.Read(bytes, 0, bytes.Length);

            if (len > 0)
            {
                String data = System.Text.Encoding.UTF8.GetString(bytes, 0, len);
                Log.Debug("LiteDataServer receive " + data);
                if (data.StartsWith("Inplace"))
                {
                    int pos = data.IndexOf(' ');
                    if (pos != -1)
                    {
                        String strIndex = data.Substring(pos + 1);
                        int index = Int32.Parse(strIndex);
                        if (InplaceEvent != null)
                        {
                            InplaceEvent(index);
                        }
                    }
                    byte[] response = new byte[4];
                    stream.Write(response, 0, response.Length);
                }
                else if (data.StartsWith("Complete"))
                {
                    int pos = data.IndexOf(' ');
                    if (pos != -1)
                    {
                        String strIndex = data.Substring(pos + 1);
                        int index = Int32.Parse(strIndex);
                        if (CompleteEvent != null)
                        {
                            CompleteEvent(index);
                        }
                    }
                    byte[] response = new byte[4];
                    stream.Write(response, 0, response.Length);
                }
                else if (data.StartsWith("PickPlace"))
                {
                    if (PickPlaceEvent != null)
                    {
                        PickPlaceEvent();
                    }
                    byte[] response = new byte[4];
                    stream.Write(response, 0, response.Length);
                }
                else if (data.StartsWith("TargetIp"))
                {
                    int pos = data.IndexOf(' ');
                    if (pos != -1)
                    {
                        String strIndex = data.Substring(pos + 1);
                        int index = Int32.Parse(strIndex);
                        string ip = GetIp(index);
                        Log.Debug("phone ip = " + ip);
                        byte[] response = System.Text.Encoding.UTF8.GetBytes(ip);
                        stream.Write(response, 0, response.Length);
                    }
                }
                else
                {
                    LiteData liteData = JsonConvert.DeserializeObject<LiteData>(data);
                    if (liteData.Name == "RemoteEquipmentCmd")
                    {
                        if (liteData.Paramters != null && liteData.Paramters.Length >= 2)
                        {
                            string result;
                            EquipmentCmd.Instance.SendCommand(liteData.Paramters[0], liteData.Paramters[1], out result);

                            byte[] response = System.Text.Encoding.UTF8.GetBytes(result);
                            stream.Write(response, 0, response.Length);
                        }
                    }
                }
            }
            stream.Close();
            client.Close();

        }

        /// <summary>
        /// 文本文件获取IP地址
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        private static string GetIp(int index)
        {
            string ip = "";
            using (StreamReader sr = new StreamReader("IpList.txt"))
            {
                string line;
                ArrayList list = new ArrayList();
                // Read and display lines from the file until the end of 

                // the file is reached.

                while ((line = sr.ReadLine()) != null)
                {
                    list.Add(line);
                }

                if (list.Count >= index)
                {
                    ip = (string)list[list.Count - index];
                }
            }


            return ip;
        }
    }
}
