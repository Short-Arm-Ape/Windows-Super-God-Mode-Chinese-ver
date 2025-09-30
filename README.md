# 适用于 Windows 的 "Super God Mode" 脚本

此 PowerShell 脚本 <b>创建 Windows 中所有特殊 shell 文件夹、命名文件夹、任务链接、系统设置、深度链接和 URL 协议的快捷方式</b>，从而可以轻松访问各种系统设置和功能。

它的灵感来自著名的绰号“上帝模式”文件夹，并创建了比这更多的快捷方式。 

➤ 注意：这并不是真正的“模式”，这只是一个朗朗上口的名字。运行它不会更改任何系统设置，它只会创建一个包含大量快捷方式的文件夹。

## 汉化声明

该项目为原项目的汉化版本，原项目仓库：[ThioJoe/Windows-Super-God-Mode](https://github.com/ThioJoe/Windows-Super-God-Mode)

非汉化质量问题或非因汉化导致的运行问题请至原项目仓库提交 `Issues` 。

汉化内容中有部分内容采用机器/人工智能翻译。

**注：经译者测试，在非管理员的情况下运行脚本时，可能会遇到“深度链接”快捷方式无法识别创建的情况，此时以管理员权限重新运行脚本即可。**

## 屏幕截图

<p align="center">
<img width="786" height="708" alt="QQ_1759251057389" src="https://github.com/user-attachments/assets/74d3e6ca-2626-4fb5-bbc2-cfbfb3a79467" />
</p><p align="center">

<img width="432" height="274" alt="QQ_1759251530530" src="https://github.com/user-attachments/assets/b822498c-a0dd-4f53-8f06-d98427cc1277" />
<img width="519" height="264" alt="QQ_1759251443150" src="https://github.com/user-attachments/assets/25596058-b86a-4e4a-b5ae-247cefcb9c0a" />

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

2. 打开 PowerShell 到包含脚本的目录。（小贴士：在文件资源管理器中，只需在地址栏中键入 “PowerShell.exe” 即可将其打开到该路径）。

3. 运行以下命令以允许暂时执行当前会话的脚本： 
   
   ```
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
   ```
   
   ➤ **注意:** 你可能会看到有关更改执行策略的警告，但命令中的 `-Scope Process` 参数确保更改只是临时的，并且仅应用于该特定 PowerShell 窗口，因此您可以选择允许。您可以在 [本文](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-5.1#-scope) 中阅读更多内容. 

4. 运行该脚本:
   
   ```
   .\Super_God_Mode.ps1
   ```
   
   - 如果未提供参数，则会出现一个 GUI ，以便于配置。
   - 您还可以使用可选参数运行脚本（见下文）。

## 演示视频：

<p align="center">演示视频： https://www.youtube.com/watch?v=CnATL9kJPn8</p>

<p align="center"><a href="https://www.youtube.com/watch?v=CnATL9kJPn8"> <img width="750" src="https://github.com/user-attachments/assets/1d5d5c88-aa50-4909-845a-8598e759a6b7"></a></p>

<p align="center">(点击该链接将跳转至 YouTube 。请参阅视频说明中的时间戳。)</p>

## 命令行参数

注意: 除了 `-Debug` 和 `-Verbose` 以外, 你必须使用 `-NoGUI` 以使参数生效

#### 可选参数

- `-DontGroupTasks`: 阻止按应用程序名称对任务快捷方式进行分组
- `-UseAlternativeCategoryNames`: 为任务链接使用备选类别名称
- `-AllURLProtocols`: 包含已安装软件中的第三方 URL 协议
- `-DeepScanHiddenLinks`: 扫描非 AppX 软件包应用程序安装目录中所有文件中的隐藏链接，否则只搜索主二进制文件。
- `-CollectExtraURLProtocolInfo`: 收集有关 URL 协议的其他信息
- `-AllowDuplicateDeepLink`: 不会跳过与现有任务链接完全相同的深度链接快捷方式

#### 控制输出

- `-Output`: 指定自定义输出文件夹路径
- `-KeepPreviousOutputFolders`: 运行前不要自动删除现有的输出文件夹

#### 限制快捷方式创建的参数

- `-NoStatistics`: 不创建统计文件夹和文件
- `-NoReadMe`: 不创建提示文本文件
- `-SkipCLSID`: 跳过为基于 CLSID 的 shell 文件夹创建快捷方式
- `-SkipNamedFolders`: 跳过为指定的特殊文件夹创建快捷方式
- `-SkipTaskLinks`: 跳过为任务链接创建快捷方式
- `-SkipMSSettings`: 跳过为 ms-settings: 创建快捷方式
- `-SkipDeepLinks`: 跳过为深度链接创建快捷方式
- `-SkipURLProtocols`: 跳过为URL协议创建快捷方式
- `-SkipHiddenAppLinks`: 跳过创建隐藏应用链接的快捷方式

#### 调试

- `-Verbose`: 启用详细输出。可以与 `-NoGUI` 一起使用或不一起不使用。
- `-Debug`: 启用调试输出（也启用详细输出）。可以与 `-NoGUI` 一起使用或不一起使用。
- `-timing`: 启用计时输出以显示脚本的每个部分运行所需的时间。也通过详细/调试开关启用。
- `-debugSkipAppxSearch`: 跳过在AppX包中搜索隐藏链接，只搜索非AppX程序。
- `-debugSearchOnlyProtocolList`: 指定一个逗号分隔的URL协议列表（用引号括起来）进行搜索，而不指定其他协议。
- `uniqueOutputFolder`: 在输出文件夹名称后附加一个唯一标识符，以防止覆盖现有文件夹。

#### 高级参数

- `-NoGUI`: 跳过GUI对话框，使用默认或提供的参数运行
- `-CustomDLLPath`: 为 shell32.dll 指定自定义 DLL 文件路径
- `-CustomLanguageFolderPath`: Specify a path to a folder containing language-specific MUI files
- `-CustomSystemSettingsDLLPath`: Specify a custom path to the SystemSettings.dll file
- `-CustomAllSystemSettingsXMLPath`: Specify a custom path to the "AllSystemSettings_" XML file

### 示例

```powershell
.\Super_God_Mode.ps1 -Output "C:\SuperGodMode" -AllURLProtocols -Verbose
```

## 注意

- 由于可用功能的差异，某些快捷方式可能无法在所有Windows版本上运行。
- 该脚本不会修改任何系统设置；它只创建现有Windows功能的快捷方式。
- 所有参数和GUI设置都是可选的。如果用户不更改任何内容，脚本将使用默认设置运行。

## 常见问题

- 常见问题请参阅 Wiki 页面: https://github.com/ThioJoe/Windows-Super-God-Mode/wiki/Frequently-Asked-Questions

___

# 拓展工具

`Extra Tools`文件夹包含补充Windows Super God Mode 脚本主要功能的其他脚本：

### `Get_DLL_String_Reference.ps1`

此脚本允许您轻松检索单个特定字符串引用的本地化字符串。

特性:

- 交互式提示字符串引用
- 解析并显示本地化字符串值
- 支持 `@dllpath,-resourceID` 格式

用法:

1. 在 PowerShell 运行此脚本
2. 出现提示时输入字符串引用 (例如, `@%SystemRoot%\system32\shell32.dll,-9227`)
3. 脚本将显示解析的字符串值

### `Windows_XML_String_Resolver.ps1`

此脚本处理包含 Windows 字符串引用的整个XML文件，并将其解析为实际的字符串值。主要用于包含所有 Windows 任务链接的 shell32.dll.mun 中的 XML 。

特性:

- 处理整个 XML 文件，用解析值替换字符串引用
- 支持解析字符串的自定义 DLL 路径
- 生成具有解析字符串的新 XML 文件

用法:

```powershell
.\Windows_XML_String_Resolver.ps1 -XmlFilePath "path\to\your\file.xml" [-CustomResourcePaths "shell32=C:\custom\path\shell32.dll", "user32=C:\another\path\user32.mui"] [-Debug]
```

### `Get-MS-Settings-Strings.ps1`

此脚本将在DLL文件中查找 "ms-settings:" 的文本字符串，并将其输出到文本文件。 
它是内置于主脚本中的功能的独立版本。主要用于：

`"C:\Windows\ImmersiveControlPanel\SystemSettings.dll"`

用法:

```
`.\Get-MS-Settings-Strings.ps1 -DllPath "C:\Windows\ImmersiveControlPanel\SystemSettings.dll" -OutputFilePath "SystemSettings-MS-Settings.txt"
```

- 如果未通过参数指定路径，脚本将提示用户输入 DLL 路径，并输出到与脚本相同的目录。

### `Find_URLs_From_AppxPackage_Files.ps1`

此脚本通过每个已安装的 AppxPackage 的 AppxManifest.xml 文件获取其 URI 协议，然后在应用程序安装目录中的所有文件中暴力搜索这些URI。
它是内置于主脚本中的功能的独立版本，但可能不是最新的！

用法:

- 无需参数:  `.\Find_URLs_From_AppxPackage_Files.ps1`
