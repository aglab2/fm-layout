using System.Diagnostics;
using schedule_fetcher.Models;

namespace schedule_fetcher.Util;

public static class Twitch
{
    public static void UpdateTwitchTitle(RunModel run)
    {
        var title = "FM2025 || ";
        title += run.GameName;
        title += ", by ";
        title += string.Join(", ", run.Runners.Where(r => !string.IsNullOrEmpty(r)));

        var updaterPath = ManifestResourceLoader.GetPathInExe("Libs\\TitleUpdaterConsole.exe");
        Process.Start(updaterPath, [title, run.TwitchDirection]);
    }

    public static void ResetTwitchTitle()
    {
        var updaterPath = ManifestResourceLoader.GetPathInExe("Libs\\TitleUpdaterConsole.exe");
        Process.Start(updaterPath, ["FM2025 is coming up!", "I Wanna Be the Guy"]);
    }
}