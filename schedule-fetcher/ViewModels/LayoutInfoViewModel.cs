using Caliburn.Micro;
using schedule_fetcher.Models;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class LayoutInfoViewModel : Screen
{
    private readonly ObsClient.ObsClient _obs;
    private readonly SelectedSceneService _selectedScene;
    private readonly SelectedRunService _runService;
    private readonly IWindowManager _windowManager;
    private RunModel? _selectedRun;

    public LayoutInfoViewModel(ObsClient.ObsClient obs, SelectedSceneService selectedScene, SelectedRunService selectedRun, IWindowManager windowManager)
    {
        _obs = obs;
        _selectedScene = selectedScene;
        _runService = selectedRun;
        _windowManager = windowManager;
        _selectedScene.SceneChanged += SelectedSceneOnSceneChanged;
        _runService.RunChanged += SelectedRunOnRunChanged;
    }

    private void SelectedRunOnRunChanged(RunModel? selectedRun)
    {
        _selectedRun = selectedRun;
        NotifyOfPropertyChange(nameof(SelectedRun));
        if (_selectedRun == null)
        {
            return;
        }
        
        GameName = _selectedRun.GameName;
        CreatedBy = _selectedRun.CreatedBy;
        Category = _selectedRun.Category;
        Estimate = _selectedRun.Estimate;
        Runner1 = _selectedRun.Runners[0];
        Runner2 = _selectedRun.Runners[1];
        Runner3 = _selectedRun.Runners[2];
        Runner4 = _selectedRun.Runners[3];
        Runner1HasWebCam = _selectedRun.RunnerHasWebcam[0];
        Runner2HasWebCam = _selectedRun.RunnerHasWebcam[1];
        Runner1Pronouns = _selectedRun.RunnerPronouns[0];
        Runner2Pronouns = _selectedRun.RunnerPronouns[1];
        Runner3Pronouns = _selectedRun.RunnerPronouns[2];
        Runner4Pronouns = _selectedRun.RunnerPronouns[3];
        Commentator1 = _selectedRun.Commentators[0];
        Commentator2 = _selectedRun.Commentators[1];
        Commentator3 = _selectedRun.Commentators[2];
        Commentator4 = _selectedRun.Commentators[3];
        Commentator1Pronouns = _selectedRun.CommentatorPronouns[0];
        Commentator2Pronouns = _selectedRun.CommentatorPronouns[1];
        Commentator3Pronouns = _selectedRun.CommentatorPronouns[2];
        Commentator4Pronouns = _selectedRun.CommentatorPronouns[3];
        
        NotifyOfPropertyChange(nameof(Category));
        NotifyOfPropertyChange(nameof(Estimate));
        NotifyOfPropertyChange(nameof(GameName));
        NotifyOfPropertyChange(nameof(CreatedBy));
        NotifyOfPropertyChange(nameof(Runner1));
        NotifyOfPropertyChange(nameof(Runner2));
        NotifyOfPropertyChange(nameof(Runner3));
        NotifyOfPropertyChange(nameof(Runner4));
        NotifyOfPropertyChange(nameof(Runner1HasWebCam));
        NotifyOfPropertyChange(nameof(Runner2HasWebCam));
        NotifyOfPropertyChange(nameof(Runner1Pronouns));
        NotifyOfPropertyChange(nameof(Runner2Pronouns));
        NotifyOfPropertyChange(nameof(Runner3Pronouns));
        NotifyOfPropertyChange(nameof(Runner4Pronouns));
        NotifyOfPropertyChange(nameof(Commentator1));
        NotifyOfPropertyChange(nameof(Commentator2));
        NotifyOfPropertyChange(nameof(Commentator3));
        NotifyOfPropertyChange(nameof(Commentator4));
        NotifyOfPropertyChange(nameof(Commentator1Pronouns));
        NotifyOfPropertyChange(nameof(Commentator2Pronouns));
        NotifyOfPropertyChange(nameof(Commentator3Pronouns));
        NotifyOfPropertyChange(nameof(Commentator4Pronouns));
    }

    private void SelectedSceneOnSceneChanged(string? selectedScene)
    {
        NotifyOfPropertyChange(nameof(CanSend));
        NotifyOfPropertyChange(nameof(SceneToSendTo));
    }

    public void SelectRun()
    {
        _windowManager.ShowDialogAsync(IoC.Get<RunsBrowserViewModel>());
    }

    public void SendToScene()
    {
        var selectedScene = _selectedScene.GetSelectedScene();
        if (selectedScene == null)
        {
            return;
        }
        
        _obs.SendToScene(selectedScene, new RunModel
        {
            GameName = GameName,
            CreatedBy = CreatedBy,
            Category = Category,
            Estimate = Estimate,
            Runners = [
                Runner1,
                Runner2,
                Runner3,
                Runner4,
            ],
            RunnerPronouns = [
                Runner1Pronouns,
                Runner2Pronouns,
                Runner3Pronouns,
                Runner4Pronouns
            ],
            Commentators = [
                Commentator1,
                Commentator2,
                Commentator3,
                Commentator4
            ],
            CommentatorPronouns = [
                Commentator1Pronouns,
                Commentator2Pronouns,
                Commentator3Pronouns,
                Commentator4Pronouns
            ],
            RunnerHasWebcam = [
                Runner1HasWebCam,
                Runner2HasWebCam
            ],
            WindowWidth = WindowWidth,
            WindowHeight = WindowHeight
        });
    }
    
    public string SelectedRun => _selectedRun?.ToString() ?? "No run selected";

    public string SceneToSendTo => _selectedScene.GetSelectedScene() != null ? $"Send to {_selectedScene.GetSelectedScene()}" : "No scene selected";
    public bool CanSend => _selectedScene.GetSelectedScene() != null;
    
    public string GameName { get; set; } = string.Empty;
    public string CreatedBy { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Estimate { get; set; } = string.Empty;
    public string Runner1 { get; set; } = string.Empty;
    public bool Runner1HasWebCam { get; set; }
    public string Runner2 { get; set; } = string.Empty;
    public bool Runner2HasWebCam { get; set; }
    public string Runner3 { get; set; } = string.Empty;
    public string Runner4 { get; set; } = string.Empty;
    public string Runner1Pronouns { get; set; } = string.Empty;
    public string Runner2Pronouns { get; set; } = string.Empty;
    public string Runner3Pronouns { get; set; } = string.Empty;
    public string Runner4Pronouns { get; set; } = string.Empty;
    public string Commentator1 { get; set; } = string.Empty;
    public string Commentator2 { get; set; } = string.Empty;
    public string Commentator3 { get; set; } = string.Empty;
    public string Commentator4 { get; set; } = string.Empty;
    public string Commentator1Pronouns { get; set; } = string.Empty;
    public string Commentator2Pronouns { get; set; } = string.Empty;
    public string Commentator3Pronouns { get; set; } = string.Empty;
    public string Commentator4Pronouns { get; set; } = string.Empty;
    public int WindowWidth { get; set; }
    public int WindowHeight { get; set; }
}