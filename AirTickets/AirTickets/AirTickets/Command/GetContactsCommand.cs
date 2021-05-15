using System;
using System.Collections.Generic;
using System.Text;
using AirTickets.ViewModel;
using System.Threading.Tasks;
using DataBase;

namespace AirTickets.Command
{
    public class GetContactsCommand : AsyncCommandBase
    {
        private readonly ScheduleViewModel scheduleViewModel;

        public GetContactsCommand(ScheduleViewModel scheduleViewModel)
        {
            this.scheduleViewModel = scheduleViewModel;
        }

        protected override async Task ExecuteAsync(object parameter)
        {
            scheduleViewModel.Message = "not connected";
            var dataBase = await DataBase.DataBase.ConnectAsync();
            scheduleViewModel.Message = "connected";
            var schedule = await dataBase.GetScheduleAsync();
            scheduleViewModel.Schedule = schedule.DefaultView;
            scheduleViewModel.Message = "ok";
        }
    }
}
