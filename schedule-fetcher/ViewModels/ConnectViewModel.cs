using System.Windows.Controls;
using Caliburn.Micro;

namespace schedule_fetcher.ViewModels;

public class ConnectViewModel(ObsClient.ObsClient obs, SpreadsheetClient.SpreadsheetClient spreadsheetClient) : Screen
{
    public void Connect()
    {
        obs.Connect($"ws://{ObsIp}", ObsPassword);
        // spreadsheetClient.Connect(SpreadsheetId);
        TryCloseAsync();
    }

    public void OnPasswordChanged(PasswordBox passwordBox)
    {
        ObsPassword = passwordBox.Password;
    }
    
    public string SpreadsheetId { get; set; } = "1XIfJVemTY3Ab4hsZR-KD_UiW7V8ahbRD2I2dYt_oY8A";
    
    public string ObsIp { get; set; } = "127.0.0.1:4455";
    
    public string ObsPassword { get; set; } = string.Empty;
}