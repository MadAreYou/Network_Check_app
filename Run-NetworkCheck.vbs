' Network Check - VBScript Launcher
' This script launches the Network Check application with a completely hidden PowerShell window
' Double-click this file to start the application without any console windows appearing

Dim objShell, strScriptPath, strPSPath, strCommand

' Get the directory where this VBS script is located
strScriptPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

' Build the PowerShell command with -NoProfile and -WindowStyle Hidden
strPSPath = strScriptPath & "\NetworkCheckApp.ps1"
strCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -File """ & strPSPath & """"

' Create shell object and run the command with window style = 0 (completely hidden)
Set objShell = CreateObject("WScript.Shell")
objShell.Run strCommand, 0, False

' Clean up
Set objShell = Nothing
