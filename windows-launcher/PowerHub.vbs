Option Explicit

' Launcher for PowerHub: checks GitHub for a newer index.html, applies it if
' found, shows a small auto-closing popup (no console window), then opens the
' app. See README.md for setup and what each message means.

Dim fso, shell, scriptDir, rawUrl, tmpFile, htmlFile, psCmd, exitCode

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
' TODO: replace with your actual GitHub username/repo once it exists.
rawUrl = "https://raw.githubusercontent.com/ptogias/powerhub/main/index.html"
tmpFile = shell.ExpandEnvironmentStrings("%TEMP%") & "\powerhub_update.html"
htmlFile = scriptDir & "\index.html"

If fso.FileExists(tmpFile) Then fso.DeleteFile tmpFile, True

' Exit codes from the PowerShell call: 0 = downloaded fine, 1 = no response at
' all (no internet), 2 = got a response but it was an error (bad URL/branch).
psCmd = "powershell -NoProfile -WindowStyle Hidden -Command " & _
        """try { Invoke-WebRequest -Uri '" & rawUrl & "' -OutFile '" & tmpFile & _
        "' -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop; exit 0 } " & _
        "catch { if ($_.Exception.Response) { exit 2 } else { exit 1 } }"""

exitCode = shell.Run(psCmd, 0, True)

Select Case exitCode
    Case 1
        shell.Popup "Δεν υπάρχει σύνδεση στο διαδίκτυο - δεν έγιναν ενημερώσεις.", 3, "PowerHub", 64
    Case 2
        shell.Popup "Βρέθηκε σύνδεση στο διαδίκτυο, αλλά η ενημέρωση απέτυχε - δεν έγιναν ενημερώσεις.", 3, "PowerHub", 48
    Case 0
        If fso.FileExists(tmpFile) And fso.GetFile(tmpFile).Size > 0 Then
            If FileHash(tmpFile) = FileHash(htmlFile) Then
                shell.Popup "Βρέθηκε σύνδεση στο διαδίκτυο - δεν υπάρχουν ενημερώσεις.", 3, "PowerHub", 64
            Else
                fso.CopyFile tmpFile, htmlFile, True
                shell.Popup "Βρέθηκε σύνδεση στο διαδίκτυο - έγιναν ενημερώσεις.", 3, "PowerHub", 64
            End If
            fso.DeleteFile tmpFile, True
        Else
            shell.Popup "Δεν υπάρχει σύνδεση στο διαδίκτυο - δεν έγιναν ενημερώσεις.", 3, "PowerHub", 64
        End If
End Select

shell.Run """" & htmlFile & """", 1, False

' SHA-256 hash via the built-in certutil, so files are compared byte-for-byte
' regardless of text encoding (handles Greek text in the HTML correctly).
Function FileHash(path)
    Dim execObj, output, lines
    If Not fso.FileExists(path) Then
        FileHash = ""
        Exit Function
    End If
    Set execObj = shell.Exec("certutil -hashfile """ & path & """ SHA256")
    Do While execObj.Status = 0
        WScript.Sleep 50
    Loop
    output = execObj.StdOut.ReadAll()
    lines = Split(output, vbCrLf)
    If UBound(lines) >= 1 Then
        FileHash = Trim(lines(1))
    Else
        FileHash = ""
    End If
End Function
