using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TwitchLib.Api;
using TwitchLib.Api.Helix.Models.Channels.ModifyChannelInformation;
using System.Text.Json;

namespace TitleUpdaterConsole
{
    public class Cache
    {
        private readonly string _filePath;
        private readonly string _tempPath;
        private Dictionary<string, string> _cache;

        public Cache(string name)
        {
            string appDataPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            appDataPath += "\\TitleUpdaterConsole\\";
            Directory.CreateDirectory(appDataPath);
            _filePath = appDataPath + name;
            _tempPath = _filePath + ".tmp";
            _cache = LoadCache();
        }

        public string Get(string key)
        {
            return _cache.TryGetValue(key, out var value) ? value : null;
        }

        public void Set(string key, string value)
        {
            _cache[key] = value;
            SaveCache();
        }

        private Dictionary<string, string> LoadCache()
        {
            try
            {
                string json = File.ReadAllText(_filePath);
                return JsonSerializer.Deserialize<Dictionary<string, string>>(json)
                       ?? new Dictionary<string, string>();
            }
            catch
            {
                return new Dictionary<string, string>();
            }
        }

        private void SaveCache()
        {
            try
            {
                string json = JsonSerializer.Serialize(_cache);
                File.WriteAllText(_tempPath, json);
                File.Move(_tempPath, _filePath, true /*overwrite*/);
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("Failed to save cache: " + ex.Message);
            }
        }
    }

    class Program
    {
        static TwitchAPI api;

        static async Task Main(string[] args)
        {
            Cache cache = new Cache("games.json");
            api = new TwitchAPI();
            api.Settings.ClientId = "";
            api.Settings.AccessToken = ""; // 

            var broadcasterId = "90780102";
            if (args.Length == 0)
            {
                var info = await api.Helix.Channels.GetChannelInformationAsync(broadcasterId);
                if (info.Data.Length == 0)
                {
                    return;
                }

                Console.WriteLine($"{info.Data[0].Title}");
                Console.WriteLine($"{info.Data[0].GameName}");
            }
            else
            {
                // var res = await api.Helix.Users.GetUsersAsync(null, new List<string> { "FangameMarathon" });
                // var id = res.Users.First().Id;

                var title = args[0];
                var gameName = args[1];

                string gameId = cache.Get(gameName);
                if (gameId is null)
                {
                    var gamesResponce = await api.Helix.Games.GetGamesAsync(null, new List<string> { gameName });
                    gameId = 0 == gamesResponce.Games.Length ? "66082" : gamesResponce.Games.First().Id;
                    cache.Set(gameName, gameId);
                }

                ModifyChannelInformationRequest req = new ModifyChannelInformationRequest
                {
                    GameId = gameId,
                    Title = title,
                };

                await api.Helix.Channels.ModifyChannelInformationAsync(broadcasterId, req);
            }
        }
    }
}
