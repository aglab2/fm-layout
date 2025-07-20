using System.Windows;
using System.Windows.Controls;
using Caliburn.Micro;
using schedule_fetcher.Models;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class RunsBrowserViewModel(SpreadsheetClient.SpreadsheetClient spreadsheet, SelectedRunService selectedRun) : Screen
{
    private string? _search = string.Empty;
    private readonly BindableCollection<RunModel> _runs = [];
    private readonly BindableCollection<RunModel> _runsView = [];
    private RunModel? _currentlySelectedRun;
    private bool _isFetching = false;

    protected override Task OnInitializeAsync(CancellationToken cancellationToken)
    {
        Activated += OnActivated;
        
        return base.OnInitializeAsync(cancellationToken);
    }

    private async void OnActivated(object? sender, ActivationEventArgs _)
    {
        try
        {
            _isFetching = true;
            NotifyOfPropertyChange(nameof(IsFetchingVis));
            NotifyOfPropertyChange(nameof(IsNotFetching));

            var fetchTask = Task.Factory.StartNew(() =>
            {
                _runs.AddRange(spreadsheet.GetRuns());
                _runsView.AddRange(_runs);
            });
        
            await fetchTask;

            _isFetching = false;
            NotifyOfPropertyChange(nameof(IsFetchingVis));
            NotifyOfPropertyChange(nameof(IsNotFetching));
        }
        catch (Exception e)
        {
            // ignored
        }
    }

    private void DoSearch()
    {
        _runsView.Clear();
        if (Search == null)
        {
            _runsView.AddRange(_runs);
            return;
        }
        
        _runsView.AddRange(_runs.Where(r => r.ToString().Contains(Search, StringComparison.InvariantCultureIgnoreCase)));
    }

    public void ChangeSelectedRun(SelectionChangedEventArgs e)
    {
        if (e.AddedItems.Count == 0)
        {
            _currentlySelectedRun = null;
            NotifyOfPropertyChange(nameof(CanSelect));
            return;
        }
        
        _currentlySelectedRun = e.AddedItems.Cast<RunModel>().First();
        NotifyOfPropertyChange(nameof(CanSelect));
    }

    public void Select()
    {
        selectedRun.SetSelectedRun(_currentlySelectedRun);
        TryCloseAsync();
    }

    public string? Search
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

    public bool IsNotFetching => !_isFetching; 
    public Visibility IsFetchingVis => _isFetching ? Visibility.Visible : Visibility.Collapsed;
    public bool CanSelect => _currentlySelectedRun != null;
    public BindableCollection<RunModel> Runs => _runsView;
}