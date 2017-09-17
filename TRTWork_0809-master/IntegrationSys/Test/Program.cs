using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommonPortCmd;



namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {
            Common com = new Common();

            com.ConnectPort();

            string rec;
            com.SendCommand("1站产品到位检测", out rec);

            //com.RecDataSendEventHander += Com_RecDataSendEventHander;

            Console.WriteLine(rec);

            Console.Read();

        }

        private static void Com_RecDataSendEventHander(object send, ActiveReporting e)
        {
            throw new NotImplementedException();
        }
    }
}
