using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace AirTickets.Command
{
    public abstract class AsyncCommandBase : ICommand
    {
        public event EventHandler CanExecuteChanged;

        private bool isExecuting;

        public bool IsExecuting
        {
            get => isExecuting;
            set
            {
                isExecuting = value;
                CanExecuteChanged?.Invoke(this, EventArgs.Empty);
            }
        }

        public bool CanExecute(object parameter)
        {
            return !IsExecuting;
        }

        public async void Execute(object parameter)
        {
            IsExecuting = true;
            await ExecuteAsync(parameter);
            IsExecuting = false;
        }

        protected abstract Task ExecuteAsync(object parameter);
    }
}
