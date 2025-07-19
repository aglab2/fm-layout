using System.Numerics;
using Newtonsoft.Json.Linq;

namespace schedule_fetcher.Models;

public class LayoutElementModel
{
    public Vector2 Position { get; set; }
    public Vector2 Size { get; set; }
    public string Alignment { get; set; } = string.Empty;
    public string ObsId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public bool AdjustPosition { get; set; } = false;
    public JObject Settings  { get; set; } = new JObject();
}