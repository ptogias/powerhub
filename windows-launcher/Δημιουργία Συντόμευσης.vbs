Option Explicit

' One-time setup: creates a desktop shortcut to PowerHub.vbs so the person
' doesn't need to find this folder every time. Run once, then delete or ignore.
'
' NOTE: keep this file saved as UTF-16 LE with BOM (see .gitattributes) —
' Windows Script Host cannot read UTF-8 and would garble the Greek text.

Dim fso, shell, scriptDir, desktopPath, shortcut

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
desktopPath = shell.SpecialFolders("Desktop")

On Error Resume Next
Set shortcut = shell.CreateShortcut(desktopPath & "\PowerHub.lnk")
shortcut.TargetPath = scriptDir & "\PowerHub.vbs"
shortcut.WorkingDirectory = scriptDir
shortcut.IconLocation = scriptDir & "\powerhub.ico,0"
shortcut.Description = "Άνοιγμα PowerHub"
shortcut.Save
If Err.Number <> 0 Then
    shell.Popup "Η δημιουργία της συντόμευσης απέτυχε (" & Err.Description & ").", 0, "PowerHub", 16
Else
    shell.Popup "Η συντόμευση δημιουργήθηκε στην επιφάνεια εργασίας.", 4, "PowerHub", 64
End If
