using Newtonsoft.Json.Linq;
using OBSWebsocketDotNet;
using OBSWebsocketDotNet.Communication;
using OBSWebsocketDotNet.Types;
using OBSWebsocketDotNet.Types.Events;
using schedule_fetcher.Models;
using schedule_fetcher.Util;

namespace schedule_fetcher.ObsClient;

public class ObsClient
{
    private OBSWebsocket _obs;

    [Flags]
    private enum Alignment
    {
        Center = 0,
        Left = 1 << 0,
        Right = 1 << 1,
        Top = 1 << 2,
        Bottom = 1 << 3,
        TopLeft = Top | Left,
        TopRight = Top | Right,
        BottomLeft = Bottom | Left,
        BottomRight = Bottom | Right,
        LeftCenter = Left | Center,
        RightCenter = Right | Center,
        TopCenter = Top | Center,
        BottomCenter = Bottom | Center,
    }

    private Dictionary<string, int> _textTransformMap = new()
    {
        { "none", 0 },
        { "upper", 1 },
        { "lower", 2 },
        { "start", 3 }
    };

    private Dictionary<string, uint> _colorMap = new()
    {
        {"red", 0x0006FF},
        {"blue", 0xB8CA01},
        {"white", 0xFFFFFF},
        {"yellow", 0x8CDFFF}
    };

    private Dictionary<string, string> _styleToFaceMap = new()
    {
        { "Regular", "Reg" },
        {"RegularItalic", "RegItalic"},
        {"Bold", "Bold"},
        {"BoldItalic", "BoldItalic"},
        {"Book", "Book"},
        {"Heavy", "Heavy"},
        {"HeavyItalic", "HeavyItalic"},
        {"Light", "Light"},
        {"LightItalic", "LightItalic"},
        {"Thin", "Thin"},
        {"ThinItalic", "ThinItalic"},
        {"Ultra", "Ultra"},
        {"UltraItalic", "UltraItalic"}
    };

    public delegate void SceneChangedHandler(string newSceneName);
    public delegate void ConnectedHandler();
    public delegate void DisconnectedHandler(string reason);

    public delegate void SceneListChangedHandler();
    
    public event SceneChangedHandler? SceneChanged;
    public event ConnectedHandler? Connected;
    public event DisconnectedHandler? Disconnected;
    public event SceneListChangedHandler? SceneListChanged;

    public ObsClient()
    {
        _obs = new OBSWebsocket();
        
        _obs.Connected += ObsOnConnected;
        _obs.Disconnected += ObsOnDisconnected;
        
        _obs.CurrentProgramSceneChanged += ObsOnCurrentProgramSceneChanged;
        _obs.SceneListChanged += ObsOnSceneListChanged;
        _obs.SceneCreated += ObsOnSceneCreated;
        _obs.SceneRemoved += ObsOnSceneRemoved;
    }

    private void ObsOnSceneRemoved(object? sender, SceneRemovedEventArgs e)
    {
        SceneListChanged?.Invoke();
    }

    private void ObsOnSceneCreated(object? sender, SceneCreatedEventArgs e)
    {
        SceneListChanged?.Invoke();
    }

    private void ObsOnSceneListChanged(object? sender, SceneListChangedEventArgs e)
    {
        SceneListChanged?.Invoke();
    }

    public void Connect(string ip, string password)
    {
        _obs.ConnectAsync(ip, password);
    }

