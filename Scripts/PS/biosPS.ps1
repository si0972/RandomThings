﻿$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition
$url = "https://downloads.dell.com/FOLDER04358530M/1/Dell-Command-Update_X79N4_WIN_2.3.1_A00.EXE"
$output = "$scriptDir\DCU_Setup.exe"
$usbdir = "$scriptDir\DCU_Setup.exe"
$start_time = Get-Date
#$WorkDir= "C:\temp\biosPS"
$pf86= "C:\Program Files (x86)"
$FileExists = Test-Path $output
$USBExists = Test-Path $usbdir
$Name = (Get-WmiObject Win32_Computersystem).name
$Logfile ="$scriptDir\$Name.log"

Start-Transcript -path $Logfile -append -NoClobber -IncludeInvocationHeader


if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Stop-Service -DisplayName "Windows Audio"

Write-Host "Checking if $output or $usbdir exits"

If ($USBExists -eq $True) {
Write-Host "$usbdir does exist"
cd $usbdir
$exe=$usbdir
}
ElseIf (-Not $FileExists -eq $True) {
Write-Host "$output does not exists"
#New-Item -ItemType directory -Path $scriptDir
cd $scriptDir
echo "Downloading"
Invoke-WebRequest -Uri $url -OutFile $output
$exe=$output
echo "Download complete"
}
Else {
Write-Host "EXE=$exe"
Write-Host "Error"
pause
exit
}

$exe = $exe.replace('\\','\')
Write-Host "EXE=$exe"

echo "Disabling BitLocker"
Suspend-BitLocker -MountPoint "C:" -RebootCount 2
echo "BitLocker disabled"
echo "Running Installer"
& $exe /s
Start-Sleep -s 10
echo "Installer Complete"
echo "Running Updater"
& "$pf86\Dell\CommandUpdate\dcu-cli.exe"
echo "Updater run"
Write-Host "Machine will restart"
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
start-Service -DisplayName "Windows Audio"
#pause
cmd /c shutdown /r /t 45
Stop-Transcript
