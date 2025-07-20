using Caliburn.Micro;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class TimerViewModel : Screen
{
    private readonly ObsClient.ObsClient _obs;
    private readonly SelectedSceneService _selectedSceneService;

    public TimerViewModel(ObsClient.ObsClient obs, SelectedSceneService selectedSceneService)
    {
        _obs = obs;
        _selectedSceneService = selectedSceneService;

        _selectedSceneService.SceneChanged += SelectedSceneServiceOnSceneChanged;
    }

    public void StartStop()
    {
        _obs.StartStopTimer(_selectedSceneService.GetSelectedScene()!);
    }

    public void PauseContinue()
    {
        _obs.PauseContinueTimer(_selectedSceneService.GetSelectedScene()!);
    }

    public void Reset()
    {
        _obs.ResetTimer(_selectedSceneService.GetSelectedScene()!);
    }
    
    private void SelectedSceneServiceOnSceneChanged(string? selectedScene)
    {
        NotifyOfPropertyChange(nameof(TimerHeader));
        NotifyOfPropertyChange(nameof(IsEnabled));
    }

    public bool IsEnabled => _selectedSceneService.GetSelectedScene() != null;
    public string TimerHeader => _selectedSceneService.GetSelectedScene() == null ? "Control Timer (Please select scene)" : $"Control Timer for {_selectedSceneService.GetSelectedScene()}";
}