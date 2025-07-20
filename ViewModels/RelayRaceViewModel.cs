using Caliburn.Micro;
using schedule_fetcher.Models;
using schedule_fetcher.Services;

namespace schedule_fetcher.ViewModels;

public class RelayRaceViewModel : Screen
{
    private readonly SpreadsheetClient.SpreadsheetClient _spreadsheet;
    private readonly ObsClient.ObsClient _obs;
    private readonly SelectedSceneService _selectedScene;
    private RelayRaceModel? _relayRace;
    private List<float> _playerXpositions = [];
    private const float DefaultX = 788.0f;

    private List<string[]> _yellowRunnerSprites =
    [
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
    ];
    
    private List<string[]> _redRunnerSprites =
    [
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
        ["kid_idle", "kid_run"],
    ];

    public RelayRaceViewModel(SpreadsheetClient.SpreadsheetClient spreadsheet, ObsClient.ObsClient obs, SelectedSceneService selectedScene)
    {
        _spreadsheet = spreadsheet;
        _obs = obs;
        _selectedScene = selectedScene;
        
        Timer = IoC.Get<TimerViewModel>();
        _obs.Connected += ObsOnConnected;
        _selectedScene.SceneChanged += SelectedSceneOnSceneChanged;
        
        Timer.TimerStarted += TimerOnTimerStarted;
        Timer.TimerStopped += TimerOnTimerStopped;
        Timer.TimerPaused += TimerOnTimerPaused;
        Timer.TimerContinued += TimerOnTimerContinued;
    }

    private void TimerOnTimerContinued()
    {
        SendRunImages();
    }

    private void TimerOnTimerPaused()
    {
        SendIdleImages();
    }

    private void TimerOnTimerStopped()
    {
        SendIdleImages();
    }

    private void TimerOnTimerStarted()
    {
        SendRunImages();
    }

    private void SendIdleImages()
    {
        var selectedScene = _selectedScene.GetSelectedScene();
        if (selectedScene == null)
        {
            return;
        }
        
        var yellowPlayerIndex = YellowTeamCurrentPlayer ?? 0;
        var redPlayerIndex = RedTeamCurrentPlayer ?? 0;
        
        _obs.SendCurrentRunnersImages(selectedScene, [
            _yellowRunnerSprites[yellowPlayerIndex][0],
            _redRunnerSprites[redPlayerIndex][0]
        ]);
    }

    private void SendRunImages()
    {
        var selectedScene = _selectedScene.GetSelectedScene();
        if (selectedScene == null)
        {
            return;
        }
        
        var yellowPlayerIndex = YellowTeamCurrentPlayer ?? 0;
        var redPlayerIndex = RedTeamCurrentPlayer ?? 0;
        
        _obs.SendCurrentRunnersImages(selectedScene, [
            _yellowRunnerSprites[yellowPlayerIndex][1],
            _redRunnerSprites[redPlayerIndex][1]
        ]);
    }

    private void SelectedSceneOnSceneChanged(string? selectedScene)
    {
        NotifyOfPropertyChange(nameof(SceneToSendTo));
        NotifyOfPropertyChange(nameof(CanSend));
    }

    private void ObsOnConnected()
    {
        _relayRace = _spreadsheet.GetRelayRace();
        
        YellowTeamName = _relayRace.YellowTeamName;
        YellowPlayer1 = _relayRace.YellowTeamPlayers[0];
        YellowPlayer2 = _relayRace.YellowTeamPlayers[1];
        YellowPlayer3 = _relayRace.YellowTeamPlayers[2];
        YellowPlayer4 = _relayRace.YellowTeamPlayers[3];
        YellowPlayer5 = _relayRace.YellowTeamPlayers[4];
        
        RedTeamName = _relayRace.RedTeamName;
        RedPlayer1 = _relayRace.RedTeamPlayers[0];
        RedPlayer2 = _relayRace.RedTeamPlayers[1];
        RedPlayer3 = _relayRace.RedTeamPlayers[2];
        RedPlayer4 = _relayRace.RedTeamPlayers[3];
        RedPlayer5 = _relayRace.RedTeamPlayers[4];

        _playerXpositions.Clear();
        var startX = DefaultX;
        foreach (var _ in _relayRace.Games)
        {
            _playerXpositions.Add(startX);
            startX += 229;
        }
        
        NotifyOfPropertyChange(nameof(IsEnabled));
        NotifyOfPropertyChange(nameof(Games));
        
        NotifyOfPropertyChange(nameof(YellowTeamName));
        NotifyOfPropertyChange(nameof(YellowPlayer1));
        NotifyOfPropertyChange(nameof(YellowPlayer2));
        NotifyOfPropertyChange(nameof(YellowPlayer3));
        NotifyOfPropertyChange(nameof(YellowPlayer4));
        NotifyOfPropertyChange(nameof(YellowPlayer5));
        
        NotifyOfPropertyChange(nameof(RedTeamName));
        NotifyOfPropertyChange(nameof(RedPlayer1));
        NotifyOfPropertyChange(nameof(RedPlayer2));
        NotifyOfPropertyChange(nameof(RedPlayer3));
        NotifyOfPropertyChange(nameof(RedPlayer4));
        NotifyOfPropertyChange(nameof(RedPlayer5));
    }

