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
using System.Collections.ObjectModel;

namespace AirTickets.ViewModel
{
    public class ScheduleViewModel : BaseViewModel, IDisposable
    {
        private async Task RefreshData()
        {
            try
            {
                currentMin = DateTime.Now;
                await FillSchedule(currentMin);

                var airports = await DataBaseWrapper.GetAirports();
                ExistingAirports = new ObservableCollection<string>();
                foreach (var airport in airports)
                {
                    var airportData = (DataRow)airport;
                    ExistingAirports.Add(airportData.ItemArray[0].ToString());
                }

                var planes = await DataBaseWrapper.GetPlanes();
                ExistingPlanes = new ObservableCollection<string>();
                foreach (var plane in planes)
                {
                    var planeData = (DataRow)plane;
                    ExistingPlanes.Add(planeData.ItemArray[0].ToString());
                }
            }
            catch (Exception)
            { }
        }

        public ScheduleViewModel()
        {
            Task.Run(() => RefreshData());
            MoveRightCommand = new RelayAsyncCommand(OnMoveRightCommandExecuted, (ex) => { throw ex; }, CanMoveRightCommandExecute);
            MoveLeftCommand = new RelayAsyncCommand(OnMoveLeftCommandExecuted, (ex) => { throw ex; }, CanMoveLeftCommandExecute);
            BuyTicketCommand = new RelayAsyncCommand(OnBuyTicketCommandExecuted, (ex) => { throw ex; }, CanBuyTicketCommandExecute);
            UpdateFlightDataCommand = new RelayAsyncCommand(OnUpdateFlightDataCommandExecuted, (ex) => { throw ex; }, CanUpdateFlightDataCommandExecute);
            RemoveFlightCommand = new RelayAsyncCommand(OnRemoveFlightCommandExecuted, (ex) => { throw ex; }, CanRemoveFlightCommandExecute);
        }

        public ICommand RemoveFlightCommand { get; }

        private async Task OnRemoveFlightCommandExecuted(object parameter)
        {
            await DataBaseWrapper.RemoveFlight(NewFlightID);

            NewFlightID = null;
            await RefreshData();
        }

        private bool CanRemoveFlightCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(NewFlightID);
        }

        public ICommand UpdateFlightDataCommand { get; }

        private async Task OnUpdateFlightDataCommandExecuted(object parameter)
        {
            var weekdayNumber = DaysOfWeek.IndexOf(NewFlightWeekdayNumber) + 1;

            await DataBaseWrapper.UpdateSchedule(NewFlightID, "DepartureAirport", NewFlightDepartureAirport);
            await DataBaseWrapper.UpdateSchedule(NewFlightID, "ArrivalAirport", NewFlightArrivalAirport);
            await DataBaseWrapper.UpdateSchedule(NewFlightID, "WeekdayNumber", weekdayNumber.ToString());
            await DataBaseWrapper.UpdateSchedule(NewFlightID, "DepartureTime", NewFlightDepartureTime.TimeOfDay.ToString());
            await DataBaseWrapper.UpdateSchedule(NewFlightID, "FlightTime", NewFlightFlightTime.ToString());
            await DataBaseWrapper.UpdateSchedule(NewFlightID, "Plane", NewFlightPlane);
            await DataBaseWrapper.UpdateSchedule(NewFlightID, "TicketCost", NewFlightTicketCost.Value.ToString());

            await RefreshData();
        }

