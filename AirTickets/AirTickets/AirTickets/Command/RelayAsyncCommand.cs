using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace AirTickets.Command
{
    public class RelayAsyncCommand : AsyncCommandBase
    {
        private Action<Exception> onException;

        private bool isExecuting;

        public bool IsExecuting
        {
            get => isExecuting;
            set
            {
                isExecuting = value;
            }
        }

        private readonly Func<object, Task> execute;
        private readonly Func<object, bool> canExecute;

        /// <summary>
        /// Basic constructor provides to set an action to execute by command and function that tells if action can be executed
        /// </summary>
        /// <param name="execute">Action to be executed</param>
        /// <param name="canExecute">Function that tells if action can be executed</param>
        public RelayAsyncCommand(Func<object, Task> execute, Action<Exception> onException, Func<object, bool> canExecute = null)
        {
            this.execute = execute ?? throw new ArgumentNullException(nameof(execute));
            this.canExecute = canExecute;
            this.onException = onException;
        }

        public override async void Execute(object parameter)
        {
            try
            {
                IsExecuting = true;
                await ExecuteAsync(parameter);
                IsExecuting = false;
            }
            catch (Exception ex)
            {
                IsExecuting = false;
                onException?.Invoke(ex);
            }
        }

        /// <summary>
        /// Returns true if command can be executed
        /// </summary>
        public override bool CanExecute(object parameter) => (canExecute?.Invoke(parameter) ?? true) && !IsExecuting;

        /// <summary>
        /// Invokes action
        /// </summary>
        /// <param name="parameter"></param>
        protected override Task ExecuteAsync(object parameter) => execute(parameter);
    }
}