    public void SendToScene()
    {
        var selectedScene = _selectedScene.GetSelectedScene();
        if (selectedScene == null)
        {
            return;
        }

        var yellowPlayerIndex = YellowTeamCurrentPlayer ?? 0;
        var currentYelloTeamPlayer = _relayRace?.YellowTeamPlayers[0] ?? string.Empty;
        if (YellowTeamCurrentPlayer != null)
        {
            currentYelloTeamPlayer = _relayRace?.YellowTeamPlayers[yellowPlayerIndex] ?? string.Empty;
        }
        
        var redPlayerIndex = RedTeamCurrentPlayer ?? 0;
        var currentRedTeamPlayer = _relayRace?.RedTeamPlayers[0] ?? string.Empty;
        if (RedTeamCurrentPlayer != null)
        {
            currentRedTeamPlayer = _relayRace?.RedTeamPlayers[redPlayerIndex] ?? string.Empty;
        }
        
        _obs.SendRelayToScene(selectedScene, new RelayRaceModel
        {
            YellowTeamName = YellowTeamName ?? string.Empty,
            YellowTeamCurrentGame = _relayRace?.Games[yellowPlayerIndex] ?? string.Empty,
            YellowTeamCurrentPlayer = currentYelloTeamPlayer,
            YellowTeamPlayers = [
                YellowPlayer1 ?? string.Empty,
                YellowPlayer2 ?? string.Empty,
                YellowPlayer3 ?? string.Empty,
                YellowPlayer4 ?? string.Empty,
                YellowPlayer5 ?? string.Empty
            ],
            RedTeamName = RedTeamName ?? string.Empty,
            RedTeamCurrentGame = _relayRace?.Games[redPlayerIndex] ?? string.Empty,
            RedTeamCurrentPlayer = currentRedTeamPlayer,
            RedTeamPlayers = [
                RedPlayer1 ?? string.Empty,
                RedPlayer2 ?? string.Empty,
                RedPlayer3 ?? string.Empty,
                RedPlayer4 ?? string.Empty,
                RedPlayer5 ?? string.Empty
            ]
        }, [
            YellowTeamCurrentPlayer != null ? _playerXpositions[YellowTeamCurrentPlayer.Value] : DefaultX,
            RedTeamCurrentPlayer != null ? _playerXpositions[RedTeamCurrentPlayer.Value] : DefaultX
        ], [
            _yellowRunnerSprites[yellowPlayerIndex],
            _redRunnerSprites[redPlayerIndex]
        ]);
    }

    public void UpdatePlayerLists()
    {
        var oldSelectedYellowPlayer = YellowTeamCurrentPlayer;
        var oldSelectedRedPlayer = RedTeamCurrentPlayer;
        NotifyOfPropertyChange(nameof(YellowTeamPlayers));
        NotifyOfPropertyChange(nameof(RedTeamPlayers));
        YellowTeamCurrentPlayer = oldSelectedYellowPlayer;
        RedTeamCurrentPlayer = oldSelectedRedPlayer;
        NotifyOfPropertyChange(nameof(YellowTeamCurrentPlayer));
        NotifyOfPropertyChange(nameof(RedTeamCurrentPlayer));
    }

    public bool IsEnabled => _relayRace != null;
    public TimerViewModel Timer { get; private set; }
    
    public string SceneToSendTo => CanSend ? $"Send to {_selectedScene.GetSelectedScene()}" : "No scene selected";
    public bool CanSend => _selectedScene.GetSelectedScene() != null;
    
    public BindableCollection<string> Games => new(_relayRace?.Games ?? []);
    public BindableCollection<string> YellowTeamPlayers => [YellowPlayer1, YellowPlayer2, YellowPlayer3, YellowPlayer4, YellowPlayer5];
    public BindableCollection<string> RedTeamPlayers => [RedPlayer1, RedPlayer2, RedPlayer3, RedPlayer4, RedPlayer5];
    
    public string? YellowTeamName { get; set; }
    public int? YellowTeamCurrentPlayer { get; set; } = 0;
    public string? YellowPlayer1 { get; set; }
    public string? YellowPlayer2 { get; set; }
    public string? YellowPlayer3 { get; set; }
    public string? YellowPlayer4 { get; set; }
    public string? YellowPlayer5 { get; set; }
    
    public string? RedTeamName { get; set; }
    public int? RedTeamCurrentPlayer { get; set; } = 0;
    public string? RedPlayer1 { get; set; }
    public string? RedPlayer2 { get; set; }
    public string? RedPlayer3 { get; set; }
    public string? RedPlayer4 { get; set; }
    public string? RedPlayer5 { get; set; }
}