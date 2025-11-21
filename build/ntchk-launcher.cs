using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

// Assembly metadata for file properties
[assembly: AssemblyTitle("ntchk")]
[assembly: AssemblyDescription("ntchk - Network Toolkit (Policy-Friendly Launcher)")]
[assembly: AssemblyCompany("Juraj Madzunkov")]
[assembly: AssemblyProduct("ntchk - Network Toolkit")]
[assembly: AssemblyCopyright("Copyright (c) 2025 Juraj Madzunkov")]
[assembly: AssemblyVersion("1.0.3.0")]
[assembly: AssemblyFileVersion("1.0.3.0")]

namespace NtchkLauncher
{
    /// <summary>
    /// Policy-friendly launcher for ntchk (Network Toolkit)
    /// Compiles to ntchk.exe - launches PowerShell application hidden
    /// No VBScript dependencies - pure .NET executable
    /// 
    /// To compile this into ntchk.exe, run from PowerShell:
    /// 
    /// Add-Type -TypeDefinition (Get-Content .\ntchk-launcher.cs -Raw) `
    ///     -OutputAssembly "..\ntchk.exe" `
    ///     -OutputType ConsoleApplication `
    ///     -ReferencedAssemblies System.dll
    /// 
    /// OR use the build script: .\Build-Launcher.ps1
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                // Get the directory where the EXE is located
                string exeDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
                
                // Path to the PowerShell script
                string psScriptPath = Path.Combine(exeDir, "ntchk.ps1");
                
                // Verify the PowerShell script exists
                if (!File.Exists(psScriptPath))
                {
                    Console.WriteLine("Error: ntchk.ps1 not found in application directory.");
                    Console.WriteLine("Expected location: " + psScriptPath);
                    Console.WriteLine("\nPress any key to exit...");
                    Console.ReadKey();
                    Environment.Exit(1);
                }
                
                // Configure the PowerShell process to run hidden
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = string.Format(
                        "-WindowStyle Hidden -ExecutionPolicy Bypass -File \"{0}\"",
                        psScriptPath
                    ),
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WindowStyle = ProcessWindowStyle.Hidden
                };
                
                // Start PowerShell process
                Process.Start(psi);
                
                // Exit launcher immediately (don't wait for PowerShell to finish)
                Environment.Exit(0);
            }
            catch (Exception ex)
            {
                // If launch fails, show error to user
                Console.WriteLine("Failed to launch ntchk:");
                Console.WriteLine(ex.Message);
                Console.WriteLine("\nTry running ntchk.ps1 directly:");
                Console.WriteLine("Right-click ntchk.ps1 > Run with PowerShell");
                Console.WriteLine("\nPress any key to exit...");
                Console.ReadKey();
                Environment.Exit(1);
            }
        }
    }
}
