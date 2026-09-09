#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\dist"
#endif

[Setup]
AppId={{38BF1B51-6769-4F9F-83BF-EF1F9BD10F9E}
AppName=Reye
AppVersion={#MyAppVersion}
AppVerName=Reye {#MyAppVersion}
AppPublisher=Reye contributors
DefaultDirName={localappdata}\Programs\Reye
DefaultGroupName=Reye
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename=Reye-Windows-x64-Setup-v{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Reye.exe
LicenseFile=..\LICENSE
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
AppMutex=Local\ReyeSingleInstanceMutex
RestartApplications=no
VersionInfoVersion={#MyAppVersion}.0
VersionInfoProductName=Reye
VersionInfoDescription=Reye installer

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Reye"; Filename: "{app}\Reye.exe"
Name: "{autodesktop}\Reye"; Filename: "{app}\Reye.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Reye.exe"; Description: "Launch Reye"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    RegDeleteValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', 'Reye');
end;
