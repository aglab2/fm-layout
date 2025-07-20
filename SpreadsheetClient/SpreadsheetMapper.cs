using System.Diagnostics;
using schedule_fetcher.Models;

namespace schedule_fetcher.SpreadsheetClient;

public static class SpreadsheetMapper
{
    private enum SpreadSheetFields
    {
        Id,
        GameName,
        Category,
        Estimate,
        Runner1,
        Runner1Pronouns,
        Runner2,
        Runner2Pronouns,
        Runner3,
        Runner3Pronouns,
        Runner4,
        Runner4Pronouns,
        HasWebcam1,
        HasWebcam2,
        Commentator1,
        Commentator1Pronouns,
        Commentator2,
        Commentator2Pronouns,
        Commentator3,
        Commentator3Pronouns,
        Commentator4,
        Commentator4Pronouns,
        WindowSize,
        CreatedBy,
        TwitchDirectory
    }
    public static List<RunModel> MapRunsFromRangeData(IList<IList<object>> values)
    {
        var result = new List<RunModel>();

        foreach (var value in values.Skip(1))
        {
            var id = GetFieldOrEmpty(value, SpreadSheetFields.Id);
            var gameName = GetFieldOrEmpty(value, SpreadSheetFields.GameName);
            var category = GetFieldOrEmpty(value, SpreadSheetFields.Category);
            var estimate = GetFieldOrEmpty(value, SpreadSheetFields.Estimate);
            var runner1 = GetFieldOrEmpty(value, SpreadSheetFields.Runner1);
            var runner2 = GetFieldOrEmpty(value, SpreadSheetFields.Runner2);
            var runner3 = GetFieldOrEmpty(value, SpreadSheetFields.Runner3);
            var runner4 = GetFieldOrEmpty(value, SpreadSheetFields.Runner4);
            var runner1Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Runner1Pronouns);
            var runner2Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Runner2Pronouns);
            var runner3Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Runner3Pronouns);
            var runner4Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Runner4Pronouns);
            var hasWebcam1 = GetFieldOrEmpty(value, SpreadSheetFields.HasWebcam1);
            var hasWebcam2 = GetFieldOrEmpty(value, SpreadSheetFields.HasWebcam2);
            var commentator1 = GetFieldOrEmpty(value, SpreadSheetFields.Commentator1);
            var commentator2 = GetFieldOrEmpty(value, SpreadSheetFields.Commentator2);
            var commentator3 = GetFieldOrEmpty(value, SpreadSheetFields.Commentator3);
            var commentator4 = GetFieldOrEmpty(value, SpreadSheetFields.Commentator4);
            var commentator1Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Commentator1Pronouns);
            var commentator2Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Commentator2Pronouns);
            var commentator3Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Commentator3Pronouns);
            var commentator4Pronouns = GetFieldOrEmpty(value, SpreadSheetFields.Commentator4Pronouns);
            var windowSize = GetFieldOrEmpty(value, SpreadSheetFields.WindowSize);
            var createdBy = GetFieldOrEmpty(value, SpreadSheetFields.CreatedBy);
            var twitchDirectory = GetFieldOrEmpty(value, SpreadSheetFields.TwitchDirectory);
            
            var runModel = new RunModel
            {
                Id = id,
                GameName = gameName.Replace('^', '\n'),
                Category = category.Replace('^', '\n'),
                Estimate = estimate,
                Runners = [
                    runner1,
                    runner2,
                    runner3,
                    runner4
                ],
                CreatedBy = createdBy,
                RunnerPronouns = [
                    runner1Pronouns,
                    runner2Pronouns,
                    runner3Pronouns,
                    runner4Pronouns
                ],
                RunnerHasWebcam = [
                    hasWebcam1.Contains("Yes", StringComparison.InvariantCultureIgnoreCase),
                    hasWebcam2.Contains("Yes", StringComparison.InvariantCultureIgnoreCase)
                ],
                Commentators = [
                    commentator1,
                    commentator2,
                    commentator3,
                    commentator4
                ],
                CommentatorPronouns = [
                    commentator1Pronouns,
                    commentator2Pronouns,
                    commentator3Pronouns,
                    commentator4Pronouns
                ],
                IsWidescreen = IsGameWidescreen(windowSize),
                TwitchDirection = string.IsNullOrEmpty(twitchDirectory) ? "Games + Demos" : twitchDirectory
            };
            
            result.Add(runModel);
        }

        return result;
    }

    public static RelayRaceModel MapRelayRaceFromRangeData(IList<IList<object>> values)
    {
        var resultModel = new RelayRaceModel();
        var gameNamesRow = values[0].Skip(1);
        var yellowTeamInfo = values[1];
        var redTeamInfo = values[2];

        var gameNamesEnumerated = gameNamesRow as object[] ?? gameNamesRow.ToArray();
        var games = new List<string>(gameNamesEnumerated.Length);
        games.AddRange(gameNamesEnumerated.Select(gameName => gameName.ToString()!));
        resultModel.Games = games.ToArray();

        var yellowTeamFormat = yellowTeamInfo[0].ToString()!;
        var yellowTeamName = yellowTeamFormat[(yellowTeamFormat.IndexOf('(') + 1)..yellowTeamFormat.IndexOf(')')];
        resultModel.YellowTeamName = yellowTeamName;
        
        var redTeamFormat = redTeamInfo[0].ToString()!;
        var redTeamName = redTeamFormat[(redTeamFormat.IndexOf('(') + 1)..redTeamFormat.IndexOf(')')];
        resultModel.RedTeamName = redTeamName;

        var yellowTeamPlayers = yellowTeamInfo.Skip(1).ToArray();
        var redTeamPlayers = redTeamInfo.Skip(1).ToArray();

        var yellowTeamPlayerList = new List<string>(yellowTeamPlayers.Length);
        yellowTeamPlayerList.AddRange(yellowTeamPlayers.Select(player => player.ToString()!));
        resultModel.YellowTeamPlayers = yellowTeamPlayerList.ToArray();
        
        var redTeamPlayerList = new List<string>(redTeamPlayers.Length);
        redTeamPlayerList.AddRange(redTeamPlayers.Select(player => player.ToString()!));
        resultModel.RedTeamPlayers = redTeamPlayerList.ToArray();
        
        return resultModel;
    }

    private static bool IsGameWidescreen(string resolution)
    {
        const double widescreenRatio = 16.0 / 9.0;
        const double narrowRatio = 4.0 / 3.0;
        
        var splitStrings = resolution switch
        {
            _ when resolution.Contains('x') => resolution.Split('x'),
            _ when resolution.Contains(':') => resolution.Split(':'),
            _ => ["16", "9"]
        };
        
        var width = int.Parse(splitStrings[0]);
        var height = int.Parse(splitStrings[1]);
        var ratio = (double)width / height;

        var wideDiff = Math.Abs(widescreenRatio - ratio);
        var narrowDiff = Math.Abs(narrowRatio - ratio);
        
        return wideDiff < narrowDiff;
    }

    private static string GetFieldOrEmpty(IList<object> value, SpreadSheetFields field)
    {
        return CheckExists(value, field) ? GetField(value, field) : string.Empty;
    }

    private static string GetField(IList<object> value, SpreadSheetFields field)
    {
        Debug.Assert(CheckExists(value, field), $"Trying to fetch unexisting field {field}");
        return value[(int)field].ToString()!;
    }

    private static bool CheckExists(IList<object> value, SpreadSheetFields field)
    {
        return value.Count > (int)field;
    }
}