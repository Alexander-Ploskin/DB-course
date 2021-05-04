using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Npgsql;

namespace AirTickets
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

            var dbPassword = Environment.GetEnvironmentVariable("DBPassword");
            using var connection = new NpgsqlConnection($"Server=localhost;Port=5432;Database=chess;User Id=postgres;Password={dbPassword};");
            connection.Open();
            using var command = new NpgsqlCommand("SELECT count(*) FROM Chessboard;", connection);
            var dataReader = command.ExecuteReader();
            if (dataReader.HasRows)
            {
                var dataTable = new DataTable();
                dataTable.Load(dataReader);
                tableView.ItemsSource = dataTable.DefaultView;
            }
        }
    }
}
