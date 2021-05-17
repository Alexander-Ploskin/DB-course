﻿using System;
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

        public async Task<int> GetFreeTickets(string flightNumber, string departureDate)
        {
            var result =
                await DoRequestAsync($"WITH FlightInfo AS (SELECT * FROM Schedule WHERE ID = '{flightNumber}') SELECT (FlightInfo.TotalTickets - SoldTickets) AS FreeTickets FROM Flights LEFT JOIN FlightInfo ON FlightNumber = ID WHERE DepartureDate = '{departureDate}';");
            if (result.Rows.Count == 0 || result.Rows[0].ItemArray[0].GetType() == typeof(DBNull))
            {
                result = await DoRequestAsync($"SELECT TotalTickets FROM Schedule WHERE ID = '{flightNumber}';");
                return (int)result.Rows[0].ItemArray[0];
            }

            return (int)result.Rows[0].ItemArray[0];
        }

        public async Task<DataTable> GetScheduleAsync() => await DoRequestAsync("select * from schedule;");

        public async Task<DataTable> GetArchiveAsync() => await DoRequestAsync("select * from archive order by DepartureDate;");

        public async Task<DataTable> GetFlightInfo(string flightNumber, string departureDate, int totalTickets)
        {
            await DoRequestAsync($"insert into flights values ('{flightNumber}', {totalTickets}, 0, '{departureDate}');");
            return await DoRequestAsync($"select * from flights where FlightNumber = '{flightNumber}'");
        }

        public void Dispose()
        {
            connection.Dispose();
        }
    }
}