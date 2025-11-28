#  Intune Deployment: Auto Time Zone Script

This project contains a PowerShell script that automatically sets the Windows time zone based on the device's public IP address, writes a registry key for detection, and provides guidance on packaging and deploying the script via Intune.

---

## 📝 Script Overview
- Queries `http://ipinfo.io/json` to get the device's **IANA time zone**  
- Maps the IANA time zone to the corresponding **Windows time zone** using a local XML mapping file  
- Sets the Windows time zone using the **`Set-TimeZone`** cmdlet  
- Writes a registry key **`TimeZoneSet`** under `HKLM\Software\AP-SetTimezone` with the Windows time zone string for detection purposes  

---

## How to Create an Intunewin Package and Upload to Intune

**Follow these steps to package the script into an `.intunewin` file and deploy it via Microsoft Intune:**

### 1. Prepare Your Script and Supporting Files
Place your PowerShell script (e.g., `Set-TimeZoneByIPAddress.ps1`) and any required files (like `windowsZones.xml`) in a single folder.

### 2. Download the Microsoft Win32 Content Prep Tool
- Download the tool from the official Microsoft GitHub repository: **Intune Win32 Content Prep Tool**  
- Extract the tool to a convenient location.

### 3. Create the `.intunewin` Package
Open a PowerShell or Command Prompt window and run:

Powershell
IntuneWinAppUtil.exe -c "C:\Path\To\Your\Folder" -s "Set-TimeZoneByIPAddress.ps1" -o "C:\Path\To\Output\Folder"

### 4. Create the `.intunewin` Package

 ### 5. Configure Program
For Install command, enter:
powershell.exe -ExecutionPolicy Bypass -File Set-TimeZoneByIPAddress.ps1

 ### 6. For Uninstall command, 

reg delete "HKLM\SOFTWARE\AP-Set-TimeZone" /f


 ### 7. Configure Requirements
Specify the minimum OS version and architecture (e.g., Windows 11 64-bit).

 ### 8. Detection Logic

If you're versioning your script or deployment logic

- **Key path:** `HKEY_LOCAL_MACHINE\SOFTWARE\AP-SetTimezone`  
- **Value name:** `Version`  
- **Detection method:** *ValueExist*  

### You can also set detection logic to FILE 

"C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Set-TimeZoneByIPAddress-script.log"

## With updated Uninstall command

powershell.exe -ExecutionPolicy Bypass -Command "Remove-Item -Path '$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\set-timezonebyipaddress-script.log' -Force"
