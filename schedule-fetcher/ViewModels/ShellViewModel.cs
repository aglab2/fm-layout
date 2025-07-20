using Caliburn.Micro;
using ModernWpf;

namespace schedule_fetcher.ViewModels;

public class ShellViewModel : PropertyChangedBase
{
    private readonly ObsClient.ObsClient _obs;
    private readonly SpreadsheetClient.SpreadsheetClient _spreadsheet;
    private readonly IWindowManager _windowManager;
    private readonly SceneInfoViewModel _sceneInfo;
    private readonly LayoutTabsViewModel _layoutInfo;

    public ShellViewModel(ObsClient.ObsClient obs, SpreadsheetClient.SpreadsheetClient spreadsheet, IWindowManager windowManager)
    {
        _obs = obs;
        _spreadsheet = spreadsheet;
        _windowManager = windowManager;
        _sceneInfo = IoC.Get<SceneInfoViewModel>();
        _layoutInfo = IoC.Get<LayoutTabsViewModel>();
        
        _obs.Connected += ObsOnConnected;
        _obs.Disconnected += ObsOnDisconnected;
    }

    private void ObsOnDisconnected(string reason)
    {
        ObsConnectionStatus = $"OBS Disconnected... {reason}";
        IsConnected = false;
        NotifyOfPropertyChange(nameof(IsConnected));
        NotifyOfPropertyChange(nameof(ObsConnectionStatus));
    }

    private void ObsOnConnected()
    {
        ObsConnectionStatus = "OBS Connected...";
        IsConnected = true;
        NotifyOfPropertyChange(nameof(IsConnected));
        NotifyOfPropertyChange(nameof(ObsConnectionStatus));
    }

    public void ToggleTheme()
    {
        ThemeManager.Current.ApplicationTheme = ThemeManager.Current.ApplicationTheme switch
        {
            ApplicationTheme.Dark => ApplicationTheme.Light,
            ApplicationTheme.Light => ApplicationTheme.Dark,
            _ => ApplicationTheme.Light
        };
    }

    public void Disconnect()
    {
        _obs.Disconnect();
    }

    public void ShowConnect()
    {
        _windowManager.ShowDialogAsync(IoC.Get<ConnectViewModel>());
    }
    
    public SceneInfoViewModel SceneInfo => _sceneInfo;
    public LayoutTabsViewModel LayoutInfo => _layoutInfo;
    
    public bool IsConnected { get; set; }
    
    public string ObsConnectionStatus { get; set; } = "OBS Disconnected...";
}