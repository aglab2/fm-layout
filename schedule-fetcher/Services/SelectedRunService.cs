using schedule_fetcher.Models;

namespace schedule_fetcher.Services;

public class SelectedRunService
{
    private RunModel? _selectedRun = null;
    
    public delegate void RunChangedHandler(RunModel? selectedRun);
    
    public event RunChangedHandler? RunChanged;

    public void SetSelectedRun(RunModel? selectedRun)
    {
        _selectedRun = selectedRun;
        RunChanged?.Invoke(selectedRun);
    }

    public RunModel? GetSelectedRun()
    {
        return _selectedRun;
    }
}