using System.Windows.Controls;
using Caliburn.Micro;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class SceneInfoViewModel : Screen
{
    private readonly ObsClient.ObsClient _obs;
    private readonly SelectedSceneService _selectedScene;
    private readonly IWindowManager _windowManager;
    private string? _search;
    private BindableCollection<string> _scenesView = [];
    private BindableCollection<string> _scenes = [];

    public SceneInfoViewModel(ObsClient.ObsClient obs, SelectedSceneService selectedScene, IWindowManager windowManager)
    {
        _obs = obs;
        _selectedScene = selectedScene;
        _windowManager = windowManager;

        _obs.SceneChanged += ObsOnSceneChanged;
        _obs.SceneListChanged += ObsOnSceneListChanged;
        _obs.Connected += ObsOnConnected;
        _obs.Disconnected += ObsOnDisconnected;
    }

    private void ObsOnSceneListChanged()
    {
        var scenes = _obs.GetSceneNames();
        ObsScenes.Clear();
        _scenesView.Clear();
        _scenesView.AddRange(scenes);
        _scenes.AddRange(scenes);
    }

    private void ObsOnDisconnected(string reason)
    {
        _scenes.Clear();
        _scenesView.Clear();
    }

    private void ObsOnConnected()
    {
        var scenes = _obs.GetSceneNames();
        _scenesView.Clear();
        _scenes.Clear();
        
        _scenesView.AddRange(scenes);
        _scenes.AddRange(scenes);
        CurrentSceneName = _obs.GetCurrentSceneName();
        
        NotifyOfPropertyChange(nameof(CurrentSceneName));
    }

    private void ObsOnSceneChanged(string newSceneName)
    {
        CurrentSceneName = newSceneName;
        NotifyOfPropertyChange(nameof(CurrentSceneName));
    }

    public void CreateLayouts()
    {
        _windowManager.ShowDialogAsync(IoC.Get<CreateLayoutViewModel>());
    }

    public void ChangeSelectedScene(SelectionChangedEventArgs e)
    {
        _selectedScene.SetSelectedScene(e.AddedItems.Cast<string>().FirstOrDefault());
    }

    private void DoSearch()
    {
        _scenesView.Clear();
        if (Search == null)
        {
            _scenesView.AddRange(_scenes);
            return;
        }
        
        _scenesView.AddRange(_scenes.Where(r => r.ToString().Contains(Search, StringComparison.InvariantCultureIgnoreCase)));
    }
    
    public string CurrentSceneName { get; set; }
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
    
    public BindableCollection<string> ObsScenes => _scenesView;
}