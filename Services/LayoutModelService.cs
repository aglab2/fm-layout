using System.IO;
using Newtonsoft.Json;
using schedule_fetcher.Models;
using schedule_fetcher.Util;

namespace schedule_fetcher.Services;

public class LayoutModelService
{
    private Dictionary<string, LayoutModel> _layoutModels = [];

    public LayoutModelService()
    {
        ReadLayoutDescs();
    }

    public LayoutModel? GetLayoutModel(string name)
    {
        return _layoutModels.GetValueOrDefault(name);
    }

    public IEnumerable<LayoutModel> GetLayoutModels()
    {
        return _layoutModels.Values;
    }

    public void ReloadDescs()
    {
        _layoutModels.Clear();
        ReadLayoutDescs();
    }
    
    private void ReadLayoutDescs()
    {
        var descsPath = ManifestResourceLoader.GetPathInExe("LayoutDescs");
        var descFiles = Directory.GetFiles(descsPath, "*.json");
        var deserializer = JsonSerializer.CreateDefault();
        foreach (var descFile in descFiles)
        {
            var jsonReader = new JsonTextReader(new StringReader(File.ReadAllText(descFile)));
            var layoutModel = deserializer.Deserialize<LayoutModel>(jsonReader);
            _layoutModels.Add(layoutModel!.Name, layoutModel);
        }
    }
}