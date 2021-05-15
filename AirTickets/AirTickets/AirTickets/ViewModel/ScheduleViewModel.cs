using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using AirTickets.Command;

namespace AirTickets.ViewModel
{
    public class ScheduleViewModel : BaseViewModel, IDisposable
    {
        public ScheduleViewModel()
        {
            GetDataCommand = new RelayAsyncCommand(OnGetDataCommandExecuted, (ex) => Message = ex.Message, CanGetDataCommandExecute);
            ConnectCommand = new RelayAsyncCommand(OnConnectCommandExecuted, (ex) => Message = ex.Message, CanConnectCommandExecute);
        }

        private bool connected;
        private bool Connected { get => connected; set => Set(ref connected, value); }

        private DataBase.DataBase dataBase;

        private DataView schedule;

        public DataView Schedule { get => schedule; set => Set(ref schedule, value); }

        private string message = "";

        public string Message { get => message; set => Set(ref message, value); }

        public ICommand ConnectCommand { get; }

        private async Task OnConnectCommandExecuted(object parameter)
        {
            Message = "not connected";
            dataBase = await DataBase.DataBase.ConnectAsync();
            Message = "connected";
            connected = true;
        }

        private bool CanConnectCommandExecute(object parameter)
        {
            return true;
        }

        public ICommand GetDataCommand { get; }

        private async Task OnGetDataCommandExecuted(object parameter)
        {
            await Task.Delay(3000);
            var schedule = await dataBase.GetScheduleAsync();
            Schedule = schedule.DefaultView;
            Message = "ok";
        }

        private bool CanGetDataCommandExecute(object parameter)
        {
            return Connected;
        }

        public void Dispose()
        {
            Schedule.Dispose();
        }
    }
}
