using System.Windows.Controls;
using Caliburn.Micro;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class SceneInfoViewModel : Screen
{
    private readonly ObsClient.ObsClient _obs;
    private readonly SelectedSceneService _selectedScene;
    
    public SceneInfoViewModel(ObsClient.ObsClient obs, SelectedSceneService selectedScene)
    {
        _obs = obs;
        _selectedScene = selectedScene;
        
        _obs.SceneChanged += ObsOnSceneChanged;
        _obs.Connected += ObsOnConnected;
        _obs.Disconnected += ObsOnDisconnected;
    }

    private void ObsOnDisconnected(string reason)
    {
        ObsScenes.Clear();
    }

    private void ObsOnConnected()
    {
        var scenes = _obs.GetSceneNames();
        ObsScenes.Clear();
        
        ObsScenes.AddRange(scenes);
        CurrentSceneName = _obs.GetCurrentSceneName();
        
        NotifyOfPropertyChange(nameof(CurrentSceneName));
    }

    private void ObsOnSceneChanged(string newSceneName)
    {
        CurrentSceneName = newSceneName;
        NotifyOfPropertyChange(nameof(CurrentSceneName));
    }

    public void ChangeSelectedScene(SelectionChangedEventArgs e)
    {
        _selectedScene.SetSelectedScene(e.AddedItems.Cast<string>().FirstOrDefault());
    }
    
    public string CurrentSceneName { get; set; }
    
    public BindableCollection<string> ObsScenes { get; } = [];
}