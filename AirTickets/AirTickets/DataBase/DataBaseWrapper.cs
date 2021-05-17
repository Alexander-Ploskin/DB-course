using System;
using System.Data;
using System.Threading.Tasks;
using Npgsql;

namespace DataBase
{
    public class DataBaseWrapper : IDisposable
    {
        private const string Server = "localhost";
        private const int Port = 5432;
        private const string Database = "airtickets";
        private const string UserId = "postgres";
        private readonly static string password = Environment.GetEnvironmentVariable("DbPassword");
        private NpgsqlConnection connection;

        public DataBaseWrapper(NpgsqlConnection connection)
        {
            this.connection = connection;
        }

        public static async Task<DataBaseWrapper> ConnectAsync()
        {
            var connection = new NpgsqlConnection($"Server={Server};Port={Port};Database={Database};User Id={UserId};Password={password};");
            await connection.OpenAsync();
            return new DataBaseWrapper(connection);
        }

        private async Task<DataTable> DoRequestAsync(string request)
        {
            using var command = new NpgsqlCommand(request, connection) { CommandType = CommandType.Text };
            using var reader = await command.ExecuteReaderAsync();
            var result = new DataTable();
            result.Load(reader);
            return result;
        }

        public async Task<DataTable> GetScheduleAsync() => await DoRequestAsync("select * from schedule;");

        public async Task<DataTable> GetArchiveAsync() => await DoRequestAsync("select * from archive order by DepartureDate");

        public void Dispose()
        {
            connection.Dispose();
        }
    }
}
