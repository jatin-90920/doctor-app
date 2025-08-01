[Setup]
AppName=Doctor CRM
AppVersion=1.0
DefaultDirName={pf}\DoctorCRM
DefaultGroupName=DoctorCRM
OutputDir=.
OutputBaseFilename=DoctorCRM_Setup
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Doctor CRM"; Filename: "{app}\doctor_app.exe"
Name: "{group}\Uninstall Doctor CRM"; Filename: "{uninstallexe}"
