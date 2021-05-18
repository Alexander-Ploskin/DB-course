using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Input;
using DataBase;
using AirTickets.Command;

namespace AirTickets.ViewModel
{
    public class TicketsViewModel : BaseViewModel
    {
        private async Task RefreshData()
        {
            try
            {
                var table = (await DataBaseWrapper.GetTickets());
                table.Columns.Add(new DataColumn("Date", typeof(string)));
                table.Columns["customer"].ColumnName = "Customer ID";
                table.Columns["flightnumber"].ColumnName = "Flight";
                foreach (DataRow row in table.Rows)
                {
                    var date = (DateTime)row["departuredate"];
                    row["Date"] = date.Date.ToString("dd/MM/yyyy");
                }
                table.Columns.Remove("departuredate");
                table.Columns.Remove("flightnumber1");
                table.Columns.Remove("soldtickets");
                table.Columns.Remove("departuredate1");

                TicketsData = table.DefaultView;
            }
            catch (Exception) { }
        }

        public TicketsViewModel()
        {
            Task.Run(() => RefreshData());
            RemoveTicketCommand = new RelayAsyncCommand(OnRemoveTicketCommandExecuted, (ex) => { }, CanRemoveTicketCommandExecute);
        }

        public ICommand RemoveTicketCommand { get; }

        private async Task OnRemoveTicketCommandExecuted(object parameter)
        {
            try
            {
                await DataBaseWrapper.RemoveTicket(ID, flightNumber, Date);
                flightNumber = null;
                await RefreshData();
            }
            catch (Exception) { }
        }

        private bool CanRemoveTicketCommandExecute(object parameter)
        {
            return !string.IsNullOrEmpty(ID) && !string.IsNullOrEmpty(flightNumber) && !string.IsNullOrEmpty(Date);
        }

        private string flightNumber;

        private string id;

        public string ID { get => id; set => Set(ref id, value); }

        private string name;

        public string Name { get => name; set => Set(ref name, value); }

        private string surname;

        public string Surname { get => surname; set => Set(ref surname, value); }

        private string patronymic;

        public string Patronymic { get => patronymic; set => Set(ref patronymic, value); }

        private string departure;

        public string Departure { get => departure; set => Set(ref departure, value); }

        private string destination;

        public string Destination { get => destination; set => Set(ref destination, value); }

        private string date;

        public string Date { get => date; set => Set(ref date, value); }

        public async void TicketSelected(object sender, SelectionChangedEventArgs args)
        {
            try
            {
                var dataRow = (DataRowView)args.AddedItems[0];
                var row = dataRow.Row;

                var customerData = await DataBaseWrapper.GetCustomerData((string)row.ItemArray[0]);
                ID = (string)customerData.ItemArray[0];
                Name = (string)customerData.ItemArray[1];
                Surname = (string)customerData.ItemArray[2];
                Patronymic = "";
                try
                {
                    Patronymic = (string)customerData.ItemArray[3];

                    var flightData = await DataBaseWrapper.GetFlightData((string)row.ItemArray[1]);
                    flightNumber = (string)flightData.ItemArray[0];
                    Departure = (string)flightData.ItemArray[1];
                    Destination = (string)flightData.ItemArray[2];
                    Date = row["Date"].ToString();
                }
                catch (Exception)
                {
                    var flightData = await DataBaseWrapper.GetFlightData((string)row.ItemArray[1]);
                    flightNumber = (string)flightData.ItemArray[0];
                    Departure = (string)flightData.ItemArray[1];
                    Destination = (string)flightData.ItemArray[2];
                    Date = row["Date"].ToString();
                }
            }
            catch (Exception)
            { }
        }

        private DataView ticketsData;

        public DataView TicketsData { get => ticketsData; set => Set(ref ticketsData, value); }
    }
}
