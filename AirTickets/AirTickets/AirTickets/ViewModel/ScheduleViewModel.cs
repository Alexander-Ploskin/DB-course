using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Linq;
using AirTickets.Command;
using System.Windows.Controls;

namespace AirTickets.ViewModel
{
    public class ScheduleViewModel : BaseViewModel, IDisposable
    {
        public ScheduleViewModel()
        {
            GetDataCommand = new RelayAsyncCommand(OnGetDataCommandExecuted, (ex) => Message = ex.Message, CanGetDataCommandExecute);
            ConnectCommand = new RelayAsyncCommand(OnConnectCommandExecuted, (ex) => Message = ex.Message, CanConnectCommandExecute);
            MoveRightCommand = new RelayCommand(OnMoveRightCommandExecuted, CanMoveRightCommandExecute);
            MoveLeftCommand = new RelayCommand(OnMoveLeftCommandExecuted, CanMoveLeftCommandExecute);
        }

        public void FlightSelected (object sender, SelectionChangedEventArgs args)
        {
            var row = (DataRowView)args.AddedItems[0];
            Message = row.Row.ItemArray.Length.ToString();
            return;
        }

        private int pageNumber;

        public ICommand MoveRightCommand { get; }

        private void OnMoveRightCommandExecuted(object parameter)
        {
            pageNumber++;

            foreach (DataRow row in VisibleSchedule.Table.Rows)
            {
                var departureDate = DateTime.Parse((string)row["Departure date"]);
                row["Departure date"] = departureDate.AddDays(7).ToString("dd/MM/yyyy");
                VisibleSchedule.Sort = "Departure date asc, Departure time asc";
            }
        }

        private bool CanMoveRightCommandExecute(object p)
            => VisibleSchedule != null && VisibleSchedule.Table != null && VisibleSchedule.Table.Rows.Count > 0 && pageNumber < 15;

        public ICommand MoveLeftCommand { get; }

        private void OnMoveLeftCommandExecuted(object parameter)
        {
            if (pageNumber < 1)
            {
                return;
            }
            pageNumber--;

            foreach (DataRow row in VisibleSchedule.Table.Rows)
            {
                var departureDate = DateTime.Parse((string)row["Departure date"]);
                row["Departure date"] = departureDate.AddDays(-7).ToString("dd/MM/yyyy");
                VisibleSchedule.Sort = "Departure date asc, Departure time asc";
            }
        }

        private bool CanMoveLeftCommandExecute(object p) => pageNumber > 0;

        private bool connected;
        private bool Connected { get => connected; set => Set(ref connected, value); }

        private DataBase.DataBaseWrapper dataBase;

        private DataView schedule;

        public DataView VisibleSchedule { get => schedule; set => Set(ref schedule, value); }

        private DataView selectedFlightData;

        public DataView SelectedFlightData { get => selectedFlightData; set => Set(ref selectedFlightData, value); }

        private string message = "";

        public string Message { get => message; set => Set(ref message, value); }

        public ICommand ConnectCommand { get; }

        private async Task OnConnectCommandExecuted(object parameter)
        {
            Message = "not connected";
            dataBase = await DataBase.DataBaseWrapper.ConnectAsync();
            Message = "connected";
            Connected = true;
        }

        private bool CanConnectCommandExecute(object parameter)
        {
            return true;
        }

        public ICommand GetDataCommand { get; }

        private string GetNearestDate(DayOfWeek dayOfWeek, DateTime minimum)
        {
            var day = minimum;
            while (day.DayOfWeek != dayOfWeek)
            {
                day = day.AddDays(1);
            }
            return day.ToString("dd/MM/yyyy");
        }

        private async Task OnGetDataCommandExecuted(object parameter)
        {
            var schedule = await dataBase.GetScheduleAsync();
            schedule.Columns.Add(new DataColumn("Departure date", typeof(string)));
            foreach (DataRow item in schedule.Rows)
            {
                var intDayOfWeek = int.Parse(item["weekdaynumber"].ToString());
                var dayOfWeek = (DayOfWeek)intDayOfWeek;
                var minimum = DateTime.Now;
                var departureTime = (TimeSpan)item["departuretime"];
                if (minimum.TimeOfDay.TotalMinutes > departureTime.TotalMinutes + 120)
                {
                    minimum = minimum.AddDays(1);
                }
                item["Departure date"] = GetNearestDate(dayOfWeek, minimum);
            }
            schedule.Columns.Remove("weekdaynumber");
            schedule.Columns["id"].ColumnName = "Flight";
            schedule.Columns["ticketcost"].ColumnName = "Ticket cost";
            schedule.Columns["departuretime"].ColumnName = "Departure time";
            schedule.Columns["departureairport"].ColumnName = "From";
            schedule.Columns["arrivalairport"].ColumnName = "To";
            schedule.Columns["flighttime"].ColumnName = "Flight time";
            schedule.Columns["Departure date"].SetOrdinal(3);
            VisibleSchedule = schedule.DefaultView;
            VisibleSchedule.Sort = "Departure date asc, Departure time asc";
            Message = "ok";
        }

        private bool CanGetDataCommandExecute(object parameter)
        {
            return dataBase != null && Connected;
        }

        public void Dispose()
        {
            dataBase.Dispose();
            VisibleSchedule.Dispose();
        }
    }
}
