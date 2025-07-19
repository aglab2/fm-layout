namespace schedule_fetcher.Services;

public class SelectedSceneService
{
    private string? _selectedScene = null;
    
    public delegate void SceneChangedHandler(string? selectedScene);
    
    public event SceneChangedHandler? SceneChanged;

    public void SetSelectedScene(string? selectedScene)
    {
        _selectedScene = selectedScene;
        SceneChanged?.Invoke(selectedScene);
    }

    public string? GetSelectedScene()
    {
        return _selectedScene;
    }
}