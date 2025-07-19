using Newtonsoft.Json.Linq;
using OBSWebsocketDotNet;
using OBSWebsocketDotNet.Communication;
using OBSWebsocketDotNet.Types;
using OBSWebsocketDotNet.Types.Events;
using schedule_fetcher.Models;

namespace schedule_fetcher.ObsClient;

public class ObsClient
{
    private OBSWebsocket _obs;

    public delegate void SceneChangedHandler(string newSceneName);
    public delegate void ConnectedHandler();
    public delegate void DisconnectedHandler(string reason);
    
    public event SceneChangedHandler? SceneChanged;
    public event ConnectedHandler? Connected;
    public event DisconnectedHandler? Disconnected;

    public ObsClient()
    {
        _obs = new OBSWebsocket();
        
        _obs.Connected += ObsOnConnected;
        _obs.Disconnected += ObsOnDisconnected;
        
        _obs.CurrentProgramSceneChanged += ObsOnCurrentProgramSceneChanged;
    }

    public void Connect(string ip, string password)
    {
        _obs.ConnectAsync(ip, password);
    }

    public void SendToScene(string sceneName, RunModel model)
    {
        var sceneItems = _obs.GetSceneItemList(sceneName);
        var runnerItems = sceneItems.Where(s => s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) && !s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase) && !s.SourceName.Contains("avatar", StringComparison.InvariantCultureIgnoreCase));
        var runnerPronounsItems = sceneItems.Where(s => s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) && s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase));
        var commentatorItems = sceneItems.Where(s => s.SourceName.Contains("commentator", StringComparison.InvariantCultureIgnoreCase) && !s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase) && !s.SourceName.Contains("commentators", StringComparison.InvariantCultureIgnoreCase));
        var commentatorPronounsItems = sceneItems.Where(s => s.SourceName.Contains("commentator", StringComparison.InvariantCultureIgnoreCase) && s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase));
        var gameNameItem = sceneItems.First(s => s.SourceName.Contains("game name", StringComparison.InvariantCultureIgnoreCase));
        var createdByItem = sceneItems.First(s => s.SourceName.Contains("created by", StringComparison.InvariantCultureIgnoreCase));
        var categoryItem = sceneItems.First(s => s.SourceName.Contains("category", StringComparison.InvariantCultureIgnoreCase));
        var estimateItem = sceneItems.First(s => s.SourceName.Contains("estimate", StringComparison.InvariantCultureIgnoreCase));
        // var runnerAvatarItems = sceneItems.Where(s => s.SourceName.Contains("runner", StringComparison.CurrentCultureIgnoreCase) && s.SourceName.Contains("avatar", StringComparison.CurrentCultureIgnoreCase));
        
        SetSourceText(gameNameItem, model.GameName);
        SetSourceText(createdByItem, model.CreatedBy);
        SetSourceText(categoryItem, model.Category);
        SetSourceText(estimateItem, model.Estimate);
        SetMultipleSourcesText(runnerItems, model.Runners);
        SetMultipleSourcesText(commentatorItems, model.Commentators);
        SetMultipleSourcesText(runnerPronounsItems, model.RunnerPronouns);
        SetMultipleSourcesText(commentatorPronounsItems, model.CommentatorPronouns);
    }

    private void SetMultipleSourcesText(IEnumerable<SceneItemDetails> sources, string[] texts)
    {
        var index = 0;
        foreach (var source in sources)
        {
            SetSourceText(source, texts[index++]);
        }
    }

    private void SetSourceText(SceneItemDetails source, string text)
    {
        _obs.SetInputSettings(source.SourceName, new JObject
        {
            { "text", text }
        });
    }

    public void Disconnect()
    {
        if (!_obs.IsConnected)
        {
            return;
        }
        
        _obs.Disconnect();
    }

    public string GetCurrentSceneName()
    {
        return _obs.GetCurrentProgramScene();
    }

    public List<string> GetSceneNames()
    {
        var scenes = _obs.ListScenes();
        
        return scenes.Select(s => s.Name).ToList();
    }

    private void ObsOnCurrentProgramSceneChanged(object? sender, ProgramSceneChangedEventArgs e)
    {
        SceneChanged?.Invoke(e.SceneName);
    }

    private void ObsOnDisconnected(object? sender, ObsDisconnectionInfo e)
    {
        Disconnected?.Invoke(e.DisconnectReason);
    }

    private void ObsOnConnected(object? sender, EventArgs e)
    {
        Connected?.Invoke();
    }
}