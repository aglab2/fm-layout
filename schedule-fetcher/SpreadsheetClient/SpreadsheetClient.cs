using System.Diagnostics;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Auth.OAuth2.Flows;
using Google.Apis.Services;
using Google.Apis.Sheets.v4;
using schedule_fetcher.Models;
using schedule_fetcher.Util;

namespace schedule_fetcher.SpreadsheetClient;

public class SpreadsheetClient
{
    private static string _applicationName = "FM Layouts Info";
    private static string _scheduleSheet = "Overlays";
    private static string _relayRaceSheet = "Relay Race";
    private static List<string> _scopes = [SheetsService.Scope.SpreadsheetsReadonly];
    private string _spreadsheetId = string.Empty;
    
    private SheetsService? Service { get; set; }
    private SpreadsheetsResource.ValuesResource _sheets;

    public void Connect(string spreadsheetId)
    {
        _spreadsheetId = spreadsheetId;
        Service = new SheetsService(new BaseClientService.Initializer
        {
            HttpClientInitializer = GetCredential(),
            ApplicationName = _applicationName,
        });
        _sheets = Service.Spreadsheets.Values;
    }

    public RunModel[] GetRuns()
    {
        if (Service == null)
        {
            return [];
        }

        var range = $"{_scheduleSheet}!A:X";
        var request = _sheets.Get(_spreadsheetId, range);
        var response = request.Execute();
        var values = response.Values;

        return SpreadsheetMapper.MapFromRangeData(values).ToArray();
    }
    
    private static UserCredential GetCredential()
    {
        var clientSecrets = GoogleClientSecrets.FromFile(ManifestResourceLoader.GetPathInExe("SpreadsheetClient\\credentials.json"));
        var initializer = new GoogleAuthorizationCodeFlow.Initializer
        {
            ClientSecrets = clientSecrets.Secrets,
            Scopes = _scopes
        };
        var flow = new GoogleAuthorizationCodeFlow(initializer);
        var receiver = new LocalServerCodeReceiver();
        var task = (new AuthorizationCodeInstalledApp(flow, receiver)).AuthorizeAsync("user", CancellationToken.None);
        task.Wait();
        return task.Result;
    }
}