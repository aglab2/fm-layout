using Caliburn.Micro;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class TimerViewModel : Screen
{
    private readonly ObsClient.ObsClient _obs;
    private readonly SelectedSceneService _selectedSceneService;
    
    public delegate void TimerStartedHandler();
    public delegate void TimerStoppedHandler();
    public delegate void TimerContinuedHandler();
    public delegate void TimerPausedHandler();

    public delegate void TimerResetHandler();
    
    public event TimerStartedHandler? TimerStarted;
    public event TimerStoppedHandler? TimerStopped;
    public event TimerContinuedHandler? TimerContinued;
    public event TimerPausedHandler? TimerPaused;
    public event TimerResetHandler? TimerReset;
    

    public TimerViewModel(ObsClient.ObsClient obs, SelectedSceneService selectedSceneService)
    {
        _obs = obs;
        _selectedSceneService = selectedSceneService;

        _selectedSceneService.SceneChanged += SelectedSceneServiceOnSceneChanged;
    }

    public void StartStop()
    {
        if (_obs.StartStopTimer(_selectedSceneService.GetSelectedScene()!))
        {
            TimerStarted?.Invoke();
        }
        else
        {
            TimerStopped?.Invoke();
        }
    }

    public void PauseContinue()
    {
        if (_obs.PauseContinueTimer(_selectedSceneService.GetSelectedScene()!))
        {
            TimerContinued?.Invoke();
        }
        else
        {
            TimerPaused?.Invoke();
        }
    }

    public void Reset()
    {
        _obs.ResetTimer(_selectedSceneService.GetSelectedScene()!);
        TimerReset?.Invoke();
    }
    
    private void SelectedSceneServiceOnSceneChanged(string? selectedScene)
    {
        NotifyOfPropertyChange(nameof(TimerHeader));
        NotifyOfPropertyChange(nameof(IsEnabled));
    }

    public bool IsEnabled => _selectedSceneService.GetSelectedScene() != null;
    public string TimerHeader => _selectedSceneService.GetSelectedScene() == null ? "Control Timer (Please select scene)" : $"Control Timer for {_selectedSceneService.GetSelectedScene()}";
}