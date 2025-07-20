namespace schedule_fetcher.Models;

public class RelayRaceModel
{
    public string YellowTeamName { get; set; } = string.Empty;
    public string RedTeamName { get; set; } = string.Empty;
    public string YellowTeamCurrentGame { get; set; } = string.Empty;
    public string RedTeamCurrentGame { get; set; } = string.Empty;
    public string YellowTeamCurrentPlayer { get; set; } = string.Empty;
    public string RedTeamCurrentPlayer { get; set; } = string.Empty;
    public string[] Games { get; set; } = [];
    public string[] YellowTeamPlayers  { get; set; } = [];
    public string[] RedTeamPlayers { get; set; } = [];
}