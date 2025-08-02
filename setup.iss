[Setup]
AppName=Doctor CRM
AppVersion=1.0
DefaultDirName={autopf}\DoctorCRM
DefaultGroupName=DoctorCRM
OutputDir=installer
OutputBaseFilename=DoctorCRM-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Add icon for the installer and uninstaller
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\ayurvedic_doctor_crm.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\DoctorCRM"; Filename: "{app}\ayurvedic_doctor_crm.exe"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0
Name: "{autodesktop}\DoctorCRM"; Filename: "{app}\ayurvedic_doctor_crm.exe"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0; Tasks: desktopicon

[Run]
Filename: "{app}\ayurvedic_doctor_crm.exe"; Description: "{cm:LaunchProgram,Ammy Bespoke}"; Flags: nowait postinstall skipifsilent