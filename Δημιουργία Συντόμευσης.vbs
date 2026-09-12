Option Explicit

' One-time setup: creates a desktop shortcut to PowerHub.vbs so the person
' doesn't need to find this folder every time. Run once, then delete or ignore.

Dim fso, shell, scriptDir, desktopPath, shortcut

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
desktopPath = shell.SpecialFolders("Desktop")

Set shortcut = shell.CreateShortcut(desktopPath & "\PowerHub.lnk")
shortcut.TargetPath = scriptDir & "\PowerHub.vbs"
shortcut.WorkingDirectory = scriptDir
shortcut.IconLocation = "shell32.dll,137"
shortcut.Description = "Άνοιγμα PowerHub"
shortcut.Save

shell.Popup "Η συντόμευση δημιουργήθηκε στην επιφάνεια εργασίας.", 4, "PowerHub", 64
