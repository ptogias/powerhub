Option Explicit

' Launcher for PowerHub: checks GitHub for a newer index.html, applies it if
' found, shows a small auto-closing popup (no console window), then opens the
' app. See README.md for setup and what each message means.
'
' NOTE: this file must stay saved as UTF-16 LE with BOM (the repo's
' .gitattributes takes care of that on checkout). Windows Script Host cannot
' read UTF-8 — the Greek text in the popups would come out as gibberish.

Dim fso, shell, scriptDir, rawUrl, tmpFile, htmlFile

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
rawUrl = "https://raw.githubusercontent.com/ptogias/powerhub/main/index.html"
tmpFile = shell.ExpandEnvironmentStrings("%TEMP%") & "\powerhub_update.html"
htmlFile = scriptDir & "\index.html"

' Whatever goes wrong while updating (no PowerShell, index.html locked or
' read-only, temp folder not writable...), the app must still open — an
' unhandled error here would show a raw script error and stop before that.
On Error Resume Next
RunUpdate
If Err.Number <> 0 Then
    shell.Popup "Η ενημέρωση απέτυχε (" & Err.Description & ") - δεν έγιναν ενημερώσεις.", 4, "PowerHub", 48
    Err.Clear
End If
On Error GoTo 0

OpenApp

Sub RunUpdate()
    Dim psCmd, exitCode
    If fso.FileExists(tmpFile) Then fso.DeleteFile tmpFile, True

    ' One hidden PowerShell call downloads AND compares, so no console window
    ' ever appears (WScript's Exec, used before for certutil, flashes one).
    ' Exit codes: 0 = downloaded, identical to the local file (SHA-256)
    '             1 = no response at all (no internet), or empty download
    '             2 = got a response but it was an error (bad URL/branch)
    '             3 = downloaded and it differs (or no local index.html yet)
    ' TLS 1.2 is switched on explicitly: GitHub requires it, and PowerShell
    ' on older Windows doesn't enable it by default (that failure would
    ' otherwise be reported as "no internet").
    psCmd = "powershell -NoProfile -NonInteractive -WindowStyle Hidden -Command """ & _
        "try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072 } catch {}; " & _
        "try { Invoke-WebRequest -Uri " & PsQuote(rawUrl) & " -OutFile " & PsQuote(tmpFile) & " -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop } " & _
        "catch { if ($_.Exception.Response) { exit 2 } else { exit 1 } }; " & _
        "if (-not (Test-Path -LiteralPath " & PsQuote(tmpFile) & ") -or (Get-Item -LiteralPath " & PsQuote(tmpFile) & ").Length -eq 0) { exit 1 }; " & _
        "if (-not (Test-Path -LiteralPath " & PsQuote(htmlFile) & ")) { exit 3 }; " & _
        "try { if ((Get-FileHash -LiteralPath " & PsQuote(tmpFile) & " -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath " & PsQuote(htmlFile) & " -Algorithm SHA256).Hash) { exit 0 } } catch {}; " & _
        "exit 3"""

    exitCode = shell.Run(psCmd, 0, True)

    Select Case exitCode
        Case 0
            shell.Popup "Βρέθηκε σύνδεση στο διαδίκτυο - δεν υπάρχουν ενημερώσεις.", 3, "PowerHub", 64
        Case 1
            shell.Popup "Δεν υπάρχει σύνδεση στο διαδίκτυο - δεν έγιναν ενημερώσεις.", 3, "PowerHub", 64
        Case 2
            shell.Popup "Βρέθηκε σύνδεση στο διαδίκτυο, αλλά η ενημέρωση απέτυχε - δεν έγιναν ενημερώσεις.", 3, "PowerHub", 48
        Case 3
            fso.CopyFile tmpFile, htmlFile, True
            shell.Popup "Βρέθηκε σύνδεση στο διαδίκτυο - έγιναν ενημερώσεις.", 3, "PowerHub", 64
        Case Else
            shell.Popup "Ο έλεγχος ενημερώσεων απέτυχε (κωδικός " & exitCode & ") - δεν έγιναν ενημερώσεις.", 4, "PowerHub", 48
    End Select

    If fso.FileExists(tmpFile) Then fso.DeleteFile tmpFile, True
End Sub

Sub OpenApp()
    If Not fso.FileExists(htmlFile) Then
        shell.Popup "Δεν βρέθηκε το αρχείο index.html δίπλα στο PowerHub.vbs. Ελέγξτε τον φάκελο της εφαρμογής ή τη σύνδεση στο διαδίκτυο.", 0, "PowerHub", 16
        Exit Sub
    End If
    On Error Resume Next
    shell.Run """" & htmlFile & """", 1, False
    If Err.Number <> 0 Then
        shell.Popup "Δεν ήταν δυνατό το άνοιγμα της εφαρμογής (" & Err.Description & ").", 0, "PowerHub", 16
        Err.Clear
    End If
End Sub

' Wraps a value as a single-quoted PowerShell string literal (the only
' character that needs escaping inside one is the quote itself).
Function PsQuote(s)
    PsQuote = "'" & Replace(s, "'", "''") & "'"
End Function
