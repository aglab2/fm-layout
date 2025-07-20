using Caliburn.Micro;

namespace schedule_fetcher.ViewModels;

public class LayoutTabsViewModel
{
    public LayoutInfoViewModel LayoutInfo => IoC.Get<LayoutInfoViewModel>();
    public TimerViewModel Timer => IoC.Get<TimerViewModel>();
    public RelayRaceViewModel RelayRace => IoC.Get<RelayRaceViewModel>();
}