# Comprehensive Installer Ecosystems Guide

**Last Updated:** November 2024 | **Version:** 1.0

A detailed guide to building, packaging, and distributing software installers across Windows, macOS, Linux, and cross-platform ecosystems. Includes practical examples, commands, and troubleshooting.

---

## Table of Contents

1. [Windows Installers](#windows-installers)
2. [macOS Installers](#macos-installers)
3. [Linux Packages](#linux-packages)
4. [Cross-Platform Solutions](#cross-platform-solutions)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## WINDOWS INSTALLERS

### 1. MSI with WiX Toolset

**Overview:** MSI (Microsoft Installer) is the standard Windows installer format. WiX (Windows Installer XML) is an open-source toolset for creating MSI packages using XML definitions.

**Key Concepts:**
- Components are the basic installation units for files and registry settings
- Product ID should be a wildcard for automatic generation on each build
- UpgradeCode must remain constant to link different package versions
- Use WiX 4 (latest) delivered via NuGet packages

**Basic WXS File Example:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs"
     xmlns:ui="http://wixtoolset.org/schemas/v4/wxs/ui">

  <Product Id="*"
           Name="MyApp"
           Language="1033"
           Version="1.0.0.0"
           UpgradeCode="12345678-1234-1234-1234-123456789012"
           Manufacturer="MyCompany">

    <Package InstallerVersion="200"
             Compressed="yes"
             InstallScope="perMachine"
             Description="MyApp Installer"
             Manufacturer="MyCompany" />

    <Media Id="1" Cabinet="myapp.cab" EmbedCab="yes" />

    <Feature Id="ProductFeature"
             Title="MyApp"
             Level="1"
             Description="Main application">
      <ComponentRef Id="MainExecutable" />
      <ComponentRef Id="ProgramFilesFolder_Data" />
    </Feature>

    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="ProgramFilesFolder">
        <Directory Id="INSTALLFOLDER" Name="MyApp" />
      </Directory>
      <Directory Id="ProgramMenuFolder">
        <Directory Id="ApplicationProgramsFolder" Name="MyApp" />
      </Directory>
    </Directory>

    <Component Id="MainExecutable"
               Directory="INSTALLFOLDER"
               Guid="87654321-4321-4321-4321-210987654321">
      <File Id="myapp.exe"
            Name="myapp.exe"
            Source="$(var.SourceDir)\myapp.exe"
            KeyPath="yes" />
      <ProgId Id="myapp.application"
              Description="MyApp Application">
        <Extension Id="txt">
          <Verb Id="open" Command="Open" TargetFile="myapp.exe" Argument='"%1"' />
        </Extension>
      </ProgId>
    </Component>

    <Component Id="ProgramFilesFolder_Data"
               Directory="INSTALLFOLDER"
               Guid="11223344-5566-7788-99aa-bbccddeeff00">
      <File Id="config.json"
            Name="config.json"
            Source="$(var.SourceDir)\config.json"
            KeyPath="yes" />
    </Component>

    <Component Id="ApplicationShortcuts"
               Directory="ApplicationProgramsFolder"
               Guid="aabbccdd-eeff-0011-2233-445566778899">
      <Shortcut Id="ApplicationStartMenuShortcut"
                Name="MyApp"
                Description="Launch MyApp"
                Target="[INSTALLFOLDER]myapp.exe"
                WorkingDirectory="INSTALLFOLDER" />
      <RemoveFolder Id="ApplicationProgramsFolder" On="uninstall" />
      <RegistryValue Root="HKCU"
                     Key="Software\MyCompany\MyApp"
                     Name="installed"
                     Type="integer"
                     Value="1"
                     KeyPath="yes" />
    </Component>

    <UIRef Id="WixUI_InstallDir" />
    <WixVariable Id="WixUILicenseRtf" Value="License.rtf" />

    <RegistryKey Root="HKLM"
                 Key="Software\MyCompany\MyApp">
      <RegistryValue Type="string"
                     Name="InstallLocation"
                     Value="[INSTALLFOLDER]" />
      <RegistryValue Type="string"
                     Name="Version"
                     Value="1.0.0.0" />
    </RegistryKey>
  </Product>
</Wix>
```

**Build Commands:**

```bash
# Install WiX (via NuGet)
dotnet tool install --global WiX

# Set compiler variables
set SourceDir=C:\Path\To\Binaries

# Compile WXS to WXO (object file)
candle.exe -d SourceDir=%SourceDir% MyApp.wxs -o MyApp.wixo

# Link WXO to MSI
light.exe -out MyApp.msi MyApp.wixo

# Build with preprocessor variables
wix build MyApp.wxs -o MyApp.msi -d SourceDir=C:\Binaries

# Silent installation
msiexec /i MyApp.msi /quiet /qn ALLUSERS=1 INSTALLFOLDER="C:\Program Files\MyApp\"
```

**Best Practices:**
- Always test installation, uninstallation, and upgrade scenarios
- Use proper GUIDs for each component (generate with `New-Guid` in PowerShell)
- Keep components small and focused (files with similar lifecycle)
- Use `RemoveFile` and `RemoveFolder` to clean up on uninstall
- Validate with `light.exe -v` for verbose output

**Troubleshooting:**

```bash
# Enable verbose logging
msiexec /i MyApp.msi /l*v install.log

# Check MSI validation
dark.exe MyApp.msi -x output.wxs  # Decompile MSI

# Common error: ICE60 - Invalid component
# Solution: Ensure KeyPath file has correct permissions
```

---

### 2. MSIX (Modern Application Packaging)

**Overview:** MSIX is Microsoft's modern app packaging format, combining best features of AppX, MSI, and App-V. Supported on Windows 10+.

**Manifest Example (AppxManifest.xml):**

```xml
<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
         xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
         xmlns:uap3="http://schemas.microsoft.com/appx/manifest/uap/windows10/3"
         xmlns:desktop="http://schemas.microsoft.com/appx/manifest/desktop/windows10">

  <Identity Name="MyApp"
            Publisher="CN=MyCompany"
            Version="1.0.0.0" />

  <Properties>
    <DisplayName>My Application</DisplayName>
    <PublisherDisplayName>My Company</PublisherDisplayName>
    <Logo>Assets\StoreLogo.png</Logo>
  </Properties>

  <Dependencies>
    <TargetDeviceFamily Name="Windows.Universal" MinVersion="10.0.0.0" MaxVersionTested="10.0.0.0" />
  </Dependencies>

  <Resources>
    <Resource Language="en-us" />
  </Resources>

  <Applications>
    <Application Id="MyApp" StartPage="myapp.exe">
      <uap:VisualElements DisplayName="My App"
                          Square150x150Logo="Assets\Square150x150Logo.png"
                          Square44x44Logo="Assets\Square44x44Logo.png"
                          Description="A useful application"
                          BackgroundColor="#FFFFFF" />

      <Extensions>
        <uap:Extension Category="windows.fileTypeAssociation">
          <uap:FileTypeAssociation Name="myapp">
            <uap:SupportedFileTypes>
              <uap:FileType>.myformat</uap:FileType>
            </uap:SupportedFileTypes>
          </uap:FileTypeAssociation>
        </uap:Extension>

        <desktop:Extension Category="windows.toastNotificationActivation">
          <desktop:ToastNotificationActivation />
        </desktop:Extension>
      </Extensions>
    </Application>
  </Applications>

  <Capabilities>
    <Capability Name="internetClient" />
    <uap:Capability Name="picturesLibrary" />
    <uap:Capability Name="documentsLibrary" />
  </Capabilities>
</Package>
```

**Packaging Steps:**

```bash
# Step 1: Create package directory structure
mkdir MyApp\Assets
mkdir MyApp\bin

# Step 2: Add files to package directory
# - Place executable in MyApp\bin\
# - Place assets (icons, logos) in MyApp\Assets\

# Step 3: Create package using MakeAppx
MakeAppx pack /d MyApp /p MyApp.msix /o

# Step 4: Sign the package (required for installation)
# First, create a test certificate
New-SelfSignedCertificate -Type Custom -Subject "CN=MyCompany" `
  -KeyUsage DigitalSignature -FriendlyName "MyApp" `
  -CertStoreLocation "Cert:\CurrentUser\My"

# Then sign the MSIX
SignTool sign /fd SHA256 /a /f MyAppCert.pfx /p password MyApp.msix

# Step 5: Validate package
MakeAppx validate /p MyApp.msix

# Alternative: Use Visual Studio to create and sign
# File > New > Project > Windows Application Packaging Project
```

**Windows App Installer XML:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<AppInstaller Uri="https://example.com/MyApp.appinstaller"
              xmlns="http://schemas.microsoft.com/appx/appinstaller/2018">

  <MainBundle Uri="https://example.com/MyApp.msix"
              Version="1.0.0.0" />

  <OnLaunch HoursBetweenUpdateChecks="24" />

  <UpdateSettings>
    <OnLaunch HoursBetweenUpdateChecks="24" />
  </UpdateSettings>
</AppInstaller>
```

**Troubleshooting:**

```bash
# Install MSIX locally (for testing)
Add-AppxPackage MyApp.msix

# Check package integrity
Get-AppxPackage -Name MyApp

# Remove if needed
Remove-AppxPackage MyApp

# Signing issues: "The publisher of the MSIX is not recognized"
# Solution: Install the certificate first
Import-PfxCertificate -FilePath MyAppCert.pfx -CertStoreLocation Cert:\LocalMachine\TrustedPeople
```

---

### 3. Inno Setup

**Overview:** Inno Setup is a free, easy-to-use installer for Windows. Uses a simple script format (.iss).

**Complete Inno Setup Script Example:**

```ini
; MyApp Installer Script
; Inno Setup Version 6.2+

[Setup]
AppName=MyApp
AppVersion=1.0.0
AppPublisher=MyCompany
AppPublisherURL=https://example.com
AppSupportURL=https://example.com/support
AppUpdatesURL=https://example.com/updates
DefaultDirName={autopf}\MyApp
DefaultGroupName=MyApp
AllowNoIcons=yes
LicenseFile=LICENSE.txt
InfoBeforeFile=README.txt
OutputDir=Output
OutputBaseFilename=MyApp-Setup-1.0.0
Compression=lzma2
SolidCompression=yes
UninstallDisplayIcon={app}\myapp.exe
ChangesAssociations=yes
ChangesEnvironment=yes
PrivilegesRequired=admin
MinVersion=6.1sp1
SignTool=default

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Spanish.isl"

[Types]
Name: "full"; Description: "Full installation"
Name: "compact"; Description: "Compact installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "main"; Description: "Main application"; Types: full custom compact; Flags: fixed
Name: "docs"; Description: "Documentation"; Types: full
Name: "examples"; Description: "Example files"; Types: full

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "associate"; Description: "Associate .myformat files with MyApp"; GroupDescription: "File associations"
Name: "addpath"; Description: "Add MyApp to system PATH"; GroupDescription: "Environment"

[Files]
Source: "build\myapp.exe"; DestDir: "{app}"; Components: main; Flags: ignoreversion
Source: "build\*.dll"; DestDir: "{app}"; Components: main; Flags: ignoreversion recursesubdirs
Source: "config\*.json"; DestDir: "{app}\config"; Components: main; Flags: ignoreversion
Source: "docs\*"; DestDir: "{app}\docs"; Components: docs; Flags: ignoreversion recursesubdirs
Source: "examples\*"; DestDir: "{app}\examples"; Components: examples; Flags: ignoreversion recursesubdirs
Source: "LICENSE.txt"; DestDir: "{app}"; Components: main; Flags: ignoreversion

[Icons]
Name: "{group}\MyApp"; Filename: "{app}\myapp.exe"; Comment: "Launch MyApp"
Name: "{group}\Documentation"; Filename: "{app}\docs\manual.pdf"
Name: "{group}\Uninstall MyApp"; Filename: "{uninstallexe}"
Name: "{desktop}\MyApp"; Filename: "{app}\myapp.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\MyApp"; Filename: "{app}\myapp.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\myapp.exe"; Description: "Launch MyApp now"; Flags: nowait postinstall skipifsilent

[Registry]
Root: HKA; Subkey: ".myformat"; ValueType: string; ValueName: ""; ValueData: "MyAppFile"; Flags: uninsdeletevalue
Root: HKA; Subkey: "MyAppFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\myapp.exe,0"
Root: HKA; Subkey: "MyAppFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\myapp.exe"" ""%1"""
Root: HKLM; Subkey: "System\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Flags: preservestringtype uninsdeletevalue; Tasks: addpath
Root: HKLM; Subkey: "Software\MyCompany\MyApp"; ValueType: string; ValueName: "Version"; ValueData: "1.0.0"
Root: HKLM; Subkey: "Software\MyCompany\MyApp"; ValueType: string; ValueName: "InstallLocation"; ValueData: "{app}"

[UninstallDelete]
Type: dirifempty; Name: "{app}"
Type: dirifempty; Name: "{app}\docs"
Type: dirifempty; Name: "{app}\examples"

[Code]
function InitializeSetup(): Boolean;
begin
  if FileExists(ExpandConstant('{app}\myapp.exe')) then
  begin
    if SuppressibleMsgBox('MyApp is already installed. Continue?',
       mbConfirmation, MB_YESNO, IDYES) = IDNO then
      Exit(False);
  end;
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    ShellExec('', ExpandConstant('{app}\myapp.exe'), '/register', '', SW_HIDE, ewWaitUntilTerminated, 0);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if Length(ExpandConstant('{app}')) < 3 then
    begin
      SuppressibleMsgBox('Invalid installation directory', mbError, MB_OK, IDOK);
      Result := False;
    end;
  end;
end;
```

**Build Command:**

```bash
# Compile Inno Setup script
iscc /O"Output" MyApp.iss

# Using ISCC with parameters
iscc /DVersion=1.0.0 /DOutputDir=".\dist" MyApp.iss

# Command-line installation
MyApp-Setup.exe /SILENT /NORESTART /SP- /D=C:\MyApp
```

---

### 4. NSIS (Nullsoft Scriptable Install System)

**Overview:** NSIS is a professional open-source installer generator. Uses .nsi scripts with a C-like syntax.

**Complete NSIS Script Example:**

```nsis
; MyApp NSIS Installer Script
; Requires NSIS 3.0+

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
!include "WinVer.nsh"

; Configuration
Name "MyApp"
OutFile "MyApp-Setup-1.0.0.exe"
InstallDir "$PROGRAMFILES\MyApp"
InstallDirRegKey HKLM "Software\MyCompany\MyApp" "InstallLocation"

; Version info
VIProductVersion "1.0.0.0"
VIAddVersionKey ProductName "MyApp"
VIAddVersionKey ProductVersion "1.0.0"
VIAddVersionKey CompanyName "MyCompany"
VIAddVersionKey FileDescription "MyApp Installer"
VIAddVersionKey FileVersion "1.0.0"
VIAddVersionKey LegalCopyright "(C) 2024 MyCompany"

; MUI Settings
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Installation Section
Section "MyApp (required)"
  SectionIn RO

  SetOutPath "$INSTDIR"

  File "build\myapp.exe"
  File "config\*.json"
  SetOverwrite try
  File /r "build\*.dll"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MyApp" \
    "DisplayName" "MyApp"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MyApp" \
    "DisplayVersion" "1.0.0"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MyApp" \
    "Publisher" "MyCompany"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MyApp" \
    "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MyApp" \
    "UninstallString" "$INSTDIR\Uninstall.exe"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  CreateDirectory "$SMPROGRAMS\MyApp"
  CreateShortcut "$SMPROGRAMS\MyApp\MyApp.lnk" "$INSTDIR\myapp.exe"
  CreateShortcut "$SMPROGRAMS\MyApp\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Desktop Shortcut"
  CreateShortcut "$DESKTOP\MyApp.lnk" "$INSTDIR\myapp.exe"
SectionEnd

Section "Documentation"
  SetOutPath "$INSTDIR\docs"
  File /r "docs\*"
SectionEnd

Section "Examples"
  SetOutPath "$INSTDIR\examples"
  File /r "examples\*"
SectionEnd

Section "File Associations"
  WriteRegStr HKCR ".myformat" "" "MyAppFile"
  WriteRegStr HKCR "MyAppFile" "" "MyApp Format File"
  WriteRegStr HKCR "MyAppFile\DefaultIcon" "" "$INSTDIR\myapp.exe,0"
  WriteRegStr HKCR "MyAppFile\shell\open\command" "" '"$INSTDIR\myapp.exe" "%%1"'
SectionEnd

Section "Add to PATH"
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR"
SectionEnd

Section "Uninstall"
  RMDir /r "$INSTDIR"
  RMDir /r "$SMPROGRAMS\MyApp"
  Delete "$DESKTOP\MyApp.lnk"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MyApp"
  DeleteRegKey HKLM "Software\MyCompany\MyApp"
  DeleteRegKey HKCR "MyAppFile"
  ${EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR"
SectionEnd

LangString DESC_Section1 ${LANG_ENGLISH} "The main application and required files"
LangString DESC_Section2 ${LANG_ENGLISH} "Create a shortcut on the desktop"
LangString DESC_Section3 ${LANG_ENGLISH} "User documentation and help files"
LangString DESC_Section4 ${LANG_ENGLISH} "Example projects and templates"
LangString DESC_Section5 ${LANG_ENGLISH} "Associate MyApp with .myformat files"
LangString DESC_Section6 ${LANG_ENGLISH} "Add MyApp installation to system PATH"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Section1} $(DESC_Section1)
  !insertmacro MUI_DESCRIPTION_TEXT ${Section2} $(DESC_Section2)
  !insertmacro MUI_DESCRIPTION_TEXT ${Section3} $(DESC_Section3)
  !insertmacro MUI_DESCRIPTION_TEXT ${Section4} $(DESC_Section4)
  !insertmacro MUI_DESCRIPTION_TEXT ${Section5} $(DESC_Section5)
  !insertmacro MUI_DESCRIPTION_TEXT ${Section6} $(DESC_Section6)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function .onInit
  ${If} ${IsWin7}
    MessageBox MB_OKCANCEL "Windows 7 is supported but not recommended. Continue?" IDCANCEL Done
  ${EndIf}
  Done:
FunctionEnd

Function un.onUninstSuccess
  MessageBox MB_ICONINFORMATION|MB_TOPMOST|MB_OK "MyApp was successfully uninstalled."
FunctionEnd
```

**Build Command:**

```bash
# Compile NSIS script
makensis MyApp.nsi

# Command-line silent install
MyApp-Setup-1.0.0.exe /S /D=C:\MyApp

# Installation with log
MyApp-Setup-1.0.0.exe /L=install.log
```

---

### 5. ClickOnce Deployment

**Overview:** ClickOnce is Microsoft's technology for deploying .NET applications with automatic updates.

**Application Manifest Example (MyApp.exe.manifest):**

```xml
<?xml version="1.0" encoding="utf-8"?>
<asmv1:assembly manifestVersion="1.0"
                 xmlns="urn:schemas-microsoft-com:asm.v1"
                 xmlns:asmv1="urn:schemas-microsoft-com:asm.v1"
                 xmlns:asmv2="urn:schemas-microsoft-com:asm.v2"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <assemblyIdentity version="1.0.0.0"
                    name="MyApp.exe" />

  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
    <security>
      <requestedPermissions>
        <requestedPermission Class="System.Security.Permissions.FileIOPermission, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
                             version="1"
                             Unrestricted="true" />
      </requestedPermissions>
    </security>
  </trustInfo>

  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">
    <application>
      <supportedOS Id="{8e0f7a12-bfb4-4fe0-a793-0997f5730732}" />
      <supportedOS Id="{35138b9a-5d96-4fab-994d-e50eff6f3af1}" />
      <supportedOS Id="{4d909215-1ee6-45da-8e7d-191fba4b374a}" />
    </application>
  </compatibility>

  <asmv2:dependency>
    <dependentAssembly dependencyType="preRequisite"
                       allowDelayedBinding="true">
      <assemblyIdentity name="Microsoft.Windows.CommonLanguageRuntime"
                        version="4.0.30319.0" />
    </dependentAssembly>
  </asmv2:dependency>

  <asmv2:dependency>
    <dependentAssembly dependencyType="install"
                       allowDelayedBinding="true">
      <assemblyIdentity name="System.Core"
                        version="4.0.0.0"
                        culture="neutral"
                        publicKeyToken="b77a5c561934e089" />
    </dependentAssembly>
  </asmv2:dependency>
</asmv1:assembly>
```

**Deployment Manifest Example (MyApp.application):**

```xml
<?xml version="1.0" encoding="utf-8"?>
<asmv1:assembly xsi:schemaLocation="urn:schemas-microsoft-com:asm.v1 assembly.adaptive.xsd"
                 manifestVersion="1.0"
                 xmlns:asmv1="urn:schemas-microsoft-com:asm.v1"
                 xmlns="urn:schemas-microsoft-com:asm.v2"
                 xmlns:asmv2="urn:schemas-microsoft-com:asm.v2"
                 xmlns:xrml="urn:mpeg:mpeg21:2003:01-REL-R-NS"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <assemblyIdentity name="MyApp.application"
                    version="1.0.0.0"
                    publicKeyToken="0000000000000000"
                    language="neutral"
                    processorArchitecture="msil"
                    xmlns="urn:schemas-microsoft-com:asm.v1" />

  <description asmv2:publisher="MyCompany"
               asmv2:product="MyApp"
               xmlns="urn:schemas-microsoft-com:asm.v1" />

  <deployment install="true"
              mapFileExtensions="true"
              trustURLParameters="false">
    <subscription>
      <update>
        <expiration maximumAge="0" unit="days" />
      </update>
    </subscription>
    <deploymentProvider codebase="https://example.com/deploy/MyApp.application" />
  </deployment>

  <compatibleFrameworks xmlns="urn:schemas-microsoft-com:compatibility.v1">
    <framework targetVersion="4.8" profile="Full" supportedRuntime="4.0.30319" />
  </compatibleFrameworks>

  <dependency>
    <dependentAssembly dependencyType="install"
                       codebase="MyApp.exe.manifest"
                       size="1234">
      <assemblyIdentity name="MyApp.exe"
                        version="1.0.0.0"
                        publicKeyToken="0000000000000000"
                        language="neutral"
                        processorArchitecture="msil"
                        type="win32" />
      <hash>
        <dsig:Transforms xmlns:dsig="http://www.w3.org/2000/09/xmldsig#">
          <dsig:Transform Algorithm="urn:schemas-microsoft-com:HashTransforms.Identity" />
        </dsig:Transforms>
        <dsig:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha256" />
        <dsig:DigestValue>ABCD1234EFGH5678IJKL9012MNOP3456QRST</dsig:DigestValue>
      </hash>
    </dependentAssembly>
  </dependency>
</asmv1:assembly>
```

**Deployment Commands:**

```bash
# Using Mage.exe (Manifest Generation and Editing Tool)
mage -New Application -ToFile MyApp.exe.manifest -Name "MyApp" `
  -Version 1.0.0.0 -FromDirectory "bin\Release"

mage -New Deployment -ToFile MyApp.application -Name "MyApp" `
  -Version 1.0.0.0 -AppManifest MyApp.exe.manifest `
  -Install true -Provider "https://example.com/deploy/"

# Sign manifests
mage -Sign MyApp.exe.manifest -CertFile MyCert.pfx -Password mypassword
mage -Sign MyApp.application -CertFile MyCert.pfx -Password mypassword

# Using Visual Studio (preferred method)
# 1. Right-click Project > Properties
# 2. Go to Publish tab
# 3. Configure deployment location
# 4. Click "Publish Now"
```

---

## MACOS INSTALLERS

### 1. DMG Creation

**Overview:** DMG (Disk Image) is the standard macOS distribution format.

**DMG Creation Steps:**

```bash
# Create temporary folder
mkdir -p dmg_temp
cp -r MyApp.app dmg_temp/
cp LICENSE.txt dmg_temp/

# Create DMG from folder
hdiutil create -volname "MyApp 1.0" \
  -srcfolder dmg_temp \
  -ov -format UDZO \
  -imagekey zlib-level=9 \
  MyApp-1.0.dmg

# Alternative: Create raw image and add files
hdiutil create -size 100m -fs HFS+ -volname "MyApp" temp.dmg
hdiutil mount temp.dmg
cp -r MyApp.app /Volumes/MyApp/
cp LICENSE.txt /Volumes/MyApp/
ln -s /Applications /Volumes/MyApp/Applications
hdiutil unmount /Volumes/MyApp
hdiutil convert temp.dmg -format UDZO -o MyApp.dmg

# Verify DMG
hdiutil verify MyApp.dmg
```

**Build Command for DMG with Code Signing:**

```bash
# Sign the app first
codesign -s "Developer ID Application: MyCompany (ABCD1234)" \
  --deep --strict MyApp.app

# Create DMG
hdiutil create -volname "MyApp 1.0" \
  -srcfolder dmg_temp \
  -format UDZO \
  -imagekey zlib-level=9 \
  MyApp-1.0.dmg

# Notarize DMG (see Notarization section)
```

---

### 2. PKG Installers

**Overview:** PKG (macOS installer package) is created using pkgbuild and productbuild tools.

**Preinstall Script (Scripts/preinstall):**

```bash
#!/bin/bash
set -e

echo "Running preinstall checks..."

if pgrep -x "MyApp" > /dev/null; then
  echo "MyApp is running. Stopping..."
  killall MyApp || true
  sleep 2
fi

osversion=$(sw_vers -productVersion)
required_version="10.12"

if [[ "$osversion" < "$required_version" ]]; then
  echo "Error: macOS $required_version or later required"
  exit 1
fi

exit 0
```

**Postinstall Script (Scripts/postinstall):**

```bash
#!/bin/bash
set -e

APP_PATH="/Applications/MyApp.app"
USER_LIBRARY="$HOME/Library/Application Support/MyApp"

echo "Running postinstall..."

if [ ! -d "$USER_LIBRARY" ]; then
  mkdir -p "$USER_LIBRARY"
  cp /Library/MyApp/default_config.json "$USER_LIBRARY/config.json"
fi

chown -R $SUDO_USER:staff "$USER_LIBRARY"

echo "Installation complete"
exit 0
```

**Distribution.xml Example:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
  <title>MyApp Installation</title>
  <organization>com.mycompany</organization>
  <options customize="always" require-scripts="false" />
  <license file="LICENSE.txt" mime-type="text/plain" />
  <readme file="README.txt" mime-type="text/plain" />

  <choices-outline>
    <line choice="com.mycompany.MyApp.app.choice"/>
  </choices-outline>

  <choice id="com.mycompany.MyApp.app.choice"
          title="MyApp"
          description="Main application"
          start_selected="true">
    <pkg-ref id="com.mycompany.MyApp.app" />
  </choice>

  <pkg-ref id="com.mycompany.MyApp.app"
           installKBytes="10000"
           version="1.0.0"
           auth="Root">
    MyApp-app.pkg
  </pkg-ref>
</installer-gui-script>
```

**PKG Build Commands:**

```bash
# Create payload directory
mkdir -p Payload/Applications
cp -r MyApp.app Payload/Applications/

# Build component package
pkgbuild --root Payload \
  --scripts Scripts \
  --identifier com.mycompany.MyApp.app \
  --version 1.0.0 \
  MyApp-app.pkg

# Create product package
productbuild --distribution Distribution.xml \
  --package-path . \
  --identifier com.mycompany.MyApp \
  --version 1.0.0 \
  MyApp-1.0.pkg

# Sign the package
productsign --certificate "Developer ID Installer" \
  MyApp-1.0.pkg MyApp-1.0-signed.pkg

# Verify
pkgutil --check-signature MyApp-1.0-signed.pkg
```

---

### 3. App Bundle Structure

**Info.plist Example:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>MyApp</string>
  <key>CFBundleIdentifier</key>
  <string>com.mycompany.MyApp</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>MyApp</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>CFBundleDisplayName</key>
  <string>My Application</string>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2024 MyCompany. All rights reserved.</string>
  <key>LSMinimumSystemVersion</key>
  <string>10.12</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSSupportsAutomaticTermination</key>
  <true/>
  <key>NSSupportsAutomaticGraphicsSwitching</key>
  <true/>
</dict>
</plist>
```

**Create App Bundle:**

```bash
# Create directory structure
mkdir -p MyApp.app/Contents/{MacOS,Resources,Frameworks}

# Create Info.plist
# (copy from example above)

# Create PkgInfo
echo "APPLMyAp" > MyApp.app/Contents/PkgInfo

# Copy executable and resources
cp build/myapp MyApp.app/Contents/MacOS/MyApp
cp -r build/Resources/* MyApp.app/Contents/Resources/

# Set executable permissions
chmod +x MyApp.app/Contents/MacOS/MyApp

# Sign the app
codesign -s "Developer ID Application" \
  --deep --strict \
  --options runtime \
  MyApp.app
```

---

### 4. Homebrew Formula and Cask

**Homebrew Formula (Ruby):**

```ruby
class Myapp < Formula
  desc "A useful application"
  homepage "https://example.com"
  url "https://github.com/mycompany/myapp/releases/download/v1.0.0/MyApp-1.0.0.tar.gz"
  sha256 "abc123def456ghi789jkl012mno345pqr678stu901vwx234yz567abc890def"
  license "MIT"

  depends_on "python@3.11"
  depends_on "openssl@3"

  def install
    python = Formula["python@3.11"].opt_bin/"python3.11"
    system python, "-m", "pip", "install", *Language::Python.setup_py_args(prefix)
  end

  test do
    assert_match "MyApp", shell_output("#{bin}/myapp --version")
  end
end
```

**Homebrew Cask (for GUI apps):**

```ruby
cask "myapp" do
  version "1.0.0"
  sha256 "abc123def456ghi789jkl012mno345pqr678stu901vwx234yz567abc890def"

  url "https://github.com/mycompany/myapp/releases/download/v#{version}/MyApp-#{version}.dmg"
  name "MyApp"
  desc "A useful application for macOS"
  homepage "https://example.com"
  license :mit

  livecheck do
    url :url
    strategy :github_latest
  end

  app "MyApp.app"
end
```

---

### 5. Code Signing & Notarization

**Code Signing:**

```bash
# Check available certificates
security find-identity -v -p codesigning

# Sign the app
codesign --sign "Developer ID Application: MyCompany (ABCD1234)" \
  --timestamp \
  --deep \
  --strict \
  --options runtime \
  MyApp.app

# Verify signing
codesign --verify --verbose MyApp.app
spctl -a -v MyApp.app
```

**Notarization (2024-2025):**

```bash
# Create archive
ditto -c -k --keepParent MyApp.app MyApp.zip

# Submit for notarization
xcrun notarytool submit MyApp.zip \
  --apple-id "developer@example.com" \
  --team-id "ABCD1234" \
  --password "app-specific-password" \
  --wait

# Or using API key
xcrun notarytool submit MyApp.zip \
  --key /path/to/AuthKey_XXXXXXXX.p8 \
  --key-id XXXXXXXX \
  --issuer-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
  --wait

# Check status
xcrun notarytool log <submission-id> \
  --key /path/to/AuthKey_XXXXXXXX.p8 \
  --key-id XXXXXXXX \
  --issuer-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Staple the ticket
xcrun stapler staple MyApp.app

# Verify
spctl -a -v -t execute MyApp.app
```

---

## LINUX PACKAGES

### 1. DEB Packages (Debian/Ubuntu)

**Debian Control File (debian/control):**

```
Package: myapp
Version: 1.0.0
Architecture: amd64
Maintainer: MyCompany <support@example.com>
Installed-Size: 5000
Depends: libcurl4 (>= 7.68), openssl (>= 1.1.1)
Section: utils
Priority: optional
Homepage: https://example.com
Description: A useful application
 This is a longer description of the application
 that spans multiple lines.
```

**Debian Rules File (debian/rules):**

```makefile
#!/usr/bin/make -f

%:
	dh $@

override_dh_auto_build:
	cd src && make

override_dh_auto_install:
	mkdir -p debian/myapp/usr/bin
	cp src/myapp debian/myapp/usr/bin/
```

**DEB Build Commands:**

```bash
# Using debuild
debuild -us -uc

# Or using dpkg-deb
mkdir -p build/myapp-1.0.0/DEBIAN
mkdir -p build/myapp-1.0.0/usr/bin
cp myapp build/myapp-1.0.0/usr/bin/
cat > build/myapp-1.0.0/DEBIAN/control << 'EOF'
Package: myapp
Version: 1.0.0
Architecture: amd64
Maintainer: MyCompany
Description: A useful application
EOF
dpkg-deb --build build/myapp-1.0.0 myapp_1.0.0_amd64.deb

# Install locally
sudo dpkg -i myapp_1.0.0_amd64.deb
```

---

### 2. RPM Packages (Fedora/RHEL/CentOS)

**Spec File (myapp.spec):**

```spec
Name:           myapp
Version:        1.0.0
Release:        1%{?dist}
Summary:        A useful application
License:        MIT
URL:            https://example.com

BuildRequires:  gcc
Requires:       libcurl

%description
MyApp is a useful application.

%prep
%autosetup

%build
make

%install
make install DESTDIR=%{buildroot}

%files
%license LICENSE
%{_bindir}/%{name}

%changelog
* Fri Nov 15 2024 MyCompany - 1.0.0-1
- Initial release
```

**RPM Build Commands:**

```bash
# Build
rpmbuild -ba myapp.spec

# Or build from current directory
rpmbuild -bb myapp.spec

# Install locally
sudo rpm -ivh myapp-1.0.0-1.fc40.x86_64.rpm
```

---

### 3. Snap Packages

**snapcraft.yaml Example:**

```yaml
name: myapp
version: '1.0.0'
summary: A useful application
description: MyApp helps users accomplish tasks efficiently.

base: core22
confinement: strict
grade: stable

apps:
  myapp:
    command: bin/myapp
    plugs:
      - home
      - network

parts:
  myapp:
    plugin: make
    source: .
    build-packages:
      - build-essential
      - libcurl4-openssl-dev
    stage-packages:
      - libcurl4
```

**Build:**

```bash
# Build snap
snapcraft

# Test locally
sudo snap install --dangerous myapp_1.0.0_amd64.snap

# Push to store
snapcraft upload myapp_1.0.0_amd64.snap --release=stable
```

---

### 4. Flatpak Packages

**flatpak/com.mycompany.MyApp.json:**

```json
{
  "app-id": "com.mycompany.MyApp",
  "runtime": "org.gnome.Platform",
  "runtime-version": "45",
  "sdk": "org.gnome.Sdk",
  "command": "myapp",

  "finish-args": [
    "--share=network",
    "--socket=x11",
    "--socket=wayland",
    "--device=dri",
    "--filesystem=home"
  ],

  "modules": [
    {
      "name": "myapp",
      "buildsystem": "simple",
      "sources": [{
        "type": "archive",
        "url": "https://github.com/mycompany/myapp/releases/download/v1.0.0/myapp-1.0.0.tar.gz",
        "sha256": "abc123..."
      }],
      "build-commands": [
        "make",
        "make install PREFIX=/app"
      ]
    }
  ]
}
```

**Build:**

```bash
# Build
flatpak-builder build-dir com.mycompany.MyApp.json

# Test
flatpak run --devel com.mycompany.MyApp

# Create bundle
flatpak build-bundle repo myapp.flatpak com.mycompany.MyApp
```

---

### 5. AppImage Packages

**AppImage Build:**

```bash
# Install appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# Create AppDir
mkdir -p AppDir/usr/bin
cp build/myapp AppDir/usr/bin/

# Create AppImage
./appimagetool-x86_64.AppImage AppDir MyApp-1.0.0-x86_64.AppImage

# Test
chmod +x MyApp-1.0.0-x86_64.AppImage
./MyApp-1.0.0-x86_64.AppImage --version
```

---

## CROSS-PLATFORM SOLUTIONS

### 1. Docker

**Dockerfile (Multi-stage):**

```dockerfile
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libcurl4-openssl-dev

WORKDIR /build
COPY . .
RUN mkdir -p build && cd build && cmake .. && make

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/myapp /usr/bin/

ENTRYPOINT ["/usr/bin/myapp"]
```

**Build and Push:**

```bash
# Build
docker build -t mycompany/myapp:1.0.0 .

# Test
docker run --rm mycompany/myapp:1.0.0 --version

# Push
docker login
docker push mycompany/myapp:1.0.0
```

---

### 2. Electron Applications

**electron-builder in package.json:**

```json
{
  "build": {
    "appId": "com.mycompany.myapp",
    "productName": "MyApp",
    "win": {"target": ["msi", "nsis"]},
    "mac": {"target": ["dmg", "zip"]},
    "linux": {"target": ["AppImage", "deb"]}
  }
}
```

**Build:**

```bash
npm run build:all
```

---

### 3. Tauri Applications

**Tauri Configuration (src-tauri/tauri.conf.json):**

```json
{
  "productName": "MyApp",
  "version": "1.0.0",
  "identifier": "com.mycompany.myapp",
  "build": {
    "beforeBuildCommand": "npm run build",
    "devPath": "http://localhost:5173",
    "frontendDist": "../dist"
  }
}
```

**Build:**

```bash
npm run tauri build
```

---

## BEST PRACTICES

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in git: `git tag -a v1.0.0`

### Code Signing
- Always sign production binaries
- Use time-stamping to prevent expiration
- Store certificates securely (not in repos)
- Rotate certificates regularly

### Distribution Channels
- **Direct Download:** Website
- **Package Managers:** apt, dnf, Homebrew
- **App Stores:** Microsoft Store, Mac App Store
- **Auto-Updates:** Built-in frameworks
- **CI/CD:** Automated builds and releases

### Security
- Validate installer signatures before execution
- Use HTTPS for all downloads
- Request only necessary permissions
- Clear security policies for data handling

---

## TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| MSI fails to install | Ensure unique component GUIDs |
| DMG won't mount | Recreate DMG from fresh sources |
| DEB dependency issues | Run `apt-get install -f` |
| RPM conflicts | Use unique package identifiers |
| App won't notarize | Check code signing and hardened runtime |
| Snap permission errors | Add required plugs to snapcraft.yaml |
| Docker image too large | Use multi-stage builds |
| Electron build fails | Install all build-essential packages |
| Tauri compilation errors | Update Rust: `rustup update` |

---

**Document Version:** 1.0 | **Last Updated:** November 2024
