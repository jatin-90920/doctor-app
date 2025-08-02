[Setup]
AppName=Doctor CRM
AppVersion=1.0
DefaultDirName={autopf}\DoctorCRM
DefaultGroupName=Doctor CRM
OutputDir=installer
OutputBaseFilename=DoctorCRM-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\ayurvedic_doctor_crm.exe
MinVersion=10.0.17763
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "debugmode"; Description: "Install debug launcher (helps troubleshoot issues)"; GroupDescription: "Development"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Create debug launcher
Source: "debug_launcher.bat"; DestDir: "{app}"; Flags: ignoreversion; Tasks: debugmode

[Icons]
Name: "{group}\Doctor CRM"; Filename: "{app}\ayurvedic_doctor_crm.exe"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0
Name: "{group}\Doctor CRM (Debug)"; Filename: "{app}\debug_launcher.bat"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0; Tasks: debugmode
Name: "{autodesktop}\Doctor CRM"; Filename: "{app}\ayurvedic_doctor_crm.exe"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0; Tasks: desktopicon

[Run]
Filename: "{app}\ayurvedic_doctor_crm.exe"; Description: "Launch Doctor CRM"; Flags: nowait postinstall skipifsilent

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectTasks then
  begin
    // Show warning about debug mode
    if WizardIsTaskSelected('debugmode') then
    begin
      MsgBox('Debug mode selected. Use "Doctor CRM (Debug)" shortcut to see error messages if the app fails to start.', mbInformation, MB_OK);
    end;
  end;
end;