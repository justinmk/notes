Imagine you have an existing Visual Studio solution (`.sln`) containing several
projects (`.csproj`) which have installed Entity Framework via NuGet, and you
want to modify the [EF source](https://github.com/aspnet/EntityFramework) and
use that modified version instead of the NuGet version.

Before compiling your modified version of EF, make sure you disable signing[1],
and change the AssemblyVersion (in `SharedAssemblyVersionInfo.cs`) to something
other than the version they're shipping, (to be super sure you are referencing
the modified EF assembly and not some cached assembly hiding in the binder's
search path).

Here it's changed it to 6.0.0.42 (the other entries don't matter[2]):

```cs
#if !BUILD_GENERATED_VERSION
[assembly: AssemblyVersion("6.0.0.42")]
[assembly: AssemblyFileVersion("6.1.0.0")]
[assembly: AssemblyInformationalVersion("6.1.0-alpha1")]
[assembly: SatelliteContractVersion("6.0.0.0")]
#endif
```

Then uninstall EF from NuGet (double-check that all of your project
`packages.config` files have been scrubbed) and update all `.csproj` references
to point to your *modified EF*:

    <Reference Include="EntityFramework, Version=6.0.0.42, Culture=neutral, processorArchitecture=MSIL">
      <HintPath>..\App\Lib\EntityFramework.dll</HintPath>
    </Reference>
    <Reference Include="EntityFramework.SqlServer, Version=6.0.0.42, Culture=neutral, processorArchitecture=MSIL">
      <HintPath>..\App\Lib\EntityFramework.SqlServer.dll</HintPath>
    </Reference>

Then if you run your program/website, you get a "manifest mismatch" error:

> Could not load file or assembly 'EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
> or one of its dependencies. The located assembly's manifest definition does not match the assembly reference. (Exception from HRESULT: 0x80131040)

You might [delete ASP.NET temporary assembly cache]
You could try uninstalling EF from the GAC, via the "Developer Command Prompt"[3]:

    :see if EntityFramework is in the GAC
    gacutil /l EntityFramework
    :uninstall it
    gacutil /u "EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"

But the error won't go away. Why is the binder "ignoring" our references to the
modified EntityFramework{.SqlServer}? Take a step back. Notice the exception
message mentions *Version=6.0.0.0*. Where is that coming from?

