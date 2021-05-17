﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Linq;
using AirTickets.Command;
using System.Windows.Controls;
using DataBase;

namespace AirTickets.ViewModel
{
    public class ScheduleViewModel : BaseViewModel, IDisposable
    {
        public ScheduleViewModel()
        {
            currentMin = DateTime.Now;
            Task.Run(() => FillSchedule(currentMin));
            GetDataCommand = new RelayAsyncCommand(OnGetDataCommandExecuted, (ex) => Message = ex.Message, CanGetDataCommandExecute);
            MoveRightCommand = new RelayAsyncCommand(OnMoveRightCommandExecuted, (ex) => Message = ex.Message, CanMoveRightCommandExecute);
            MoveLeftCommand = new RelayAsyncCommand(OnMoveLeftCommandExecuted, (ex) => Message = ex.Message, CanMoveLeftCommandExecute);
            BuyTicketCommand = new RelayAsyncCommand(OnBuyTicketCommandExecuted, (ex) => Message = ex.Message, CanBuyTicketCommandExecute);
        }

        public ICommand BuyTicketCommand { get; }

        private async Task OnBuyTicketCommandExecuted(object parameter)
        {
            await DataBaseWrapper.InsertFlight(selectedFlightNumber, selectedFlightDepartureDate);
            await DataBaseWrapper.InsertPassenger(SelectedName, SelectedSurname, SelectedPatronymic,
                SelectedID, selectedFlightNumber, selectedFlightDepartureDate);
            await FillSchedule(currentMin);
        }

        private bool CanBuyTicketCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(selectedFlightNumber)
                && !string.IsNullOrEmpty(selectedFlightDepartureDate)
                && !string.IsNullOrEmpty(SelectedName)
                && !string.IsNullOrEmpty(SelectedSurname)
                && !string.IsNullOrEmpty(SelectedID);
        }

        private string selectedFlightNumber;

        private string selectedFlightDepartureDate;

        private string selectedName;

        public string SelectedName { get => selectedName; set => Set(ref selectedName, value); }

        private string selectedSurname;

        public string SelectedSurname { get => selectedSurname; set => Set(ref selectedSurname, value); }

        private string selectedPatronymic;

        public string SelectedPatronymic { get => selectedPatronymic; set => Set(ref selectedPatronymic, value); }

        private string selectedID;

        public string SelectedID { get => selectedID; set => Set(ref selectedID, value); }

        private string selectedFlight;

        public string SelectedFlight { get => selectedFlight; set => Set(ref selectedFlight, value); }

        public void FlightSelected (object sender, SelectionChangedEventArgs args)
        {
            var dataRow = (DataRowView)args.AddedItems[0];
            selectedFlightNumber = dataRow.Row.ItemArray[0].ToString();
            selectedFlightDepartureDate = dataRow.Row.ItemArray[3].ToString();
            SelectedFlight = selectedFlightNumber;
            return;
        }

        private int pageNumber;

        private DateTime currentMin;

        public ICommand MoveRightCommand { get; }

        private async Task OnMoveRightCommandExecuted(object parameter)
        {
            pageNumber++;
            currentMin = currentMin.AddDays(7);
            await FillSchedule(currentMin);
        }

        private bool CanMoveRightCommandExecute(object p)
            => VisibleSchedule != null && VisibleSchedule.Table != null && VisibleSchedule.Table.Rows.Count > 0 && pageNumber < 15;

        public ICommand MoveLeftCommand { get; }

        private async Task OnMoveLeftCommandExecuted(object parameter)
        {
            if (pageNumber < 1)
            {
                return;
            }
            pageNumber--;
            currentMin = currentMin.AddDays(-7);

            await FillSchedule(currentMin);
        }

        private bool CanMoveLeftCommandExecute(object p) => pageNumber > 0;

        private bool connected;
        private bool Connected { get => connected; set => Set(ref connected, value); }

        private DataView schedule;

        public DataView VisibleSchedule { get => schedule; set => Set(ref schedule, value); }

        private DataView selectedFlightData;

        public DataView SelectedFlightData { get => selectedFlightData; set => Set(ref selectedFlightData, value); }

        private string message = "";

        public string Message { get => message; set => Set(ref message, value); }

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

        private async Task FillSchedule(DateTime minimum)
        {
            var schedule = await DataBaseWrapper.GetScheduleAsync();
            schedule.Columns.Add(new DataColumn("Departure date", typeof(string)));
            schedule.Columns.Add(new DataColumn("Free seats", typeof(string)));
            foreach (DataRow row in schedule.Rows)
            {
                var intDayOfWeek = int.Parse(row["weekdaynumber"].ToString());
                var dayOfWeek = (DayOfWeek)intDayOfWeek;
                var departureTime = (TimeSpan)row["departuretime"];
                var localMinimum = minimum;
                if (minimum.TimeOfDay.TotalMinutes > departureTime.TotalMinutes + 120)
                {
                    localMinimum = localMinimum.AddDays(1);
                }
                row["Departure date"] = GetNearestDate(dayOfWeek, localMinimum);
                row["Free seats"] = await DataBaseWrapper.GetFreeTickets(row["id"].ToString(), row["Departure date"].ToString());
            }
            schedule.Columns.Remove("weekdaynumber");
            schedule.Columns.Remove("plane");
            schedule.Columns.Remove("totaltickets");
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

        private async Task OnGetDataCommandExecuted(object parameter)
        {
            currentMin = DateTime.Now;
            await FillSchedule(DateTime.Now);
        }

        private bool CanGetDataCommandExecute(object parameter)
        {
            return true;
        }

        public void Dispose()
        {
            VisibleSchedule.Dispose();
        }
    }
}
