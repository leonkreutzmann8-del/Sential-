# Sentinel Desktop Verknüpfung mit Icon erstellen
$SentinelDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Sentinel.lnk")
$Shortcut.TargetPath = "$SentinelDir\start.bat"
$Shortcut.WorkingDirectory = $SentinelDir
$Shortcut.Description = "Sentinel Security Monitor"
$Shortcut.IconLocation = "$SentinelDir\assets\sentinel.ico"
$Shortcut.WindowStyle = 7
$Shortcut.Save()
Write-Host "Verknuepfung erstellt auf dem Desktop!" -ForegroundColor Green
Write-Host "Icon: $SentinelDir\assets\sentinel.ico"
