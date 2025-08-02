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

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Doctor CRM"; Filename: "{app}\ayurvedic_doctor_crm.exe"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0
Name: "{autodesktop}\Doctor CRM"; Filename: "{app}\ayurvedic_doctor_crm.exe"; IconFilename: "{app}\ayurvedic_doctor_crm.exe"; IconIndex: 0; Tasks: desktopicon

[Run]
Filename: "{app}\ayurvedic_doctor_crm.exe"; Description: "Launch Doctor CRM"; Flags: nowait postinstall skipifsilent
