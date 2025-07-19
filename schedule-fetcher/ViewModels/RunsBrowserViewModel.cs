using System.Windows.Controls;
using Caliburn.Micro;
using schedule_fetcher.Models;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class RunsBrowserViewModel : Screen
{
    private readonly SpreadsheetClient.SpreadsheetClient _spreadsheet;
    private readonly SelectedRunService _selectedRun;
    private string _search = string.Empty;
    private readonly BindableCollection<RunModel> _runs = [];
    private readonly BindableCollection<RunModel> _runsView = [];
    private RunModel? _currentlySelectedRun;

    public RunsBrowserViewModel(SpreadsheetClient.SpreadsheetClient spreadsheet, SelectedRunService selectedRun)
    {
        _spreadsheet = spreadsheet;
        _selectedRun = selectedRun;
        
        _runs.AddRange(_spreadsheet.GetRuns());
        _runsView.AddRange(_runs);
    }

    private void DoSearch()
    {
        _runsView.Clear();
        _runsView.AddRange(_runs.Where(r => r.ToString().Contains(Search, StringComparison.InvariantCultureIgnoreCase)));
    }

    public void ChangeSelectedRun(SelectionChangedEventArgs e)
    {
        _currentlySelectedRun = e.AddedItems.Cast<RunModel>().First();
    }

    public void Select()
    {
        _selectedRun.SetSelectedRun(_currentlySelectedRun);
        TryCloseAsync();
    }

    public string Search
    {
        get => _search;
        set
        {
            if (_search == value)
            {
                return;
            }
            
            _search = value;
            DoSearch();
        }
        
    }

    public BindableCollection<RunModel> Runs => _runsView;
}