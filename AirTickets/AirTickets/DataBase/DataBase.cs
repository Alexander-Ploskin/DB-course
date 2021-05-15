using System;
using System.Data;
using System.Threading.Tasks;
using Npgsql;

namespace DataBase
{
    public class DataBase : IDisposable
    {
        private const string Server = "localhost";
        private const int Port = 5432;
        private const string Database = "postgres";
        private const string UserId = "postgres";
        private readonly static string password = Environment.GetEnvironmentVariable("DbPassword");
        private NpgsqlConnection connection;

        public DataBase(NpgsqlConnection connection)
        {
            this.connection = connection;
        }

        public static DataBase Connect()
        {
             var connection = new NpgsqlConnection($"Server={Server};Port={Port};Database={Database};User Id={UserId};Password={password};");
            connection.Open();
            return new DataBase(connection);
        }

        public DataTable GetPlanes()
        {
            using var command = new NpgsqlCommand("select * from planes", connection) { CommandType = CommandType.Text };
            using var reader = command.ExecuteReader();
            var result = new DataTable();
            result.Load(reader);
            return result;
        }

        public void Dispose()
        {
            connection.Dispose();
        }
    }
}
