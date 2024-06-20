using System.Diagnostics;

var stopwatch = Stopwatch.StartNew();
var builder = WebApplication.CreateSlimBuilder(args);

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

await app.StartAsync();
stopwatch.Stop();
Console.WriteLine($"Started {stopwatch}");

double workingSet = Process.GetCurrentProcess().WorkingSet64;
Console.WriteLine($"Working Set: {workingSet / (1024 * 1024):N2}MB");

await app.WaitForShutdownAsync();
Console.WriteLine("Stopped");
