namespace schedule_fetcher.Models;

public class LayoutModel
{
    public string Name { get; set; } = string.Empty;
    public List<LayoutElementModel> Elements { get; set; } = [];
}