        private bool CanUpdateFlightDataCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(NewFlightID) && !string.IsNullOrEmpty(NewFlightArrivalAirport) && !string.IsNullOrEmpty(NewFlightDepartureAirport)
                && NewFlightTicketCost != null && NewFlightDepartureTime != null && NewFlightFlightTime != null && !string.IsNullOrEmpty(NewFlightWeekdayNumber)
                && !string.IsNullOrEmpty(NewFlightPlane);
        }

        public ICommand BuyTicketCommand { get; }

        private async Task OnBuyTicketCommandExecuted(object parameter)
        {
            await DataBaseWrapper.InsertFlight(NewFlightID, selectedFlightDepartureDate);
            await DataBaseWrapper.InsertPassenger(SelectedName, SelectedSurname, SelectedPatronymic,
                SelectedID, NewFlightID, selectedFlightDepartureDate);
            await RefreshData();
        }

        private bool CanBuyTicketCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(NewFlightID)
                && !string.IsNullOrEmpty(selectedFlightDepartureDate)
                && !string.IsNullOrEmpty(SelectedName)
                && !string.IsNullOrEmpty(SelectedSurname)
                && !string.IsNullOrEmpty(SelectedID);
        }

        private string selectedFlightDepartureDate;

        private int discount;

        public int Discount { get => discount; set => Set(ref discount, value); }

        public string DiscountString { get => $"- {Discount}%"; }

        public int finalPrice;

        public int FinalPrice { get => finalPrice; set => Set(ref finalPrice, value); }

        public string FinalPriceString { get => $"Final price: {FinalPrice}"; }

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

        public async void FlightSelected (object sender, SelectionChangedEventArgs args)
        {
            try
            {
                var dataRow = (DataRowView)args.AddedItems[0];
                var row = dataRow.Row;
                var index = 0;
                while (!fullData.Table.Rows[index].ItemArray[0].Equals(row.ItemArray[0]))
                {
                    index++;
                }
                var dataRow2 = fullData.Table.Rows[index];
                NewFlightID = dataRow2.ItemArray[0].ToString();
                NewFlightDepartureAirport = dataRow2.ItemArray[1].ToString();
                NewFlightArrivalAirport = dataRow2.ItemArray[2].ToString();
                NewFlightWeekdayNumber = ((DayOfWeek)((int)dataRow2.ItemArray[3])).ToString();
                NewFlightDepartureTime = DateTime.Parse(dataRow2.ItemArray[4].ToString());
                NewFlightFlightTime = TimeSpan.Parse(dataRow2.ItemArray[5].ToString());
                NewFlightPlane = dataRow2.ItemArray[7].ToString();
                var cost = dataRow2.ItemArray[8].ToString().Split(",")[0];
                NewFlightTicketCost = int.Parse(cost);

                selectedFlightDepartureDate = dataRow.Row.ItemArray[3].ToString();

                if (!string.IsNullOrEmpty(SelectedID))
                {
                    Discount = await DataBaseWrapper.GetDiscount(SelectedID);
                    OnPropertyChanged(nameof(DiscountString));
                }

                FinalPrice = NewFlightTicketCost.Value - NewFlightTicketCost.Value / 100 * Discount;
                OnPropertyChanged(nameof(FinalPriceString));

                return;
            }
            catch (Exception) { }
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

        private DataView schedule;

        public DataView VisibleSchedule { get => schedule; set => Set(ref schedule, value); }

        private DataView selectedFlightData;

        public DataView SelectedFlightData { get => selectedFlightData; set => Set(ref selectedFlightData, value); }

        private string GetNearestDate(DayOfWeek dayOfWeek, DateTime minimum)
        {
            var day = minimum;
            while (day.DayOfWeek != dayOfWeek)
            {
                day = day.AddDays(1);
            }
            return day.ToString("dd/MM/yyyy");
        }

        private DataView fullData;

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
            fullData = (await DataBaseWrapper.GetScheduleAsync()).DefaultView;
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

            try
            {
                VisibleSchedule = schedule.DefaultView;
                VisibleSchedule.Sort = "Departure date asc, Departure time asc";
            }
            catch (Exception)
            {
                try
                {
                    VisibleSchedule.Sort = "Departure date asc, Departure time asc";
                }
                catch (Exception)
                { }
            }
        }

        private string newFlightID;

        public string NewFlightID { get => newFlightID; set => Set(ref newFlightID, value); }

        private string newFlightArrivalAirport;

        public string NewFlightArrivalAirport { get => newFlightArrivalAirport; set => Set(ref newFlightArrivalAirport, value); }

        private string newFlightDepartureAirport;

        public string NewFlightDepartureAirport { get => newFlightDepartureAirport; set => Set(ref newFlightDepartureAirport, value); }

        private int? newFlightTicketCost;

        public int? NewFlightTicketCost { get => newFlightTicketCost; set => Set(ref newFlightTicketCost, value); }

        private DateTime newFlightDepartureTime;

        public DateTime NewFlightDepartureTime { get => newFlightDepartureTime; set => Set(ref newFlightDepartureTime, value); }

        private TimeSpan? newFlightFlightTime;

        public TimeSpan? NewFlightFlightTime { get => newFlightFlightTime; set => Set(ref newFlightFlightTime, value); }

        public ObservableCollection<string> DaysOfWeek { get; } = new ObservableCollection<string>() { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };

        private string newFlightWeekdayNumber;

        public string NewFlightWeekdayNumber { get => newFlightWeekdayNumber; set => Set(ref newFlightWeekdayNumber, value); }

        private ObservableCollection<string> existingAirports;

        public ObservableCollection<string> ExistingAirports { get => existingAirports; set => Set(ref existingAirports, value); }

        private ObservableCollection<string> existingPlanes;

        public ObservableCollection<string> ExistingPlanes { get => existingPlanes; set => Set(ref existingPlanes, value); }

        private string newFlightPlane;

        public string NewFlightPlane { get => newFlightPlane; set => Set(ref newFlightPlane, value); }

        public void Dispose()
        {
            VisibleSchedule.Dispose();
        }
    }
}
