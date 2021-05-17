using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Threading.Tasks;
using System.Windows.Input;
using AirTickets.Command;
using DataBase;

namespace AirTickets.ViewModel
{
    public class FlightsEditorViewModel : BaseViewModel
    {
        public FlightsEditorViewModel()
        {
            RefreshDataCommand = new RelayAsyncCommand(OnRefreshDataCommandExecuted, (Exception ex) => { }, CanRefreshDataCommandExecute);
            AddAirportCommand = new RelayAsyncCommand(OnAddAirportCommandExecuted, (Exception ex) => { }, CanAddAirportCommandExecute);
        }

        private DataBaseWrapper dataBase;

        public ICommand RefreshDataCommand { get; }

        private async Task OnRefreshDataCommandExecuted(object parameter)
        {
            dataBase = await DataBaseWrapper.ConnectAsync();
            var airports = await dataBase.GetAirports();
            ExistingAirports = new ObservableCollection<string>();
            foreach (var airport in airports)
            {
                var airportData = (DataRow)airport;
                ExistingAirports.Add(airportData.ItemArray[0].ToString());
            }
        }

        private bool CanRefreshDataCommandExecute(object parameter) => true;

        public ICommand AddAirportCommand { get; }

        private async Task OnAddAirportCommandExecuted(object parameter)
        {
            await dataBase.InsertAirport(NewAirportIataCode, NewAirportPlace);
        }

        private bool CanAddAirportCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(NewAirportIataCode) && !string.IsNullOrEmpty(NewAirportPlace);
        }

        private string newAirportIataCode;

        public string NewAirportIataCode { get => newAirportIataCode; set => Set(ref newAirportIataCode, value); }

        private string newAirportPlace;

        public string NewAirportPlace { get => newAirportPlace; set => Set(ref newAirportPlace, value); }

        private ObservableCollection<string> existingAirports;

        public ObservableCollection<string> ExistingAirports { get => existingAirports; set => Set(ref existingAirports, value); }
    }
}
