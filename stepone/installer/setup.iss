; StepONE 成就管理系统 - Inno Setup 安装脚本
; 生成命令："C:\Program Files (x86)\Inno Setup 6\ISCC.exe" setup.iss

#define MyAppName "StepONE"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "StepONE"
#define MyAppExeName "stepone_app.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".stepone"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; 应用信息
AppId={{9B6E4C3D-5E8F-4B0C-9D2E-3F4A5B6C7D8E}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes

; 输出设置
OutputDir=..\build\installer
OutputBaseFilename=StepONE_Setup_v{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico

; 压缩设置
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

; 权限设置
PrivilegesRequiredOverridesAllowed=dialog
PrivilegesRequired=lowest

; 版本信息
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} 安装程序
VersionInfoCopyright=Copyright (C) 2024 {#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

; 界面设置
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[TASKS]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[FILES]
; 主程序文件
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[ICONS]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[RUN]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UNINSTALLDELETE]
Type: filesandordirs; Name: "{app}\data"

[CODE]
function InitializeSetup(): Boolean;
begin
  Result := true;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // 安装完成后的操作
  end;
end;
