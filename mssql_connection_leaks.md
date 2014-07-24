# SQL Server connection-leak debugging: state of the art (30 June 2014)

Tell-tale exception:

> System.InvalidOperationException: Timeout expired. The timeout period elapsed prior to obtaining a connection from the pool.
> This may have occurred because all pooled connections were in use and max pool size was reached.

exec sp_who2

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

