using AirTickets.Command;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using DataBase;

namespace AirTickets.ViewModel
{
    public class ArchiveViewModel : BaseViewModel
    {
        public ArchiveViewModel()
        {
            GetDataCommand = new RelayAsyncCommand(OnGetDataCommandExecuted, (ex) => StatusMessage = ex.Message, CanGetDataCommandExecute);
        }

        private DataBaseWrapper dataBase;
        private DataView archive;

        public DataView Archive { get => archive; set => Set(ref archive, value); }

        private string statusMessage = "";

        public string StatusMessage { get => statusMessage; set => Set(ref statusMessage, value); }

        public ICommand GetDataCommand { get; }

        private async Task OnGetDataCommandExecuted(object parameter)
        {
            var dataBase = await DataBaseWrapper.ConnectAsync();
            var archive = await dataBase.GetArchiveAsync();
            Archive = archive.DefaultView;
            StatusMessage = "ok";
        }

        private bool CanGetDataCommandExecute(object parameter)
        {
            return true;
        }

        public void Dispose()
        {
            dataBase.Dispose();
            Archive.Dispose();
        }
    }
}
