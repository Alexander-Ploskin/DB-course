using AirTickets.Command;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace AirTickets.ViewModel
{
    public class ArchiveViewModel : BaseViewModel
    {
        public ArchiveViewModel()
        {
            GetDataCommand = new RelayAsyncCommand(OnGetDataCommandExecuted, (ex) => StatusMessage = ex.Message, CanGetDataCommandExecute);
        }

        private bool connected;
        private bool Connected { get => connected; set => Set(ref connected, value); }

        public DataBase.DataBase DataBase { get; set; } 

        private DataView archive;

        public DataView Archive { get => archive; set => Set(ref archive, value); }

        private string statusMessage = "";

        public string StatusMessage { get => statusMessage; set => Set(ref statusMessage, value); }

        public ICommand GetDataCommand { get; }

        private async Task OnGetDataCommandExecuted(object parameter)
        {
            var archive = await DataBase.GetArchiveAsync();
            Archive = archive.DefaultView;
            StatusMessage = "ok";
        }

        private bool CanGetDataCommandExecute(object parameter)
        {
            return DataBase != null && Connected;
        }

        public void Dispose()
        {
            DataBase.Dispose();
            Archive.Dispose();
        }
    }
}