    public void SendToScene(string sceneName, RunModel model)
    {
        var sceneItems = _obs.GetSceneItemList(sceneName);
        var runnerItems = sceneItems.Where(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("avatar", StringComparison.InvariantCultureIgnoreCase));
        var runnerPronounsItems = sceneItems.Where(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase));
        var runnerPronounsFramesItems = sceneItems.Where(s =>
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase));
        var commentatorItems = sceneItems.Where(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("commentator", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("commentators", StringComparison.InvariantCultureIgnoreCase));
        var commentatorPronounsItems = sceneItems.Where(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("commentator", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase));
        var gameNameItem = sceneItems.FirstOrDefault(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("game name", StringComparison.InvariantCultureIgnoreCase));
        var createdByItem = sceneItems.FirstOrDefault(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("created by", StringComparison.InvariantCultureIgnoreCase));
        var categoryItem = sceneItems.FirstOrDefault(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("category", StringComparison.InvariantCultureIgnoreCase));
        var estimateItem = sceneItems.FirstOrDefault(s =>
            s.SourceName.StartsWith("d_", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("estimate", StringComparison.InvariantCultureIgnoreCase));
        var runnerAvatarItems = sceneItems.Where(s =>
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("avatar", StringComparison.InvariantCultureIgnoreCase));
        var runnerWebCamItems = sceneItems.Where(s =>
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("webcam", StringComparison.InvariantCultureIgnoreCase));
        var commentatorFrames = sceneItems.Where(s => 
            s.SourceName.Contains("commentator", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("commentators", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase));
        var commentatorPronounsFrames = sceneItems.Where(s => 
            s.SourceName.Contains("commentator", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("pronouns", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase));
        var commentatorsFrame = sceneItems.FirstOrDefault(s =>
            s.SourceName.Contains("commentators", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase));
        var commentatorsStatic = sceneItems.FirstOrDefault(s =>
            s.SourceName.Contains("commentators", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("static", StringComparison.InvariantCultureIgnoreCase));
        var runner4x3Frame = sceneItems.FirstOrDefault(s => 
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("4x3", StringComparison.InvariantCultureIgnoreCase));
        var runner16x9Frame = sceneItems.FirstOrDefault(s => 
            s.SourceName.Contains("runner", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase) &&
            s.SourceName.Contains("16x9", StringComparison.InvariantCultureIgnoreCase));
        
        var commentatorsEnumerated = commentatorItems.ToList();
        var commentatorPronounsEnumerated = commentatorPronounsItems.ToList();
        
        SetSourceText(gameNameItem, model.GameName);
        SetSourceText(createdByItem, $"Created by {model.CreatedBy}");
        SetSourceText(categoryItem, model.Category);
        SetSourceText(estimateItem, model.Estimate);
        
        SetMultipleSourcesText(runnerItems, model.Runners);
        SetMultipleSourcesText(commentatorsEnumerated, model.Commentators);
        
        SetMultipleSourcesText(runnerPronounsItems, model.RunnerPronouns);
        SetMultipleSourcesText(commentatorPronounsEnumerated, model.CommentatorPronouns);

        var visibleRunnerPronouns = model.RunnerPronouns.Select(s => !string.IsNullOrEmpty(s)).ToArray();
        SetMultipleSourcesVisibility(sceneName, runnerPronounsFramesItems, visibleRunnerPronouns);
        
        var visibleCommentators = model.Commentators.Select(s => !string.IsNullOrEmpty(s)).ToArray();
        SetMultipleSourcesVisibility(sceneName, commentatorsEnumerated, visibleCommentators);
        SetMultipleSourcesVisibility(sceneName, commentatorFrames, visibleCommentators);
        var visibleCommentatorPronouns = model.CommentatorPronouns.Select(s => !string.IsNullOrEmpty(s)).ToArray();
        SetMultipleSourcesVisibility(sceneName, commentatorPronounsEnumerated, visibleCommentatorPronouns);
        SetMultipleSourcesVisibility(sceneName, commentatorPronounsFrames, visibleCommentatorPronouns);
        var hasCommentators = visibleCommentators.Any(b => b);
        SetSourceVisibility(sceneName, commentatorsFrame, hasCommentators);
        SetSourceVisibility(sceneName, commentatorsStatic, hasCommentators);
        
        SetSourceVisibility(sceneName, runner4x3Frame, !model.IsWidescreen);
        SetSourceVisibility(sceneName, runner16x9Frame, model.IsWidescreen);
        

        SetMultipleSourcesVisibility(sceneName, runnerAvatarItems, model.RunnerHasWebcam.Select(b => !b).ToArray());
        SetMultipleSourcesVisibility(sceneName, runnerWebCamItems, model.RunnerHasWebcam);
    }

    public void StartStopTimer(string sceneName)
    {
        var sceneItems = _obs.GetSceneItemList(sceneName);
        var timer = sceneItems.FirstOrDefault(s =>
            s.SourceName.Contains("timer", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase));
        
        if (timer == null)
        {
            return;
        }

        var timerStatus = _obs.GetMediaInputStatus(timer.SourceName);
        switch (timerStatus.State)
        {
            case MediaState.OBS_MEDIA_STATE_PLAYING:
                _obs.TriggerMediaInputAction(timer.SourceName, "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_NEXT");
                break;
            case MediaState.OBS_MEDIA_STATE_NONE:
            case MediaState.OBS_MEDIA_STATE_STOPPED:
            case MediaState.OBS_MEDIA_STATE_ENDED:
                _obs.TriggerMediaInputAction(timer.SourceName, "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_PLAY");
                break;
        }
    }

    public void PauseContinueTimer(string sceneName)
    {
        var sceneItems = _obs.GetSceneItemList(sceneName);
        var timer = sceneItems.FirstOrDefault(s =>
            s.SourceName.Contains("timer", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase));
        
        if (timer == null)
        {
            return;
        }
        
        var timerStatus = _obs.GetMediaInputStatus(timer.SourceName);
        switch (timerStatus.State)
        {
            case MediaState.OBS_MEDIA_STATE_PLAYING:
                _obs.TriggerMediaInputAction(timer.SourceName, "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_PAUSE");
                break;
            case MediaState.OBS_MEDIA_STATE_ENDED:
                _obs.TriggerMediaInputAction(timer.SourceName, "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_PREVIOUS");
                break;
            case MediaState.OBS_MEDIA_STATE_PAUSED:
                _obs.TriggerMediaInputAction(timer.SourceName, "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_PLAY");
                break;
        }
    }

    public void ResetTimer(string sceneName)
    {
        var sceneItems = _obs.GetSceneItemList(sceneName);
        var timer = sceneItems.FirstOrDefault(s =>
            s.SourceName.Contains("timer", StringComparison.InvariantCultureIgnoreCase) &&
            !s.SourceName.Contains("frame", StringComparison.InvariantCultureIgnoreCase));
        
        if (timer == null)
        {
            return;
        }
        
        _obs.TriggerMediaInputAction(timer.SourceName, "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_STOP");
    }

    public void CreateLayout(LayoutModel model)
    {
        var actualName = model.Name[..];
        var index = 1;
        while (_obs.ListScenes().Select(s => s.Name).Contains(actualName))
        {
            actualName = model.Name + $" {index}";
            index++;
        }
        
        _obs.CreateScene(actualName);
        
        foreach (var layoutElementModel in model.Elements)
        {
            CreateElement(actualName, layoutElementModel);
        }
    }

    private void CreateElement(string sceneName, LayoutElementModel model)
    {
        NormalizeLayoutElementSettings(model);

        var actualName = model.Name[..];
        var index = 1;
        while (_obs.GetInputList().Select(i => i.InputName).Contains(actualName))
        {
            actualName = model.Name + $" {index}";
            index++;
        }

        var sceneItem = _obs.CreateInput(sceneName, actualName, model.ObsId, model.Settings, true);
        var isNotBound = model.Settings.ContainsKey("text") || model.Settings.ContainsKey("layout_path");
        var alignment = ParseAlignment(model.Alignment);
        var position = model.Position;
        if (model.AdjustPosition)
        {
            position = GetPositionBasedOnAlignment(model.Position, model.Size, alignment);
        }

        _obs.SetSceneItemTransform(sceneName, sceneItem, new SceneItemTransformInfo
        {
            X = position.X,
            Y = position.Y,
            ScaleX = 1.0,
            ScaleY = 1.0,
            BoundsType = isNotBound ? SceneItemBoundsType.OBS_BOUNDS_NONE : SceneItemBoundsType.OBS_BOUNDS_STRETCH,
            BoundsWidth = model.Size.X,
            BoundsHeight = model.Size.Y,
            SourceWidth = model.Size.X,
            SourceHeight = model.Size.Y,
            Width = model.Size.X,
            Height = model.Size.Y,
            Alignnment = (int)alignment
        });
    }

    private static System.Numerics.Vector2 GetPositionBasedOnAlignment(System.Numerics.Vector2 position, System.Numerics.Vector2 size, Alignment alignment)
    {
        var newPosition = position;
        if (alignment.HasFlag(Alignment.TopLeft))
        {
            return newPosition;
        }

        if (alignment.HasFlag(Alignment.Center))
        {
            newPosition.X += size.X / 2;
            newPosition.Y += size.Y / 2;
        }

        if (alignment.HasFlag(Alignment.Top))
        {
            newPosition.Y = position.Y;
        }

        if (alignment.HasFlag(Alignment.Bottom))
        {
            newPosition.Y = position.Y + size.Y;
        }

        if (alignment.HasFlag(Alignment.Right))
        {
            newPosition.X = position.X + size.X;
        }

        if (alignment.HasFlag(Alignment.Left))
        {
            newPosition.X = position.X;
        }

        return newPosition;
    }

    private void NormalizeLayoutElementSettings(LayoutElementModel model)
    {
        if (model.Settings.ContainsKey("file"))
        {
            model.Settings["file"] = ManifestResourceLoader.GetPathInExe(model.Settings["file"]!.ToString());
        }

        if (model.Settings.ContainsKey("layout_path"))
        {
            model.Settings["layout_path"] = ManifestResourceLoader.GetPathInExe(model.Settings["layout_path"]!.ToString());
        }

        if (model.Settings.TryGetValue("font", out var fontSetting))
        {
            fontSetting["face"] = "MrEavesXLModOT-" + _styleToFaceMap[fontSetting["style"]!.ToString()];
        }

        if (model.Settings.ContainsKey("align"))
        {
            model.Settings["align"] = model.Settings["align"]!.ToString().ToLower();
        }

        if (model.Settings.ContainsKey("transform"))
        {
            if (_textTransformMap.TryGetValue(model.Settings["transform"]!.ToString().ToLower(), out var transformSetting))
            {
                model.Settings["transform"] = transformSetting;
            }
        }

        if (model.Settings.ContainsKey("color"))
        {
            if (_colorMap.TryGetValue(model.Settings["color"]!.ToString().ToLower(), out var color))
            {
                model.Settings["color"] = color;
            }
        }
    }

    private static Alignment ParseAlignment(string alignmentStr)
    {
        var alignment = Alignment.Center;
        if (alignmentStr.Contains("top", StringComparison.InvariantCultureIgnoreCase))
        {
            alignment |= Alignment.Top;
        }

        if (alignmentStr.Contains("bottom", StringComparison.InvariantCultureIgnoreCase))
        {
            alignment |= Alignment.Bottom;
        }
        
        if (alignmentStr.Contains("right", StringComparison.InvariantCultureIgnoreCase))
        {
            alignment |= Alignment.Right;
        }
        
        if (alignmentStr.Contains("left", StringComparison.InvariantCultureIgnoreCase))
        {
            alignment |= Alignment.Left;
        }
        return alignment;
    }

    private void SetSourceVisibility(string sceneName, SceneItemDetails? source, bool visible)
    {
        if (source == null)
        {
            return;
        }
        
        _obs.SetSceneItemEnabled(sceneName, source.ItemId, visible);
    }

    private void SetMultipleSourcesVisibility(string sceneName, IEnumerable<SceneItemDetails> sources, bool[] visibility)
    {
        var index = 0;
        foreach (var source in sources)
        {
            SetSourceVisibility(sceneName, source, visibility[index++]);
        }
    }

    private void SetMultipleSourcesText(IEnumerable<SceneItemDetails> sources, string[] texts)
    {
        var index = 0;
        foreach (var source in sources)
        {
            SetSourceText(source, texts[index++]);
        }
    }

    private void SetSourceText(SceneItemDetails? source, string text)
    {
        if (source == null)
        {
            return;
        }
        
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