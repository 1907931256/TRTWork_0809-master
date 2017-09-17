using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class BitConvwetTest
    {
        static void Main(string[] args)
        {
            byte[] byteArray =
            //{ 0, 01, 02, 03, 04, 05 };
            { 52, 05, 01, 01, 255, 71 };
            Console.WriteLine(BitConverter.ToString(byteArray));
            Console.WriteLine();



            BAToInt16(byteArray, 0);
            BAToInt16(byteArray, 1);
            BAToInt16(byteArray, 2);
            BAToInt16(byteArray, 3);
            BAToInt16(byteArray, 4);
            //BAToInt16(byteArray, 5);

            Console.Read();
        }

        public static void BAToInt16(byte[] bytes, int index)
        {
            short value = BitConverter.ToInt16(bytes, index);
            Console.WriteLine(value);
            Console.WriteLine(BitConverter.ToString(bytes, index, 2));
            Console.WriteLine();


            //Console.WriteLine(BitConverter.ToString(bytes,index));
        }

    }
}
