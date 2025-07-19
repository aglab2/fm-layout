using System.Reflection;
using System.Windows;
using Caliburn.Micro;
using OBSWebsocketDotNet;
using schedule_fetcher.Services;
using schedule_fetcher.ViewModels;

namespace schedule_fetcher;

public class Bootstrapper : BootstrapperBase
{
    private SimpleContainer _container;
    public Bootstrapper()
    {
        Initialize();
    }
    
    protected override void Configure()
    {
        _container = new SimpleContainer();

        _container.Singleton<IWindowManager, WindowManager>();
        _container.Singleton<IEventAggregator, EventAggregator>();
        _container.Singleton<ObsClient.ObsClient>();
        _container.Singleton<SpreadsheetClient.SpreadsheetClient>();
        _container.Singleton<SelectedSceneService>();
        _container.Singleton<SelectedRunService>();

        foreach (var assembly in SelectAssemblies())
        {
            assembly.GetTypes()
                .Where(type => type.IsClass)
                .Where(type => type.Name.EndsWith("ViewModel"))
                .ToList()
                .ForEach(viewModelType =>
                {
                    _container.RegisterPerRequest(viewModelType, viewModelType.ToString(), viewModelType);
                });
        }
    }

    protected override object GetInstance(Type service, string key)
    {
        return _container.GetInstance(service, key);
    }

    protected override IEnumerable<object> GetAllInstances(Type service)
    {
        return _container.GetAllInstances(service);
    }

    protected override void BuildUp(object instance)
    {
        _container.BuildUp(instance);
    }

    protected override void OnStartup(object sender, StartupEventArgs e)
    {
        DisplayRootViewForAsync<ShellViewModel>();
    }
    
}