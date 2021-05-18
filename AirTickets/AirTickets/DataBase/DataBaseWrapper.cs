using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Npgsql;

namespace DataBase
{
    public static class DataBaseWrapper
    {
        private const string Server = "localhost";
        private const int Port = 5432;
        private const string Database = "airtickets";
        private const string UserId = "postgres";
        private readonly static string password = Environment.GetEnvironmentVariable("DbPassword");

        private static async Task<DataTable> DoRequestAsync(string request)
        {
            try
            {
                using var connection = new NpgsqlConnection($"Server={Server};Port={Port};Database={Database};User Id={UserId};Password={password};");
                await connection.OpenAsync();
                using var command = new NpgsqlCommand(request, connection) { CommandType = CommandType.Text };
                using var reader = await command.ExecuteReaderAsync();
                var result = new DataTable();
                result.Load(reader);
                return result;
            }
            catch(Exception)
            {
                return new DataTable();
            }
        }

        public static async Task InsertFlight(string flightNumber, string departureDate)
        {
            await DoRequestAsync($"INSERT INTO Flights VALUES ('{flightNumber}', 0, '{departureDate}');");
        }

        public static async Task<bool> InsertPassenger(string name, string surname, string patronymic, string id, string flightNumber, string departureDate)
        {
            if (patronymic == null || patronymic == "")
            {
                patronymic = "NULL";
            }

            var splittedDepartureDate = departureDate.Split(".");
            var day = splittedDepartureDate[0];
            var month = splittedDepartureDate[1];
            var year = splittedDepartureDate[2];

            departureDate = $"{year}-{month}-{day}";

            await DoRequestAsync($"INSERT INTO Customers VALUES ('{id}', '{name}', '{surname}', '{patronymic}');");

            await DoRequestAsync($"INSERT INTO Passengers VALUES ('{id}', '{flightNumber}', '{departureDate}');");

            return true;
        }

        public static async Task<int> GetFreeTickets(string flightNumber, string departureDate)
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

        public static async Task<DataTable> GetScheduleAsync() => await DoRequestAsync("select * from schedule;");

        public static async Task<DataTable> GetArchiveAsync() => await DoRequestAsync("select * from archive order by DepartureDate;");

        public static async Task<DataTable> GetFlightInfo(string flightNumber, string departureDate, int totalTickets)
        {
            await DoRequestAsync($"insert into flights values ('{flightNumber}', {totalTickets}, 0, '{departureDate}');");
            return await DoRequestAsync($"select * from flights where FlightNumber = '{flightNumber}'");
        }

        public static async Task<DataRowCollection> GetAirports()
        {
            var result = await DoRequestAsync("select * from airports");
            return result.Rows;
        }

        public static async Task<DataRowCollection> GetPlanes()
        {
            var result = await DoRequestAsync("select * from planes");
            return result.Rows;
        }

        public static async Task InsertAirport(string iataCode, string place)
        {
            try
            {
                await DoRequestAsync($"insert into places values ('{place}')");
                await DoRequestAsync($"INSERT INTO Airports VALUES ('{iataCode}', '{place}');");
            }
            catch (Exception)
            {
                await DoRequestAsync($"INSERT INTO Airports VALUES ('{iataCode}', '{place}');");
            }
        }

        public static async Task InsertPlane(string id, string producer, string model)
        {
            await DoRequestAsync($"INSERT INTO Producers VALUES('{producer}');");
            await DoRequestAsync($"INSERT INTO Models VALUES('{producer}', '{model}');");
            await DoRequestAsync($"INSERT INTO Planes VALUES('{id}', '{producer} {model}');");
        }

        public static async Task InsertSchedule(string id, string departureAirport, string arrivalAirport, int weekdayNumber, 
            string departureTime, string flightTime, int totalTickets, string plane, int ticketCost)
        {
            await DoRequestAsync($"INSERT INTO Schedule VALUES('{id}', '{departureAirport}', '{arrivalAirport}', '{weekdayNumber}', '{departureTime}', '{flightTime}', '{totalTickets}', '{plane}', '{ticketCost}');");
        }

        public static async Task UpdateSchedule(string id, string propertyName, string newValue)
        {
            await DoRequestAsync($"UPDATE Schedule SET {propertyName} = '{newValue}' WHERE ID = '{id}';");
        }

        public static async Task  RemoveFlight(string id)
        {
            await DoRequestAsync($"DELETE FROM Schedule WHERE ID = '{id}';");
        }
    }
}
