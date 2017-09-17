using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommonPortCmd;

namespace ComportTest
{
    class Program
    {
        static void Main(string[] args)
        {
            Common com = new Common();
            com.ConnectPort();
            com.RecDataSendEventHander += Com_RecDataSendEventHander;


        }

        private static void Com_RecDataSendEventHander(object send, ActiveReporting e)
        {
            throw new NotImplementedException();
        }
    }
}
