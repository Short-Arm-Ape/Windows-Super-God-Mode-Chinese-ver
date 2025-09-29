# 适用于 Windows 的 "Super God Mode" 脚本

此 PowerShell 脚本 <b>创建 Windows 中所有特殊 shell 文件夹、命名文件夹、任务链接、系统设置、深度链接和 URL 协议的快捷方式</b>，从而可以轻松访问各种系统设置和功能。

它的灵感来自著名的绰号“上帝模式”文件夹，并创建了比这更多的快捷方式。 

➤ 注意：这并不是真正的“模式”，这只是一个朗朗上口的名字。运行它不会更改任何系统设置，它只会创建一个包含大量快捷方式的文件夹。

## 汉化声明

该项目为原项目的汉化版本，原项目仓库：[ThioJoe/Windows-Super-God-Mode](https://github.com/ThioJoe/Windows-Super-God-Mode)

非汉化质量问题或非因汉化导致的运行问题请至原项目仓库提交 `Issues` 。

汉化内容中有部分内容采用机器/人工智能翻译。

## 屏幕截图

<p align="center">
<img width="700" alt="GUI Window" src="https://github.com/user-attachments/assets/d318373c-d4d4-4521-bf57-8b4a4b4273ee">
</p><p align="center">
<img width="290" alt="Results" src="https://github.com/user-attachments/assets/4d01fbad-b597-4433-bd67-2638ded8a6ed">
<img width="392" alt="Output Folders" src="https://github.com/user-attachments/assets/898efc48-ddc6-4875-b906-b89963d5778e">
</p>



## 特点

- 为各种 Windows 组件创建快捷方式：
  - **CLSID Shell 文件夹**
  - **命名特殊文件夹**
  - **任务链接** （shell 文件夹和控制面板菜单中的子页面）
  - **系统设置** （ “ms-settings:” 链接）
  - **"深度链接"** （直接链接到 Windows 上的各种设置菜单）
  - **URL 协议**
  - **隐藏的应用程序链接** （应用程序使用的内部使用和未记录的 URL 链接）
- 生成包含有关快捷方式的详细信息的 CSV 文件
- 保存从 shell32.dll 和其他来源检索到的 XML 内容以供参考
- 图形用户界面 （GUI），易于配置
- 使用 EV 代码签名证书签名的发布版本

## 使用说明:

### 方法 1 (更简单): 使用 .bat 启动器
1. 点击页面上部的绿色按钮 `< > Code` ，在弹出的选项中选择 `Download ZIP`。 
2. 解压下载的 `Windows-Super-God-Mode-Chinese-ver-main.zip` ，确保 `SuperGodMode-EasyLauncher.bat` 和 `Super_God_Mode.ps1` 两个脚本均解压完毕且处于同一目录下。 
3. 运行 `SuperGodMode-EasyLauncher.bat` 。

### 方法 2: 手动运行

1. 下载脚本 `Super_God_Mode.ps1` 。 ( [下载链接](https://raw.githubusercontent.com/Short-Arm-Ape/Windows-Super-God-Mode-Chinese-ver/refs/heads/main/Super_God_Mode.ps1))
2. 打开 PowerShell 到包含脚本的目录。（小贴士：在文件资源管理器中，只需在地址栏中键入“PowerShell.exe”即可将其打开到该路径）。
3. 运行以下命令以允许暂时执行当前会话的脚本： 
   ```
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
   ```
   ➤ **注意:** 你可能会看到有关更改执行策略的警告，但命令中的 `-Scope Process` 参数确保更改只是临时的，并且仅应用于该特定PowerShell窗口，因此您可以选择允许。您可以在 [本文](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-5.1#-scope) 中阅读更多内容. 
   
5. 运行该脚本:
   ```
   .\Super_God_Mode.ps1
   ```
   - 如果未提供参数，则会出现一个 GUI，以便于配置。
   - 您还可以使用可选参数运行脚本（见下文）。

## 演示视频：

<p align="center">演示视频： https://www.youtube.com/watch?v=CnATL9kJPn8</p>

<p align="center"><a href="https://www.youtube.com/watch?v=CnATL9kJPn8"> <img width="750" src="https://github.com/user-attachments/assets/1d5d5c88-aa50-4909-845a-8598e759a6b7"></a></p>

<p align="center">(点击该链接将跳转至 YouTube。请参阅视频说明中的时间戳。)</p>


## 命令行参数

Note: 除了 `-Debug` 和 `-Verbose` 以外, 你必须使用 `-NoGUI` 以使参数生效

#### Alternative Options Arguments

- `-DontGroupTasks`: Prevent grouping task shortcuts by application name
- `-UseAlternativeCategoryNames`: Use alternative category names for task links
- `-AllURLProtocols`: Include third-party URL protocols from installed software
- `-DeepScanHiddenLinks`: Scans for hidden links in all files in the install directory of non-appx-package apps, otherwise only the main binary file is searched.
- `-CollectExtraURLProtocolInfo`: Collect additional information about URL protocols
- `-AllowDuplicateDeepLink`: Will not skip Deep Link shortcuts that are exactly the same as an existing task link

#### Control Output

- `-Output`: Specify a custom output folder path
- `-KeepPreviousOutputFolders`: Don't auto-delete existing output folders before running

#### Arguments to Limit Shortcut Creation

- `-NoStatistics`: Don't create statistics folder and files
- `-NoReadMe`: Don't create tips text file
- `-SkipCLSID`: Skip creating shortcuts for CLSID-based shell folders
- `-SkipNamedFolders`: Skip creating shortcuts for named special folders
- `-SkipTaskLinks`: Skip creating shortcuts for task links
- `-SkipMSSettings`: Skip creating shortcuts for ms-settings: links
- `-SkipDeepLinks`: Skip creating shortcuts for deep links
- `-SkipURLProtocols`: Skip creating shortcuts for URL protocols
- `-SkipHiddenAppLinks`: Skip creating shortcuts to hidden app links

#### Debugging

- `-Verbose`: Enable verbose output. Can be used with or without `-NoGUI`.
- `-Debug`: Enable debug output (also enables verbose output). Can be used with or without `-NoGUI`.
- `-timing`: Enable timing output to show how long each section of the script takes to run. Also enabled by verbose/debug switches.
- `-debugSkipAppxSearch`: Skip searching for hidden links in AppX packages, and only search for non-appx programs.
- `-debugSearchOnlyProtocolList`: Specify a comma-separated list of URL protocols (surrounded by quotes) to search for, and no others.
- `uniqueOutputFolder`: Append a unique identifier to the output folder name to prevent overwriting existing folders.

#### Advanced Arguments

- `-NoGUI`: Skip the GUI dialog and run with default or provided parameters
- `-CustomDLLPath`: Specify a custom DLL file path for shell32.dll
- `-CustomLanguageFolderPath`: Specify a path to a folder containing language-specific MUI files
- `-CustomSystemSettingsDLLPath`: Specify a custom path to the SystemSettings.dll file
- `-CustomAllSystemSettingsXMLPath`: Specify a custom path to the "AllSystemSettings_" XML file

### Example

```powershell
.\Super_God_Mode.ps1 -Output "C:\SuperGodMode" -AllURLProtocols -Verbose
```

## Notes

- Some shortcuts may not work on all Windows versions due to differences in available features.
- The script does not modify any system settings; it only creates shortcuts to existing Windows features.
- All parameters and GUI settings are optional. The script will run with default settings if the user doesn't change anything.

## Frequently Asked Questions
- See Wiki Page for FAQs: https://github.com/ThioJoe/Windows-Super-God-Mode/wiki/Frequently-Asked-Questions
___

# 拓展工具

`Extra Tools`文件夹包含补充Windows Super God Mode 脚本主要功能的其他脚本：

### Get_DLL_String_Reference.ps1

This script allows you to easily retrieve the localized string of a single specific string reference.

Features:
- Interactively prompts for string references
- Resolves and displays the localized string values
- Supports the `@dllpath,-resourceID` format

Usage:
1. Run the script in PowerShell
2. Enter the string reference when prompted (e.g., `@%SystemRoot%\system32\shell32.dll,-9227`)
3. The script will display the resolved string value

### Windows_XML_String_Resolver.ps1

This script processes entire XML files containing Windows string references and resolves them to their actual string values. Mostly intended to be used with the XML from shell32.dll.mun containing all the Windows task links.

Features:
- Processes entire XML files, replacing string references with their resolved values
- Supports custom DLL paths for resolving strings
- Generates a new XML file with resolved strings

Usage:
```powershell
.\Windows_XML_String_Resolver.ps1 -XmlFilePath "path\to\your\file.xml" [-CustomResourcePaths "shell32=C:\custom\path\shell32.dll", "user32=C:\another\path\user32.mui"] [-Debug]
```

### Get-MS-Settings-Strings.ps1

This script will find text strings of "ms-settings:" in a DLL file and output them to a text file. 
It is a standalone version of the feature built into the main script. Intended mainly for: "C:\Windows\ImmersiveControlPanel\SystemSettings.dll".

Usage:
```
`.\Get-MS-Settings-Strings.ps1 -DllPath "C:\Windows\ImmersiveControlPanel\SystemSettings.dll" -OutputFilePath "SystemSettings-MS-Settings.txt"
```
- If not specified via arguments, the script will prompt the user for the DLL path, and output to the same directory as the script.

### Find_URLs_From_AppxPackage_Files.ps1

This script fetches the URI protocols for each installed AppxPackage via their AppxManifest.xml file, then brute force searches for those URIs in all files in the app's install directory.
It is a standalone version of the feature built into the main script, but might not be up to date!

Usage:
- No arguments necessary:  `.\Find_URLs_From_AppxPackage_Files.ps1`