The .NET binder resolves references using this [search order](http://stackoverflow.com/a/2733113/152142):

- Files in the current project (MSBuild property `{CandidateAssemblyFiles}`).
- `$(ReferencePath)` property that comes from `.user` or `.targets` file.
- `%(HintPath)` metadata indicated by reference item.
- Target .NET framework directory.
- Directories found in the registry that use AssemblyFoldersEx Registration.
- Registered assembly folders, indicated by `{AssemblyFolders}`.
- `$(OutputPath)` or `$(OutDir)`
- GAC

And there are [even more rules](http://msdn.microsoft.com/en-us/library/yx7xezcf%28v%3Dvs.110%29.aspx).
In particular, you can [control binding via `<assemblyBinding>`](http://msdn.microsoft.com/en-us/library/8f6988ab%28v%3Dvs.110%29.aspx):

> the common language runtime checks the application configuration file for
> information that **overrides the version information stored in the calling
> assembly's manifest**.

So you can *override the manifest*, for example, by using a `<bindingRedirect>`.
NuGet has a habit of puking out `<bindingRedirect>`s for every project in your `.sln`,
[whether you like it or not](http://stackoverflow.com/a/22228738/152142);
you might think this is just noise until you try to change a reference
in one project without updating the `App.config`s (it's still pretty noisy, though).

But if you add a `<bindingRedirect>` to your project, the error wont' go away. Why?

ASP.NET shows "Assembly Load Trace" (the same log that Fusion Log Viewer shows!
But if you have a component such as an IoC that dynamically loads some assemblies, you may not see the ASP.NET error page).

For binding issues, reach for the [Fusion Log Viewer](http://www.hanselman.com/blog/BackToBasicsUsingFusionLogViewerToDebugObscureLoaderErrors.aspx).
This tool (included with Visual Studio) tells you where a reference is coming from.

- Open "Developer Command Prompt" and run `fuslogvw.exe`.
- Click "Settings"
- Check "Log bind failures to disk"
- Next time a binding error happens, it should show up in the viewer.
    - If it doesn't, go to "Settings" again, check "Enable custom log path",
      and set "Custom log path" to a writable directory (somwhere in your home folder).
      Then try again, and check the folder. If it *still* doesn't work, reboot. Yes, seriously.

Open the fusion log file (named like `Default/b85f73b8/EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089.HTM`):

    *** Assembly Binder Log Entry  (8/7/2014 @ 12:14:38 PM) ***

    The operation failed.
    Bind result: hr = 0x80131040. No description available.

    Assembly manager loaded from:  C:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll
    Running under executable  C:\Windows\SysWOW64\inetsrv\w3wp.exe
    --- A detailed error log follows. 

    === Pre-bind state information ===
    LOG: DisplayName = EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
     (Fully-specified)
    LOG: Appbase = file:///C:/projects.git/Psa/dev/ServerStaging/App/
    LOG: Initial PrivatePath = C:\projects.git\Psa\dev\ServerStaging\App\bin
    LOG: Dynamic Base = C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\v4_6_development\9347a27e
    LOG: Cache Base = C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\v4_6_development\9347a27e
    LOG: AppName = b85f73b8
    Calling assembly : Foo.Bar, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null.
    ===

Pay attention to "Calling assembly", Version, and PublicKeyToken.

After you fix the reference from the calling assembly "Foo.Bar", if the error
happens again, the calling assembly will be different: then you need to fix the
reference from *that* project (and add a binding `<bindingRedirect>` to that
project's App.config), and so on.

System.AppDomain.CurrentDomain.AssemblyResolve
AppDomain.CurrentDomain.ReflectionOnlyAssemblyResolve
  are useful but in my case they were sending ResolveEventArgs.RequestingAssembly as null, so that dosen't help.

Assembly.LoadFrom() isn't going to solve a manifest mismatch.

    App.config

      <configuration>
        <runtime>
          <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
            <dependentAssembly>
                <assemblyIdentity name="EntityFramework" publicKeyToken="b77a5c561934e089" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-7.0.0.0" newVersion="6.0.0.42" />
            </dependentAssembly>
            <dependentAssembly>
                <assemblyIdentity name="EntityFramework.SqlServer" publicKeyToken="b77a5c561934e089" culture="neutral" />
                <bindingRedirect oldVersion="0.0.0.0-7.0.0.0" newVersion="6.0.0.42" />
            </dependentAssembly>
          </assemblyBinding>
        </runtime>
      </configuration>

["To make effective use of the Binder ... avoid partial binds"](http://msdn.microsoft.com/en-us/magazine/dd727509.aspx).
Use the fully specified assembly name (simple name, version, culture, and public key token).

"Partial binds lead to nondeterministic Binder behavior"

note: specifying publicKeyToken="" or publicKeyToken="null" is useless because the binder will just look for the first match.

App.config and Web.config most certainly can affect the compiled assembly.
  http://stackoverflow.com/a/22228738/152142

But _dependent_ project .config does not matter:
  Web.Config

   </dependentAssembly>
       <dependentAssembly>
         <assemblyIdentity name="Newtonsoft.Json" publicKeyToken="30ad4fe6b2a6aeed" culture="neutral" />
         <bindingRedirect oldVersion="0.0.0.0-6.0.0.0" newVersion="6.0.0.0" />
       </dependentAssembly>
     </assemblyBinding>
   </runtime>

packages.config doesn't matter:

    <packages>
      <package id="EntityFramework" version="6.1.0" targetFramework="net40" />
    </packages>


[1] In Visual Studio: go to project properties, Signing, uncheck "Sign the assembly"

[2] AssemblyVersion is the *only* value the .NET binder cares about.
    AssemblyFileVersion is used [to indicate a build number without affecting downstream
    compilation](http://www.danielfortunov.com/software/$daniel_fortunovs_adventures_in_software_development/2009/03/03/assembly_versioning_in_net).

[3] This basically just adds `%VS120COMNTOOLS%` to your `%PATH%`.
