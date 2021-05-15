using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Windows.Input;
using AirTickets.Command;

namespace AirTickets.ViewModel
{
    public class ScheduleViewModel : BaseViewModel, IDisposable
    {
        public ScheduleViewModel()
        {
            IncrementCommand = new RelayCommand(OnIncrementCommandExecuted, CanIncrementCommandExecute);
        }

        public ICommand IncrementCommand { get; }

        private void OnIncrementCommandExecuted(object parameter) => Counter++;

        private bool CanIncrementCommandExecute(object parameter) => true;

        private int counter = 0;

        public int Counter { get => counter; set => Set(ref counter, value); }

        private DataView schedule;

        public DataView Schedule { get => schedule; set => Set(ref schedule, value); }

        private string message = "";

        public string Message { get => message; set => Set(ref message, value); }

        public ICommand GetDataCommand => new GetContactsCommand(this);

        public void Dispose()
        {
            Schedule.Dispose();
        }
    }
}
