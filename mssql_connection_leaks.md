TODO: 
    http://www.brentozar.com/archive/2010/09/sql-server-dba-scripts-how-to-find-slow-sql-server-queries/
    http://blogs.msdn.com/b/angelsb/archive/2004/08/25/220333.aspx

# SQL Server connection-leak debugging: state of the art (30 June 2014)

Tell-tale exception:

> System.InvalidOperationException: Timeout expired. The timeout period elapsed prior to obtaining a connection from the pool.
> This may have occurred because all pooled connections were in use and max pool size was reached.

## Observing from SQL Server

exec `sp_who2`

```
SPID Status      Login                DBName        Command           ProgramName
======================================================================================================
31   BACKGROUND  sa                   master        FT CRAWL MON                                      
32   sleeping    sa                   master        TASK MANAGER                                      
34   BACKGROUND  sa                   NULL          UNKNOWN TOKEN                                     
51   sleeping    NT AUTHORITY\SYSTEM  msdb          AWAITING COMMAND  SQLAgent - Job invocation engine
52   sleeping    NT AUTHORITY\SYSTEM  ReportServer  AWAITING COMMAND  Report Server                   
[...]
83   sleeping    NT AUTHORITY\SYSTEM  FooApp        AWAITING COMMAND  .Net SqlClient Data Provider
84   sleeping    NT AUTHORITY\SYSTEM  FooApp        AWAITING COMMAND  .Net SqlClient Data Provider
```

The `sp_who2` list is more convenient if you set the `Application Name`
parameter in your SQL connection string.

```cs
    + ";Application Name=" + this.appName + "/Database/" + subModuleName + ";";
```

## Observing from the .NET application

Windows *performance counters* can be used to observe the connection pool
behavior. Awkwardly derive the "instance name" from the application name, then
PerformanceCounter.NextValue() should report the value.
`NumberOfReclaimedConnections` is probably the one you care about for leaks.

```cs
using System.Runtime.InteropServices;

[DllImport("kernel32.dll", SetLastError = true)]
static extern int GetCurrentProcessId();

private void openConnectionIfNecessary() {
    // Open a connection and create the performance counters.
    // http://msdn.microsoft.com/en-us/library/ms254503%28v=vs.80%29.aspx

    string instanceName = AppDomain.CurrentDomain.FriendlyName.Replace('(','[')
        .Replace(')',']').Replace('#','_').Replace('/','_').Replace('\\','_').ToLower()
        + "[" + GetCurrentProcessId() + "]";

    connection.Open();

    var p = new PerformanceCounter {
        CategoryName = ".NET Data Provider for SqlServer",
                     CounterName = "NumberOfReclaimedConnections",
                     InstanceName = instanceName
    };
    DebugOutput.Output("NumberOfReclaimedConnections: "+p.NextValue());
}
```
