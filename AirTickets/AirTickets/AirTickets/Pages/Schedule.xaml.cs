using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using DataBase;
using AirTickets.ViewModel;

namespace AirTickets.Pages
{
    /// <summary>
    /// Interaction logic for Departure.xaml
    /// </summary>
    public partial class Schedule : UserControl
    {
        public Schedule()
        {
            InitializeComponent();
            var vm = (ScheduleViewModel)DataContext;
            schedule.SelectionChanged += vm.FlightSelected;
        }
    }
}
