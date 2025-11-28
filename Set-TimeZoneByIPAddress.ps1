<# 
.SYNOPSIS
    Sets the Windows time zone automatically based on the public IP address using IANA to Windows time zone conversion.

.DESCRIPTION
    This script queries http://ipinfo.io/json to determine the device's geographic IANA time zone, 
    maps it to the correct Windows time zone using a local XML source, and sets the local time zone accordingly.

.NOTES
    Author:        Ankur Arora
    Version:       1
    Last Updated:  2025-11-28
    Run As:        SYSTEM (not user)
    Architecture:  Must run in 64-bit context
#>

$PackageName = "Set-TimeZoneByIPAddress"
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-script.log" -Force -Append

try {
    Write-Output "Fetching IANA time zone from ipinfo.io..."
    $ianaTz = (Invoke-RestMethod -Uri "http://ipinfo.io/json").timezone
    if (-not $ianaTz) {
        throw "Could not retrieve IANA time zone from ipinfo.io."
    }
    Write-Output "Detected IANA Time Zone: $ianaTz"

    Write-Output "Loading local XML mapping file..."
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $xmlPath = Join-Path $scriptRoot "windowsZones.xml"
    if (-not (Test-Path $xmlPath)) {
        throw "Local XML mapping file not found at $xmlPath"
    }
    [xml]$windowsZones = Get-Content $xmlPath
    if (-not $windowsZones) {
        throw "Failed to load or parse the XML mapping file."
    }

    Write-Output "Searching for matching mapping..."
    $mapping = $windowsZones.supplementalData.windowsZones.mapTimezones.mapZone | Where-Object {
        $_.type -split ' ' -contains $ianaTz
    }

    if (-not $mapping) {
        throw "No mapping found for IANA time zone: $ianaTz"
    }

    $windowsTZ = $mapping.other | Select-Object -First 1
    Write-Output "Mapped to Windows Time Zone: $windowsTZ"

    try {
        Write-Output "Setting Windows time zone using Set-TimeZone..."
        Set-TimeZone -Id $windowsTZ
        Write-Output "Successfully set Windows Time Zone: $windowsTZ"
    } catch {
        Write-Error "Set-TimeZone failed."
    }

} catch {
    Write-Error "Failed to set Windows time zone: $_"
}
Stop-Transcript
$Path = "HKEY_LOCAL_MACHINE\SOFTWARE\AP-SetTimezone"
$Key = "Version" 
$KeyFormat = "dword"
$Value = "1"

if(!(Test-Path $Path)){New-Item -Path $Path -Force}
if(!$Key){Set-Item -Path $Path -Value $Value
}else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}
