using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Threading.Tasks;
using System.Windows.Input;
using AirTickets.Command;
using DataBase;
using System.Linq;

namespace AirTickets.ViewModel
{
    public class FlightsEditorViewModel : BaseViewModel
    {
        public FlightsEditorViewModel()
        {
            Task.Run(() => RefreshData());
            AddAirportCommand = new RelayAsyncCommand(OnAddAirportCommandExecuted, (Exception ex) => { }, CanAddAirportCommandExecute);
            AddNewPlaneCommand = new RelayAsyncCommand(OnAddNewPlaneCommandExecuted, (Exception ex) => { }, CanAddNewPlaneCommandExecute);
            AddNewFlightCommand = new RelayAsyncCommand(OnAddNewFlightCommandExecuted, (Exception ex) => { throw ex; }, CanAddNewFlightCommandExecute);
        }

        private async Task RefreshData()
        {
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

        public ICommand AddAirportCommand { get; }

        private async Task OnAddAirportCommandExecuted(object parameter)
        {
            await RefreshData();
            await DataBaseWrapper.InsertAirport(NewAirportIataCode, NewAirportPlace);
            await RefreshData();
        }

        private bool CanAddAirportCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(NewAirportIataCode) && !string.IsNullOrEmpty(NewAirportPlace);
        }

        private string newAirportIataCode;

        public string NewAirportIataCode { get => newAirportIataCode; set => Set(ref newAirportIataCode, value); }

        private string newAirportPlace;

        public string NewAirportPlace { get => newAirportPlace; set => Set(ref newAirportPlace, value); }

        private string newPlaneID;

        public string NewPlaneID { get => newPlaneID; set => Set(ref newPlaneID, value); }

        private string newPlaneProducer;

        public string NewPlaneProducer { get => newPlaneProducer; set => Set(ref newPlaneProducer, value); }

        private string newPlaneModel;

        public string NewPlaneModel { get => newPlaneModel; set => Set(ref newPlaneModel, value); }

        public ICommand AddNewPlaneCommand { get; }

        private async Task OnAddNewPlaneCommandExecuted(object parameter)
        {
            await RefreshData();
            await DataBaseWrapper.InsertPlane(NewPlaneID, NewPlaneProducer, NewPlaneModel);
            await RefreshData();
        }

        private bool CanAddNewPlaneCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(NewPlaneID) && !string.IsNullOrEmpty(NewPlaneModel) && !string.IsNullOrEmpty(NewPlaneProducer);
        }

        private string newFlightID;

        public string NewFlightID { get => newFlightID; set => Set(ref newFlightID, value); }

        public string NewFlightArrivalAirport { get; set; }

        public string NewFlightDepartureAirport { get; set; }

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

        public string NewFlightPlane { get; set; }

        public ICommand AddNewFlightCommand { get; }

        private async Task OnAddNewFlightCommandExecuted(object parameter)
        {
            await RefreshData();
            var weekdayNumber = DaysOfWeek.IndexOf(NewFlightWeekdayNumber) + 1;
            var departureTime = NewFlightDepartureTime.TimeOfDay.ToString();
            await DataBaseWrapper.InsertSchedule(NewFlightID, NewFlightDepartureAirport, NewFlightArrivalAirport, weekdayNumber,
                departureTime, NewFlightFlightTime.ToString(), 220, NewFlightPlane, NewFlightTicketCost.Value);
            await RefreshData();
        }

        private bool CanAddNewFlightCommandExecute(object parameter)
        {
            return true;
        }
    }
}
