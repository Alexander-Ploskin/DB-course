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

        private DataView archive;

        public DataView Archive { get => archive; set => Set(ref archive, value); }

        private string statusMessage = "";

        public string StatusMessage { get => statusMessage; set => Set(ref statusMessage, value); }

        public ICommand GetDataCommand { get; }

        private async Task OnGetDataCommandExecuted(object parameter)
        {
        }

        private bool CanGetDataCommandExecute(object parameter)
        {
            return true;
        }

        public void Dispose()
        {
            Archive.Dispose();
        }
    }
}
