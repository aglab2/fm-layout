using System.IO;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using Caliburn.Micro;
using schedule_fetcher.Models;
using schedule_fetcher.Services;
using schedule_fetcher.Util;

namespace schedule_fetcher.ViewModels;

public class CreateLayoutViewModel : Screen
{
    private readonly ObsClient.ObsClient _obs;
    private readonly LayoutModelService _layoutModelService;
    private List<string> SelectedLayouts { get; } = [];
    private bool _isCreating = false;

    public CreateLayoutViewModel(ObsClient.ObsClient obs, LayoutModelService layoutModelService)
    {
        _obs = obs;
        _layoutModelService = layoutModelService;
        
        Layouts.AddRange(layoutModelService.GetLayoutModels().Select(lm => lm.Name));
    }

    public async Task CreateLayout()
    {
        _isCreating = true;
        NotifyOfPropertyChange(nameof(IsNotCreating));
        NotifyOfPropertyChange(nameof(IsCreatingVis));

        var creationTask = Task.Factory.StartNew(() =>
        {
            foreach (var selectedLayout in SelectedLayouts)
            {
                _obs.CreateLayout(_layoutModelService.GetLayoutModel(selectedLayout)!);
            }
        });
        
        await creationTask;
        await TryCloseAsync();
    }

    public void ReloadTemplates()
    {
        _layoutModelService.ReloadDescs();
        Layouts.Clear();
        Layouts.AddRange(_layoutModelService.GetLayoutModels().Select(lm => lm.Name));
    }

    public void ChangeSelectedLayout(SelectionChangedEventArgs e)
    {
        foreach (var removedSelection in e.RemovedItems.Cast<string>())
        {
            SelectedLayouts.Remove(removedSelection);
        }
        
        SelectedLayouts.AddRange(e.AddedItems.Cast<string>());
        
        NotifyOfPropertyChange(nameof(CanCreate));
    }

    public bool IsNotCreating => !_isCreating;
    public Visibility IsCreatingVis => _isCreating ? Visibility.Visible : Visibility.Hidden;
    public bool CanCreate => SelectedLayouts.Count > 0;
    public BindableCollection<string> Layouts { get; } = [];
}