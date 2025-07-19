namespace schedule_fetcher.Models;

public class RunModel
{
    public string Id { get; set; } = string.Empty;
    public string GameName { get; set; } = string.Empty;
    public string CreatedBy { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Estimate { get; set; } = string.Empty;
    public bool IsWidescreen { get; set; } = false;
    public bool[] RunnerHasWebcam { get; set; } = [false, false];
    public string[] Runners { get; set; } = ["REPLACE_ME"];
    public string[] RunnerPronouns { get; set; } = ["REPLACE_ME"];
    public string[] Commentators { get; set; } = ["REPLACE_ME"];
    public string[] CommentatorPronouns { get; set; } = ["REPLACE_ME"];

    public override string ToString()
    {
        return $"{Id}. {GameName} ({Category}) {Estimate} {Runners[0]}";
    }
}