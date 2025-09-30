# Get All Shell Folder Shortcuts Script (Aka "Super God Mode")
#
# Author: ThioJoe
# GitHub Repo: https://github.com/ThioJoe/Windows-Super-God-Mode
#
# This PowerShell script is designed to find and create shortcuts for all special shell folders in Windows.
# These folders can be identified through their unique Class Identifiers (CLSIDs) or by their names.
# The script also generates CSV files listing these folders and associated tasks/links.

# How to Use:
# 1. Open PowerShell and navigate to the path containing this script using the 'cd' command.
# 2. Run the following command to allow running scripts for the current session:
#        Set-ExecutionPolicy -ExecutionPolicy unrestricted -Scope Process
# 3. Without closing the PowerShell window, run the script by typing the name of the script file starting with  .\  for example:
#        .\Super_God_Mode.ps1
# 4. Wait for it to finish, then check the "Super God Mode" folder for the generated shortcuts.

# ======================================================================================================
# ===================================  ARGUMENTS (ALL ARE OPTIONAL)  ===================================
# ======================================================================================================
#
# ---------------------------------   Alternative Options Arguments   ----------------------------------
#
# -DontGroupTasks
#     • Switch (Takes no values)
#     Prevent grouping task shortcuts, meaning the application name won't be prepended to the task name in the shortcut file
#
# -UseAlternativeCategoryNames
#     • Switch (Takes no values)
#     Looks up alternative category names for task links to prepend to the task names
#
# -AllURLProtocols
#     • Switch (Takes no values)
#     Include third party URL protocols from installed software in the URL Protocols section. By default, only protocols detected to be from Microsoft or system protocols are included.
#
# -DeepScanHiddenLinks
#     • Switch (Takes no values)
#     Scans all files in the installation directory of non-appx-package apps for hidden links. Otherwise, only the primary binary file will be searched. Note: This will be MUCH slower.
#
# -CollectExtraURLProtocolInfo
#     • Switch (Takes no values)
#     Collects extra information about URL protocols that goes into the CSV spreadsheet. Optional because it is not used in the shortcuts and takes slightly longer.
#
# -AllowDuplicateDeepLinks
#     • Switch (Takes no values)
#     Allow the creation of Deep Links that are the same as an existing Task Link. By default, such duplicates are not included in the Deep Links folder.
#
# ------------------------------------------  Control Output  ------------------------------------------
#
# -Output
#     • String Type
#     Specify a custom output folder path (relative or absolute) to save the generated shortcuts. If not provided, a folder named "Super God Mode" will be created in the script's directory.
#
# -KeepPreviousOutputFolders
#     • Switch (Takes no values)
#     Doesn't delete existing output folders before running the script. Any existing shortcuts will still be overwritten if being created again.
#
# -------------------------------  Arguments to Limit Outputs  -------------------------------
#
# -NoStatistics
#     • Switch (Takes no values)
#     Skip creating the statistics folder and files containing CSV data about the shell folders and tasks and XML files with other collected data
#
# -NoReadMe
#     • Switch (Takes no values)
#     Skip creating the ReadMe text file in the main folder
#
#
# -SkipCLSID
#     • Switch (Takes no values)
#     Skip creating shortcuts for shell folders based on CLSIDs
#
# -SkipNamedFolders
#     • Switch (Takes no values)
#     Skip creating shortcuts for named special folders
#
# -SkipTaskLinks
#     • Switch (Takes no values)
#     Skip creating shortcuts for task links (sub-pages within shell folders and control panel menus)
#
# -SkipMSSettings
#     • Switch (Takes no values)
#     Skip creating shortcuts for ms-settings: links (system settings pages)
#
# -SkipDeepLinks
#     • Switch (Takes no values)
#     Skip creating shortcuts for deep links (direct links to various settings menus across Windows)
#
# -SkipURLProtocols
#     • Switch (Takes no values)
#     Skip creating shortcuts for URL protocols (e.g., mailto:, ms-settings:, etc.)
#
# -SkipHiddenAppLinks
#   • Switch (Takes no values)
#   Skip creating shortcuts for hidden sub-page links for app protocols (e.g., ms-clock://pausefocustimer, etc.)
#
# --------------------------------------------  Debugging  ---------------------------------------------
#
# -Verbose
#     • Switch (Takes no values)
#     Enable verbose output for more detailed information during script execution
#
# -Debug
#     • Switch (Takes no values)
#     Enable debug output for maximum information during script execution. This will also enable verbose output.
#
# -timing
#     • Switch (Takes no values)
#     Enable timing output to show how long each section of the script takes to run. Or timing will be enabled automatically if in verbose or debug mode
#
# -debugSkipAppxSearch
#    • Switch (Takes no values)
#    Skip searching for hidden links in AppX packages. This is useful for debugging and testing searching of third party apps without having to wait for the AppX search to complete.
#
# -debugSearchOnlyProtocolList
#    • String Type
#    Specify a comma-separated list of URL protocols (surrounded by quotes) to search for in the debug mode. This is useful for testing the URL protocol search without having to wait for the full search to complete.
#
# -uniqueOutputFolder
#    • Switch (Takes no values)
#    Append a unique identifier to the output folder name to prevent overwriting existing folders, even if using manual output folder name.  Useful to compare different runs without having to manually set a new output folder each time. 
#
# ----------------------------------------  Advanced Arguments  ----------------------------------------
#
# -NoGUI
#     • Switch (Takes no values)
#     Skip the GUI dialog when running the script. If no other arguments are provided, the script will run with default settings. If other arguments are provided, they will be used without the GUI.
#
# -CustomDLLPath
#     • String Type
#     Specify a custom DLL file path to load the shell32.dll content from. If not provided, the default shell32.dll will be used.
#     NOTE: Because of how Windows works behind the scenes, DLLs reference resources in corresponding .mui and .mun files.
#        The XML data (resource ID 21) that is required in this script is actually located in shell32.dll.mun, which is located at "C:\Windows\SystemResources\shell32.dll.mun"
#        This means if you want to reference the data from a DLL that is NOT at C:\Windows\System32\shell32.dll, you should directly reference the .mun file instead. It will auto redirect if it's at that exact path, but not otherwise.
#            > This is especially important if wanting to reference the data from a different computer, you need to be sure to copy the .mun file
#        See: https://stackoverflow.com/questions/68389730/windows-dll-function-behaviour-is-different-if-dll-is-moved-to-different-locatio
#
# -CustomLanguageFolderPath
#     • String Type
#     Specify a path to a folder containing language-specific MUI files to use for localized string references, and it will prefer any mui files from there if available instead of the system default.
#     For example, to use your own language file for shell32.dll, you could specify a path to a folder containing a file named "shell32.dll.mui" in the desired language, and any other such files.
#     For another example, if you have multiple language packs installed on your system, you could specify the entire language directory in system32 such as "C:\Windows\System32\en-US" to use English strings, or "C:\Windows\System32\de-DE" for German strings.
#
# -CustomSystemSettingsDLLPath
#     • String Type
#     Specify a custom path to the SystemSettings.dll file to load the system settings (ms-settings: links) content from. If not provided, the default SystemSettings.dll will be used.
#
# -CustomAllSystemSettingsXMLPath
#     • String Type
#     Specify a custom path to the AllSystemSettings XML file to load deep links from. If not provided, the default AllSystemSettings XML file will be used.
#     The default path is "C:\Windows\ImmersiveControlPanel\Settings\AllSystemSettings\ and versions may vary depending on Windows 11 or Windows 10.
#
# ------------------------------------------------------------------------------------------------------
#
#   EXAMPLE USAGE FROM COMMAND LINE:
#       .\Super_God_Mode.ps1 -NoStatistics -CollectExtraURLProtocolInfo -Output "C:\Users\Username\Desktop\My Shortcuts"
#
# ------------------------------------------------------------------------------------------------------
param(
    # Alternative Options Arguments
    [switch]$DontGroupTasks,
    [switch]$UseAlternativeCategoryNames,
    [switch]$AllURLProtocols,
    [switch]$CollectExtraURLProtocolInfo,
    [switch]$AllowDuplicateDeepLinks,
    [switch]$DeepScanHiddenLinks,
    # Control Output
    [string]$Output,
    [switch]$KeepPreviousOutputFolders,
    # Arguments to Limit Outputs
    [switch]$NoStatistics,
    [switch]$NoReadMe,
    [switch]$SkipCLSID,
    [switch]$SkipNamedFolders,
    [switch]$SkipTaskLinks,
    [switch]$SkipMSSettings,
    [switch]$SkipDeepLinks,
    [switch]$SkipURLProtocols,
    [switch]$SkipHiddenAppLinks,
    # Debugging
    [switch]$Verbose,
    [switch]$Debug,
    [switch]$timing,
    [switch]$debugSkipAppxSearch,
    [string]$debugSearchOnlyProtocolList,
    [switch]$uniqueOutputFolder,
    # Advanced Arguments
    [switch]$NoGUI,
    [string]$CustomDLLPath,
    [string]$CustomLanguageFolderPath,
    [string]$CustomSystemSettingsDLLPath,
    [string]$CustomAllSystemSettingsXMLPath
)

# Note: Arguments that are command line only and not used in the GUI:
# -NoGUI
# -NoReadMe
# -CustomDLLPath
# -CustomLanguageFolderPath
# -CustomSystemSettingsDLLPath
# -CustomAllSystemSettingsXMLPath
# -debugSkipAppxSearch
# -debugSearchOnlyProtocolList
# -uniqueOutputFolder

$VERSION = "1.2.3"



# ==============================================================================================================================
# ==================================================  GUI FUNCTION  ============================================================
# ==============================================================================================================================

# Function to show a GUI dialog for selecting script options
function Show-SuperGodModeDialog {
    # Add param for output folder default name
    param(
        [string]$defaultOutputFolderName,
        [switch]$initialDebug,
        [switch]$initialVerbose
    )
    # Define tooltips here for easy editing
    $tooltips = @{
        # Use &#x0a; for line breaks in the tooltip text
        DontGroupTasks = "防止对任务快捷方式进行分组，&#x0a;这意味着应用程序名称不会添加到快捷方式文件中的任务名称之前"
        UseAlternativeCategoryNames = "查找任务链接的替代类别名称，以便将其添加到任务名称之前"
        AllURLProtocols = "创建指向 URL 协议的快捷方式时，例如 'ms-settings://', &#x0a;包括来自已安装软件的第三方 URL 协议，而不仅仅是 Microsoft 或系统协议"
        CollectExtraURLProtocolInfo = "收集有关 URL 协议的额外信息，这些信息将进入 CSV 电子表格。 &#x0a;可选，因为它不用于快捷方式，并且需要稍长时间。"
        KeepPreviousOutputFolders = "在运行脚本之前不删除现有输出文件夹。 &#x0a;如果再次创建，将仍然覆盖任何现有快捷方式。"
        CollectStatistics = "创建统计文件夹和文件，其中包含有关 shell 文件夹的 CSV 数据 &#x0a;和任务以及其他收集数据的 XML 文件"
        AllowDuplicateDeepLinks = "允许创建与现有任务链接相同的深度链接。 &#x0a;默认情况下，此类重复项不包括在深度链接文件夹中。"
        CollectCLSID = "根据 CLSID 创建 shell 文件夹的快捷方式"
        CollectNamedFolders = "为特殊名称文件夹创建快捷方式"
        CollectTaskLinks = "为任务链接（shell 文件夹和控制面板菜单中的子页面）创建快捷方式"
        CollectMSSettings = "为 ms-settings: 链接（系统设置页面）创建快捷方式"
        CollectDeepLinks = "为深度链接（直接链接到 Windows 各种设置菜单）创建快捷方式"
        CollectURLProtocols = "为 URL 协议（例如，ms-settings: 等）创建快捷方式"
        CollectAppxLinks = "为应用程序的隐藏子页面 URL 链接创建快捷方式（例如，ms-clock://pausefocustimer 等） &#x0a;注意：需要收集 URL 协议链接"
        DeepScanHiddenLinks = "扫描非 appx 包应用程序的安装目录中的所有文件以查找隐藏链接。 &#x0a;否则只会搜索主要的二进制文件。 &#x0a;&#x0a;注意：这将慢得多。 &#x0a;另请注意：不要与 &quot;深度链接&quot; 混淆。"
        LoggingLevel = "选择在运行时控制台窗口中显示的详细程度：&#x0a; - 标准：正常日志记录&#x0a; - 详细：更详细的日志记录&#x0a; - 调试：最大详细信息，还会创建一些日志文件。"
    }

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms

    [xml]$xaml = @"
    <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Super God Mode 选项" Height="715" Width="800"
        FontFamily="Microsoft YaHei">
        <Window.Resources>
            <Color x:Key="BackgroundColor">#1E1E1E</Color>
            <Color x:Key="ForegroundColor">#CCCCCC</Color>
            <Color x:Key="AccentColor">#0078D4</Color>
            <Color x:Key="SecondaryBackgroundColor">#2D2D2D</Color>
            <Color x:Key="BorderColor">#3F3F3F</Color>
            <Color x:Key="WarningColor">#FF6B68</Color>
            <Color x:Key="VersionColor">#888888</Color>
            <Color x:Key="ButtonHoverColor">#1b99fa</Color>
            <Color x:Key="HighlightedTextColor">#69d2ff</Color>

            <SolidColorBrush x:Key="BackgroundBrush" Color="{StaticResource BackgroundColor}"/>
            <SolidColorBrush x:Key="ForegroundBrush" Color="{StaticResource ForegroundColor}"/>
            <SolidColorBrush x:Key="AccentBrush" Color="{StaticResource AccentColor}"/>
            <SolidColorBrush x:Key="SecondaryBackgroundBrush" Color="{StaticResource SecondaryBackgroundColor}"/>
            <SolidColorBrush x:Key="BorderBrush" Color="{StaticResource BorderColor}"/>
            <SolidColorBrush x:Key="WarningBrush" Color="{StaticResource WarningColor}"/>
            <SolidColorBrush x:Key="VersionBrush" Color="{StaticResource VersionColor}"/>
            <SolidColorBrush x:Key="ButtonHoverBrush" Color="{StaticResource ButtonHoverColor}"/>
            <SolidColorBrush x:Key="HighlightedTextBrush" Color="{StaticResource HighlightedTextColor}"/>
            
            <Thickness x:Key="BorderThickness">1</Thickness>
            <Thickness x:Key="GroupBoxPadding">5</Thickness>

            <Style x:Key="DarkModeGroupBoxStyle" TargetType="GroupBox">
                <Setter Property="BorderBrush" Value="{StaticResource BorderBrush}"/>
                <Setter Property="BorderThickness" Value="{StaticResource BorderThickness}"/>
                <Setter Property="Padding" Value="{StaticResource GroupBoxPadding}"/>
                <Setter Property="Margin" Value="0,10,0,10"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="GroupBox">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="*"/>
                                </Grid.RowDefinitions>
                                <Border BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Grid.Row="0" Grid.RowSpan="2"/>
                                <Border Background="{TemplateBinding Background}" BorderBrush="Transparent" BorderThickness="{TemplateBinding BorderThickness}" Grid.Row="1">
                                    <ContentPresenter Margin="{TemplateBinding Padding}"/>
                                </Border>
                                <TextBlock Margin="5,0,0,0" Padding="3,0,3,0" Background="{StaticResource BackgroundBrush}" HorizontalAlignment="Left" VerticalAlignment="Top" TextElement.Foreground="{StaticResource ForegroundBrush}" Text="{TemplateBinding Header}"/>
                            </Grid>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>

            <Style x:Key="SubtleButtonStyle" TargetType="Button">
                <Setter Property="Background" Value="Transparent"/>
                <Setter Property="Foreground" Value="{StaticResource ForegroundBrush}"/>
                <Setter Property="BorderThickness" Value="0"/>
                <Setter Property="FontSize" Value="12"/>
                <Setter Property="Cursor" Value="Hand"/>
                <Setter Property="Padding" Value="10,5"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="Button">
                            <Border Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
                <Style.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter Property="Background" Value="{StaticResource ButtonHoverBrush}"/>
                    </Trigger>
                </Style.Triggers>
            </Style>

            <Style x:Key="CustomCheckBoxStyle" TargetType="CheckBox" BasedOn="{StaticResource {x:Type CheckBox}}">
                <Style.Triggers>
                    <Trigger Property="IsEnabled" Value="False">
                        <Setter Property="Opacity" Value="0.5"/>
                    </Trigger>
                </Style.Triggers>
            </Style>

            <Style x:Key="HighlightedCheckBoxStyle" TargetType="CheckBox" BasedOn="{StaticResource {x:Type CheckBox}}">
                <Setter Property="Foreground" Value="{StaticResource HighlightedTextBrush}"/>
                <Setter Property="FontWeight" Value="Semibold"/>
            </Style>

        </Window.Resources>
        <Grid Background="{StaticResource BackgroundBrush}">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Border Background="{StaticResource AccentBrush}" Grid.Row="0">
                <Grid>
                    <StackPanel>
                        <TextBlock Text="&quot;Super God Mode&quot; 脚本" FontSize="24" Foreground="White" HorizontalAlignment="Center" Margin="0,10,0,0"/>
                        <TextBlock Text="适用于 Windows" FontSize="16" Foreground="White" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                    </StackPanel>
                    <Button x:Name="btnAbout" Content="关于" Style="{StaticResource SubtleButtonStyle}"
                            HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,10,10,0"/>
                </Grid>
            </Border>

            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                <Grid Margin="10">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <TextBlock Text="将鼠标悬停在设置上以查看详细信息" FontStyle="Italic" HorizontalAlignment="Right" Margin="0,0,0,10" Grid.Row="0" Foreground="{StaticResource ForegroundBrush}"/>

                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <GroupBox Header="可选项" Grid.Column="0" Style="{StaticResource DarkModeGroupBoxStyle}">
                            <StackPanel Margin="5">
                                <CheckBox x:Name="chkDontGroupTasks" Content="任务链接:    不分组任务链接" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.DontGroupTasks)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkUseAlternativeCategoryNames" Content="任务链接:    使用替代类别名称" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.UseAlternativeCategoryNames)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                               <CheckBox x:Name="chkAllowDuplicateDeepLinks" Content="深度链接:  允许复制深度链接" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.AllowDuplicateDeepLinks)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkAllURLProtocols" Content="协议:     包括第三方应用程序URL协议" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.AllURLProtocols)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectExtraURLProtocolInfo" Content="协议:     收集额外的 URL 协议信息" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectExtraURLProtocolInfo)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkDeepScanHiddenLinks" Content="协议:     深度扫描隐藏链接（慢）" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.DeepScanHiddenLinks)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Header="输出控制" Grid.Column="1" Style="{StaticResource DarkModeGroupBoxStyle}">
                            <Grid Margin="5">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>

                                <CheckBox x:Name="chkCollectStatistics" Content="收集统计信息  &#128202;" IsChecked="True" Margin="0,5,5,5" Grid.Column="0" Grid.Row="0" Style="{StaticResource HighlightedCheckBoxStyle}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectStatistics)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectCLSID" Content="CLSID 链接" IsChecked="True" Margin="5,5,0,5" Grid.Column="1" Grid.Row="0" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectCLSID)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectNamedFolders" Content="特殊名称文件夹链接" IsChecked="True" Margin="0,5,5,5" Grid.Column="0" Grid.Row="1" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectNamedFolders)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectTaskLinks" Content="任务链接" IsChecked="True" Margin="5,5,0,5" Grid.Column="1" Grid.Row="1" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectTaskLinks)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectMSSettings" Content="MS-Settings 链接" IsChecked="True" Margin="0,5,5,5" Grid.Column="0" Grid.Row="2" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectMSSettings)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectDeepLinks" Content="深度链接" IsChecked="True" Margin="5,5,0,5" Grid.Column="1" Grid.Row="2" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectDeepLinks)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectURLProtocols" Content="URL 协议链接" IsChecked="True" Margin="0,5,5,5" Grid.Column="0" Grid.Row="3" Foreground="{StaticResource ForegroundBrush}">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectURLProtocols)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                                <CheckBox x:Name="chkCollectAppxLinks" Content="隐藏的应用链接" IsChecked="True" Margin="5,5,0,5" Grid.Column="1" Grid.Row="3" Foreground="{StaticResource ForegroundBrush}" Style="{StaticResource CustomCheckBoxStyle}" ToolTipService.ShowOnDisabled="True">
                                    <CheckBox.ToolTip>
                                        <ToolTip Content="$($tooltips.CollectAppxLinks)" />
                                    </CheckBox.ToolTip>
                                </CheckBox>
                            </Grid>
                        </GroupBox>
                    </Grid>

                    <GroupBox Header="输出目录" Grid.Row="2" Style="{StaticResource DarkModeGroupBoxStyle}">
                        <StackPanel Margin="5">
                            <CheckBox x:Name="chkKeepPreviousOutputFolders" Content="不自动删除现有输出文件夹" Margin="0,5,0,0" Foreground="{StaticResource ForegroundBrush}">
                                <CheckBox.ToolTip>
                                    <ToolTip Content="$($tooltips.KeepPreviousOutputFolders)" />
                                </CheckBox.ToolTip>
                            </CheckBox>
                            <TextBlock Text="输出目录:" Margin="0,10,0,5" Foreground="{StaticResource ForegroundBrush}"/>
                            <DockPanel LastChildFill="True" Margin="0,0,0,5">
                                <Button x:Name="btnBrowse" Content="浏览" DockPanel.Dock="Right" Margin="5,0,0,0" Padding="10,5" FontSize="14" MinWidth="100" Background="{StaticResource SecondaryBackgroundBrush}" Foreground="{StaticResource ForegroundBrush}"/>
                                <TextBox x:Name="txtOutputPath" IsReadOnly="True" Padding="5,0,0,0" VerticalContentAlignment="Center" FontSize="14" Height="30" Background="{StaticResource SecondaryBackgroundBrush}" Foreground="{StaticResource ForegroundBrush}"/>
                            </DockPanel>
                            <TextBlock Text="输出文件夹名称:" Margin="0,5,0,5" Foreground="{StaticResource ForegroundBrush}"/>
                            <TextBox x:Name="txtOutputFolderName" Margin="0,0,0,5" Padding="5,0,0,0" VerticalContentAlignment="Center" FontSize="14" Height="30" Background="{StaticResource SecondaryBackgroundBrush}" Foreground="{StaticResource ForegroundBrush}"/>
                            <Separator Margin="0,10,0,10" Background="{StaticResource BorderBrush}"/>
                            <TextBlock Text="最终输出路径:" Margin="0,5,0,5" FontWeight="Bold" Foreground="{StaticResource ForegroundBrush}"/>
                            <TextBlock x:Name="txtCurrentPath" Text="" Margin="0,0,0,10" TextWrapping="Wrap" FontWeight="Bold" Foreground="{StaticResource ForegroundBrush}"/>
                        </StackPanel>
                    </GroupBox>

                    <StackPanel Grid.Row="3">
                        <Button x:Name="btnOK" Content="运行脚本" Width="Auto" Height="Auto" FontSize="14" HorizontalAlignment="Center" Margin="0,10,0,10" Padding="10,5" Background="{StaticResource AccentBrush}" Foreground="White"/>
                        <TextBlock Text="所有设置都是可选的-让它们单独使用默认值" FontWeight="Bold" Foreground="{StaticResource WarningBrush}" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Grid.Column="0" Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Center">
                                <TextBlock Text="日志等级:" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="{StaticResource ForegroundBrush}">
                                    <TextBlock.ToolTip>
                                        <ToolTip Content="$($tooltips.LoggingLevel)" />
                                    </TextBlock.ToolTip>
                                </TextBlock>
                                <ComboBox x:Name="cmbLoggingLevel" Width="Auto" MinWidth="65" SelectedIndex="0">
                                    <ComboBoxItem Content="标准"/>
                                    <ComboBoxItem Content="详细"/>
                                    <ComboBoxItem Content="调试"/>
                                    <ComboBox.ToolTip>
                                        <ToolTip Content="$($tooltips.LoggingLevel)" />
                                    </ComboBox.ToolTip>
                                </ComboBox>
                            </StackPanel>
                        </Grid>
                    </StackPanel>
                </Grid>
            </ScrollViewer>

            <TextBlock x:Name="txtVersion" Text="版本: $VERSION" Grid.Row="1" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,10,5" FontSize="12" Foreground="{StaticResource VersionBrush}"/>
        </Grid>
    </Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Alternate Settings Check Boxes
    $chkDontGroupTasks = $window.FindName("chkDontGroupTasks")
    $chkUseAlternativeCategoryNames = $window.FindName("chkUseAlternativeCategoryNames")
    $chkAllURLProtocols = $window.FindName("chkAllURLProtocols")
    $chkCollectExtraURLProtocolInfo = $window.FindName("chkCollectExtraURLProtocolInfo")
    $chkKeepPreviousOutputFolders = $window.FindName("chkKeepPreviousOutputFolders")
    $chkAllowDuplicateDeepLinks = $window.FindName("chkAllowDuplicateDeepLinks")
    $chkDeepScanHiddenLinks = $window.FindName("chkDeepScanHiddenLinks")

    # Control Outputs Check Boxes
    $chkCollectStatistics = $window.FindName("chkCollectStatistics")
    $chkCollectCLSID = $window.FindName("chkCollectCLSID")
    $chkCollectNamedFolders = $window.FindName("chkCollectNamedFolders")
    $chkCollectTaskLinks = $window.FindName("chkCollectTaskLinks")
    $chkCollectMSSettings = $window.FindName("chkCollectMSSettings")
    $chkCollectDeepLinks = $window.FindName("chkCollectDeepLinks")
    $chkCollectURLProtocols = $window.FindName("chkCollectURLProtocols")
    $chkCollectAppxLinks = $window.FindName("chkCollectAppxLinks")

    # Output Location Controls
    $txtOutputPath = $window.FindName("txtOutputPath")
    $txtCurrentPath = $window.FindName("txtCurrentPath")
    $txtOutputFolderName = $window.FindName("txtOutputFolderName")
    $btnBrowse = $window.FindName("btnBrowse")
    $btnOK = $window.FindName("btnOK")

    # Other controls
    $cmbLoggingLevel = $window.FindName("cmbLoggingLevel")
    # Set initial logging level based on the initialDebug and initialVerbose switches
    if ($initialDebug) {
        $cmbLoggingLevel.SelectedIndex = 2
    } elseif ($initialVerbose) {
        $cmbLoggingLevel.SelectedIndex = 1
    } else {
        $cmbLoggingLevel.SelectedIndex = 0
    }

    # Set default values
    $defaultOutputPath = $PSScriptRoot
    $txtOutputPath.Text = $defaultOutputPath
    $txtOutputFolderName.Text = $defaultOutputFolderName
    $txtCurrentPath.Text = [System.IO.Path]::Combine($defaultOutputPath, $defaultOutputFolderName)

    # Add event handlers like browse button and text change
    $btnBrowse.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $folderBrowser.ValidateNames = $false
        $folderBrowser.CheckFileExists = $false
        $folderBrowser.CheckPathExists = $true
        $folderBrowser.FileName = "Folder Selection"
        $folderBrowser.Title = "选择输出目录"
        $folderBrowser.InitialDirectory = $txtOutputPath.Text
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $selectedPath = Split-Path $folderBrowser.FileName
            $txtOutputPath.Text = $selectedPath
            UpdateCurrentPath
        }
    })

    # Add event handler for URL Protocols checkbox
    $chkCollectURLProtocols.Add_Checked({
        $chkCollectAppxLinks.IsEnabled = $true
    })

    $chkCollectURLProtocols.Add_Unchecked({
        $chkCollectAppxLinks.IsChecked = $false
        $chkCollectAppxLinks.IsEnabled = $false
    })

    # Initialize the state of chkCollectAppxLinks based on chkCollectURLProtocols
    $chkCollectAppxLinks.IsEnabled = $chkCollectURLProtocols.IsChecked

    $txtOutputPath.Add_TextChanged({ UpdateCurrentPath })
    $txtOutputFolderName.Add_TextChanged({ UpdateCurrentPath })

    # After loading the XAML and before showing the window
    $btnAbout = $window.FindName("btnAbout")
    $btnAbout.Add_Click({
        [System.Windows.MessageBox]::Show("    适用于 Windows 的 `"Super God Mode`" 脚本

    版本: $VERSION
    作者: ThioJoe
    汉化: 短臂猿-Short_Arm_Ape
    源码:
    https://github.com/ThioJoe/Windows-Super-God-Mode
    汉化分支: 
    https://github.com/Short-Arm-Ape/Windows-Super-God-Mode-Chinese-ver
    ",
            "关于 Super God Mode 脚本",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::None
        )
    })

    function UpdateCurrentPath {
        $outputPath = $txtOutputPath.Text
        $folderName = $txtOutputFolderName.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($folderName)) {
            $txtCurrentPath.Text = $outputPath
        } else {
            $txtCurrentPath.Text = [System.IO.Path]::Combine($outputPath, $folderName)
        }
    }

    $btnOK.Add_Click({
        $window.DialogResult = $true
        $window.Close()
    })

    $result = $window.ShowDialog()

    if (-not $result) {
        return $null
    }

    # Return script parameters based on GUI selections
    return @{
        # Alternative Options
        DontGroupTasks = $chkDontGroupTasks.IsChecked
        UseAlternativeCategoryNames = $chkUseAlternativeCategoryNames.IsChecked
        AllURLProtocols = $chkAllURLProtocols.IsChecked
        CollectExtraURLProtocolInfo = $chkCollectExtraURLProtocolInfo.IsChecked
        KeepPreviousOutputFolders = $chkKeepPreviousOutputFolders.IsChecked
        NoStatistics = !$chkCollectStatistics.IsChecked
        AllowDuplicateDeepLinks = $chkAllowDuplicateDeepLinks.IsChecked
        DeepScanHiddenLinks = $chkDeepScanHiddenLinks.IsChecked
        # Inverse of the Skip options
        SkipCLSID = !$chkCollectCLSID.IsChecked
        SkipNamedFolders = !$chkCollectNamedFolders.IsChecked
        SkipTaskLinks = !$chkCollectTaskLinks.IsChecked
        SkipMSSettings = !$chkCollectMSSettings.IsChecked
        SkipDeepLinks = !$chkCollectDeepLinks.IsChecked
        SkipURLProtocols = !$chkCollectURLProtocols.IsChecked
        SkipHiddenAppLinks = !$chkCollectAppxLinks.IsChecked
        # Output folder path
        Output = $txtCurrentPath.Text
        # Logging level
        Verbose = $cmbLoggingLevel.SelectedIndex -eq 1
        Debug = $cmbLoggingLevel.SelectedIndex -eq 2
    }
}

# Setting the default folder name up here so it can be used in the GUI dialog
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$defaultOutputFolderName = "Super God Mode"
if ($uniqueOutputFolder) { $defaultOutputFolderName += "-$timestamp" }

# Start the GUI dialog unless -NoGUI is used
if (-not $NoGUI) {
    Write-Host "`n使用刚刚出现的GUI窗口选择任何选项并运行脚本。`n(请勿关闭此窗口)"
    $params = Show-SuperGodModeDialog -defaultOutputFolderName $defaultOutputFolderName -initialDebug:$Debug -initialVerbose:$Verbose
    if ($null -eq $params) {
        Write-host "脚本GUI窗口似乎已被关闭。正在退出脚本。`n" -ForegroundColor Yellow
        exit
    }
    # Use $params here to set your script variables
    $DontGroupTasks = $params.DontGroupTasks
    $UseAlternativeCategoryNames = $params.UseAlternativeCategoryNames
    $AllURLProtocols = $params.AllURLProtocols
    $CollectExtraURLProtocolInfo = $params.CollectExtraURLProtocolInfo
    $KeepPreviousOutputFolders = $params.KeepPreviousOutputFolders
    $NoStatistics = $params.NoStatistics
    $AllowDuplicateDeepLinks = $params.AllowDuplicateDeepLinks
    $DeepScanHiddenLinks = $params.DeepScanHiddenLinks
    $SkipCLSID = $params.SkipCLSID
    $SkipNamedFolders = $params.SkipNamedFolders
    $SkipTaskLinks = $params.SkipTaskLinks
    $SkipMSSettings = $params.SkipMSSettings
    $SkipDeepLinks = $params.SkipDeepLinks
    $SkipURLProtocols = $params.SkipURLProtocols
    $SkipHiddenAppLinks = $params.SkipHiddenAppLinks
    $Output = $params.Output
    $Verbose = $params.Verbose
    $Debug = $params.Debug
}

# If -Debug or -Verbose is used, set $DebugPreference and $VerbosePreference to Continue, otherwise set to SilentlyContinue.
# This way it will show messages without stopping if -Debug is used and not otherwise
if ($Verbose) {
    $Verbose = $true # Setting it as $true instead of letting it be a switch to avoid confusion with 'IsPresent' property
    $VerbosePreference = 'Continue'
} else { $VerbosePreference = 'SilentlyContinue' }

if ($Debug) {
    $Debug = $true # Setting it as $true instead of letting it be a switch to avoid confusion with 'IsPresent' property
    $DebugPreference = 'Continue'
    $VerbosePreference = 'Continue' # If Debug is used, also enable Verbose
    $Verbose = $true # Set Verbose to true if Debug is used
} else { $DebugPreference = 'SilentlyContinue' }

Write-Host "正在执行脚本..." -ForegroundColor Green

# ====================================================================================================================================
# ==================================================  SCRIPT PREPARATION  ============================================================
# ====================================================================================================================================


# Set the output folder path for the generated shortcuts based on the provided argument or default location. Convert to full path if necessary
if ($Output) {
    # Remove any trailing backslashes from the output path
    $Output = $Output.TrimEnd("\")
    # Append timestamp if unique output folder is requested
    if ($uniqueOutputFolder) { $Output += "-$timestamp" }

    # Convert to full path only if necessary, otherwise use as is
    if (-not [System.IO.Path]::IsPathRooted($Output)) {
        $mainShortcutsFolder = Join-Path $PSScriptRoot $Output
    } else { $mainShortcutsFolder = $Output }
} else {
    # Default output folder path is a subfolder named "Super God Mode" in the script's directory
    $mainShortcutsFolder = Join-Path $PSScriptRoot $defaultOutputFolderName
}

# If Debug mode enabled, create debug logs folder and start transcript
$debugLogsFolderName = "__调试日志"
$debugLogFolderPath = Join-Path $mainShortcutsFolder $debugLogsFolderName
if ($Debug) {
    if (-not (Test-Path $debugLogFolderPath)) { New-Item -Path $debugLogFolderPath -ItemType Directory -Force | Out-Null }
    $debugTranscriptFileName = "DebugTranscript-$timestamp.log"
    $debugTranscriptFilePath = Join-Path $debugLogFolderPath $debugTranscriptFileName
    Start-Transcript -Path $debugTranscriptFilePath
}

# Print the script parameters to the console
if ($Debug) {
    Write-Debug "************** 初始脚本参数 **************"
    Write-Debug ("不分组任务: $DontGroupTasks`n使用替代类别名称: $UseAlternativeCategoryNames`n" +
        "所有URL协议: $AllURLProtocols`n收集额外URL协议信息: $CollectExtraURLProtocolInfo`n" +
        "允许重复深度链接: $AllowDuplicateDeepLinks`n深度扫描隐藏链接: $DeepScanHiddenLinks`n" +
        "输出: $Output`n保留先前输出文件夹: $KeepPreviousOutputFolders`n无统计信息: $NoStatistics`n" +
        "无自述文件: $NoReadMe`n跳过CLSID: $SkipCLSID`n跳过命名文件夹: $SkipNamedFolders`n" +
        "跳过任务链接: $SkipTaskLinks`n跳过MS设置: $SkipMSSettings`n跳过深度链接: $SkipDeepLinks`n" +
        "跳过URL协议: $SkipURLProtocols`n跳过隐藏应用链接: $SkipHiddenAppLinks`n详细: $Verbose`n" +
        "调试: $Debug`n计时: $timing`n调试跳过Appx搜索: $debugSkipAppxSearch`n" +
        "调试仅搜索协议列表: $debugSearchOnlyProtocolList`n唯一输出文件夹: $uniqueOutputFolder`n" +
        "无GUI: $NoGUI`n自定义动态链接库路径: $CustomDLLPath`n自定义语言文件夹路径: $CustomLanguageFolderPath`n" +
        "自定义系统设置动态链接库路径: $CustomSystemSettingsDLLPath`n自定义所有系统设置XML路径: $CustomAllSystemSettingsXMLPath")
}

# Define folder names
$clsidFolderName = "CLSID Shell 文件夹"
$namedFolderName = "特殊名称文件夹"
$taskLinksFolderName = "所有任务链接"
$msSettingsFolderName = "系统设置"
$deepLinksFolderName = "深度链接"
$urlProtocolsFolderName = "URL 协议"
$URLProtocolPageLinksFolderName = "隐藏的应用链接"
$statisticsFolderName = "__脚本运行结果统计信息"

# Construct paths for subfolders
$CLSIDshortcutsOutputFolder = Join-Path $mainShortcutsFolder $clsidFolderName
$namedShortcutsOutputFolder = Join-Path $mainShortcutsFolder $namedFolderName
$taskLinksOutputFolder = Join-Path $mainShortcutsFolder $taskLinksFolderName
$msSettingsOutputFolder = Join-Path $mainShortcutsFolder $msSettingsFolderName
$deepLinksOutputFolder = Join-Path $mainShortcutsFolder $deepLinksFolderName
$URLProtocolLinksOutputFolder = Join-Path $mainShortcutsFolder $urlProtocolsFolderName
$URLProtocolPageLinksOutputFolder = Join-Path $mainShortcutsFolder $URLProtocolPageLinksFolderName
$statisticsOutputFolder = Join-Path $mainShortcutsFolder $statisticsFolderName

# Define hashtables for CSV and XML files
$csvFiles = @{
    CLSID = @{ Value = "CLSID_Shell_Folders.csv"; Skip = $SkipCLSID }
    NamedFolders = @{ Value = "Named_Shell_Folders.csv"; Skip = $SkipNamedFolders }
    TaskLinks = @{ Value = "Task_Links.csv"; Skip = $SkipTaskLinks }
    MSSettings = @{ Value = "MS_Settings.csv"; Skip = $SkipMSSettings }
    DeepLinks = @{ Value = "Deep_Links.csv"; Skip = $SkipDeepLinks }
    URLProtocols = @{ Value = "URL_Protocols.csv"; Skip = $SkipURLProtocols }
    URLProtocolPages = @{ Value = "Hidden_App_Links.csv"; Skip = $SkipHiddenAppLinks }
}
$xmlFiles = @{
    Shell32Content = @{ Value = "Shell32_Tasks.xml"; Skip = $SkipTaskLinks }
    Shell32ResolvedContent = @{ Value = "Shell32_Tasks_Resolved.xml"; Skip = $SkipTaskLinks }
    ResolvedSettings = @{ Value = "Settings_XML_Resolved.xml"; Skip = $SkipDeepLinks }
}

# Set filenames for various output files (CSV and XML)
$clsidCsvPath = Join-Path $statisticsOutputFolder $csvFiles.CLSID.Value
$namedFoldersCsvPath = Join-Path $statisticsOutputFolder $csvFiles.NamedFolders.Value
$taskLinksCsvPath = Join-Path $statisticsOutputFolder $csvFiles.TaskLinks.Value
$msSettingsCsvPath = Join-Path $statisticsOutputFolder $csvFiles.MSSettings.Value
$deepLinksCsvPath = Join-Path $statisticsOutputFolder $csvFiles.DeepLinks.Value
$URLProtocolLinksCsvPath = Join-Path $statisticsOutputFolder $csvFiles.URLProtocols.Value
$URLProtocolPageLinksCsvPath = Join-Path $statisticsOutputFolder $csvFiles.URLProtocolPages.Value

# XML content file paths
$xmlContentFilePath = Join-Path $statisticsOutputFolder $xmlFiles.Shell32Content.Value
$resolvedXmlContentFilePath = Join-Path $statisticsOutputFolder $xmlFiles.Shell32ResolvedContent.Value
$resolvedSettingsXmlContentFilePath = Join-Path $statisticsOutputFolder $xmlFiles.ResolvedSettings.Value

# Other constants / known paths.
# Available AllSystemSettings XML files may differ depending on Windows 11 or Windows 10, so will try them in order:
$allSettingsXmlPath1 = "$Env:windir\ImmersiveControlPanel\Settings\AllSystemSettings_{D6E2A6C6-627C-44F2-8A5C-4959AC0C2B2D}.xml"
$allSettingsXmlPath2 = "$Env:windir\ImmersiveControlPanel\Settings\AllSystemSettings_{FDB289F3-FCFC-4702-8015-18926E996EC1}.xml"
$allSettingsXmlPath3 = "$Env:windir\ImmersiveControlPanel\Settings\AllSystemSettings_{253E530E-387D-4BC2-959D-E6F86122E5F2}.xml"
$systemSettingsDllPath = "$Env:windir\ImmersiveControlPanel\SystemSettings.dll"



# URI Protocols deemed "permanent" and not to be included in the URL Protocols section because they aren't special
# See: https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
$permanentURIProtocols = @(
    'bb','drop','fax','filesystem','grd','mailserver','modem','p1','pack','payment','prospero','snews','upt','videotex','wais','wpid','z39.50',
    'aaa','aaas','about','acap','acct','cap','cid','coap','coap+tcp','coap+ws','coaps','coaps+tcp','coaps+ws','crid','data','dav','dict','dns',
    'dtn','example','file','ftp','geo','go','gopher','h323','http','https','iax','icap','im','imap','info','ipn','ipp','ipps','iris','iris.beep',
    'iris.lwz','iris.xpc','iris.xpcs','jabber','ldap','leaptofrogans','mailto','mid','msrp','msrps','mt','mtqp','mupdate','news','nfs','ni','nih',
    'nntp','opaquelocktoken','pkcs11','pop','pres','reload','rtsp','rtsps','rtspu','service','session','shttp','sieve','sip','sips','sms','snmp',
    'soap.beep','soap.beeps','stun','stuns','tag','tel','telnet','tftp','thismessage','tip','tn3270','turn','turns','tv','urn','vemmi','vnc','ws',
    'wss','xcon','xcon-userid','xmlrpc.beep','xmlrpc.beeps','xmpp','z39.50r','z39.50s'
)

# Tests if a file exists at a path without throwing a huge exception if it doesn't
function Test-Path-Safe {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        $testPathResult = Test-Path -LiteralPath $Path -PathType Leaf -ErrorAction Stop
        if ($testPathResult -ne $true) {
            Write-Debug "Test-Path-Safe Result for $Path`: $testPathResult"
        }
        return $testPathResult
    }
    catch {
        Write-Debug "Test-Path-Safe: Error checking path - $Path : $_"
        return $false
    }
}

# Check which AllSystemSettings XML file to use
if ($CustomAllSystemSettingsXMLPath) {
    if (-not (Test-Path-Safe $CustomAllSystemSettingsXMLPath)) {
        Write-Error "The specified AllSystemSettings XML path does not exist: $CustomAllSystemSettingsXMLPath"
        return
    } else {
        $allSettingsXmlPath = $CustomAllSystemSettingsXMLPath
    }
} elseif (Test-Path-Safe $allSettingsXmlPath1) {
    $allSettingsXmlPath = $allSettingsXmlPath1
} elseif (Test-Path-Safe $allSettingsXmlPath2) {
    $allSettingsXmlPath = $allSettingsXmlPath2
} elseif (Test-Path-Safe $allSettingsXmlPath3) {
    $allSettingsXmlPath = $allSettingsXmlPath3
} else {
    Write-Error "No AllSystemSettings XML file found in expected directory `"$Env:windir\ImmersiveControlPanel\Settings`"  - Deep Link shortcuts will not be created."
    $allSettingsXmlPath = $null
}

# Check if main folder already exists
if (-not (Test-Path $mainShortcutsFolder)) {
    $mainFolderWasCreatedThisRun = $true
} else {
    $mainFolderWasCreatedThisRun = $false
}

# Creates the main directory if it does not exist; `-Force` ensures it is created without errors if it already exists. It won't overwrite any files within even if the folder already exists
try {
    New-Item -Path $mainShortcutsFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
# If creating the folder failed and it doesn't already exist, throw an error and exit the script. Give suggestions for some specific cases
} catch [System.UnauthorizedAccessException] {
    Write-Error "无法创建输出文件夹: $_"
    # If the default path is used
    if (-not $Output) {
        Write-Host "这可能是由于权限问题。确保您具有在脚本目录中创建文件夹的权限。" -ForegroundColor Yellow
    } else {
        Write-Host "这可能是由于权限问题。确保您具有在指定路径下创建文件夹的权限。" -ForegroundColor Yellow
    }
    return
} catch {
    if (-not (Test-Path $mainShortcutsFolder)) {
        Write-Host "无法创建输出文件夹: $_" -ForegroundColor Yellow
        return
    }
}

# If the -KeepPreviousOutputFolders switch is not used, go into the set main folder and delete each set subfolder using above variable names
# Doing this instead of just deleting the entire main folder in case the user wants to put the output into a directory in use for other things
if (-not $KeepPreviousOutputFolders) {
    try {
        if (Test-Path $mainShortcutsFolder) {
            # Remove folders
            if (Test-Path $CLSIDshortcutsOutputFolder){
                Remove-Item -Path $mainShortcutsFolder -Recurse -Force
            }
            if (Test-Path $namedShortcutsOutputFolder){
                Remove-Item -Path $namedShortcutsOutputFolder -Recurse -Force
            }
            if (Test-Path $taskLinksOutputFolder){
                Remove-Item -Path $taskLinksOutputFolder -Recurse -Force
            }
            if (Test-Path $statisticsOutputFolder) {
                Remove-Item -Path $statisticsOutputFolder -Recurse -Force
            }
            if (Test-Path $msSettingsOutputFolder){
                Remove-Item -Path $msSettingsOutputFolder -Recurse -Force
            }
            if (Test-Path $deepLinksOutputFolder){
                Remove-Item -Path $deepLinksOutputFolder -Recurse -Force
            }
            if (Test-Path $URLProtocolLinksOutputFolder){
                Remove-Item -Path $URLProtocolLinksOutputFolder -Recurse -Force
            }
            if (Test-Path $URLProtocolPageLinksOutputFolder){
                Remove-Item -Path $URLProtocolPageLinksOutputFolder -Recurse -Force
            }
        }
    } catch {
        Write-Error "无法删除先前输出文件夹的内容: $_"
    }
}

# Validate the custom dll path if provided
if ($CustomDLLPath) {
    if (-not (Test-Path-Safe $CustomDLLPath)) {
        Write-Error "指定的 DLL 路径不存在: $CustomDLLPath"
        return
    }
}

# Validate the custom language folder path if provided. Ensure it is a folder
if ($CustomLanguageFolderPath) {
    if (-not (Test-Path $CustomLanguageFolderPath -PathType Container)) {
        Write-Error "指定的自定义语言文件夹路径无效: $CustomLanguageFolderPath"
        # Check if they insetad provided a file path, and if so, suggest they provide the folder containing the file
        if (Test-Path $CustomLanguageFolderPath -PathType Leaf) {
            Write-Host "如果您尝试指定一个文件，请提供包含该文件的文件夹，并将其命名为与其对应的 DLL 文件相对应。" -ForegroundColor Yellow
        }
        return
    }
    else {
        Write-Host "使用自定义语言文件夹路径: $CustomLanguageFolderPath"
    }
}

# Validate the custom system settings DLL path if provided
if ($CustomSystemSettingsDLLPath) {
    if (-not (Test-Path-Safe $CustomSystemSettingsDLLPath)) {
        Write-Error "The specified SystemSettings.dll path does not exist: $CustomSystemSettingsDLLPath"
        return
    } else {
        $systemSettingsDllPath = $CustomSystemSettingsDLLPath
    }
}

# Validate or set appropriate incompatible or dependent switches
if ($SkipURLProtocols) {
    $SkipHiddenAppLinks = $true
}

# Function to create a folder with a custom icon and set Details view
function New-FolderWithIcon {
    param (
        [string]$FolderPath,
        [string]$IconFile,
        [string]$IconIndex,
        [string]$IconFileWin10,
        [string]$IconIndexWin10,
        [switch]$DetailsView,
        [switch]$desktopIniOnly
    )
    # Create the folder
    if (-not $desktopIniOnly) {
        New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
    }

    # Check current build of windows to determine which icon to use
    $windowsBuildNum = [System.Environment]::OSVersion.Version.Build
    if ($windowsBuildNum -lt 22000) {
        # Update the icon index if a different one is specified for Windows 10 and earlier
        if ($IconIndexWin10) {
            $IconIndex = $IconIndexWin10
        }
        if ($IconFileWin10) {
            $IconFile = $IconFileWin10
        }
    }

    # If there's not a negative sign at the beginning of the index, add one
    if ($IconIndex -notmatch '^-') {
        $IconIndex = "-$IconIndex"
    }

    # Create desktop.ini content
    if ($DetailsView) {
        $desktopIniContent = @"
[.ShellClassInfo]
IconResource=$IconFile,$IconIndex
[ViewState]
Mode=4
Vid={137E7700-3573-11CF-AE69-08002B2E1262}
"@
    } else {
        $desktopIniContent = @"
[.ShellClassInfo]
IconResource=$IconFile,$IconIndex
"@
    }

    # Create desktop.ini file
    $desktopIniPath = Join-Path $FolderPath "desktop.ini"
    Set-Content -Path $desktopIniPath -Value $desktopIniContent -Encoding ASCII -Force

    # Set desktop.ini attributes
    $desktopIniItem = Get-Item $desktopIniPath -Force
    $desktopIniItem.Attributes = 'Hidden,System'

    # Set folder attributes
    $folderItem = Get-Item $FolderPath -Force
    $folderItem.Attributes = 'ReadOnly,Directory'
}


# Create relevant subfolders for different types of shortcuts, and set custom icons for each folder
# Notes for choosing an icon:
#    - You can use the tool 'IconsExtract' from NirSoft to see icons in a DLL file and their indexes: https://www.nirsoft.net/utils/iconsext.html
#    - Good DLLs to check for icons are Shell32.dll and Imageres.dll, both in "C:\Windows\System32"
#    - The default icon for a folder is index 3 in Imageres.dll
#    - Be aware some icons may be different at different sizes. For example ImageRes icons 185 and 186 just look like the default folder icon when small, like in details view.
#        - Note: Nirsoft's IconsExtract shows the "small" version of the icon, even if the view option is set to "Large Icons". So many icons will appear as the default folder icon for the reason above.

# Create desktop.ini for main folder if it was created this run
if ($mainFolderWasCreatedThisRun) {
    New-FolderWithIcon -FolderPath $mainShortcutsFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "10" -IconIndexWin10 "190" -desktopIniOnly
}
if (-not $SkipCLSID) {
    New-FolderWithIcon -FolderPath $CLSIDshortcutsOutputFolder -IconFile "%windir%\System32\shell32.dll" -IconIndex "20" -IconIndexWin10 "210" -DetailsView
}

if (-not $SkipNamedFolders) {
    New-FolderWithIcon -FolderPath $namedShortcutsOutputFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "77" -DetailsView
}

if (-not $SkipTaskLinks) {
    New-FolderWithIcon -FolderPath $taskLinksOutputFolder -IconFile "%windir%\System32\shell32.dll" -IconIndex "137" -DetailsView
}
if (-not $SkipMSSettings) {
    New-FolderWithIcon -FolderPath $msSettingsOutputFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "114" -DetailsView
}
if (-not $SkipDeepLinks) {
    New-FolderWithIcon -FolderPath $deepLinksOutputFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "175" -DetailsView
}
if (-not $SkipURLProtocols) {
    New-FolderWithIcon -FolderPath $URLProtocolLinksOutputFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "5302" -DetailsView
}
if (-not $SkipHiddenAppLinks) {
    New-FolderWithIcon -FolderPath $URLProtocolPageLinksOutputFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "1025" -DetailsView
}
if (-not $NoStatistics) {
    New-FolderWithIcon -FolderPath $statisticsOutputFolder -IconFile "%windir%\System32\imageres.dll" -IconIndex "9" -DetailsView
}

# Create any other static files
if (-not $NoReadMe) {
    # Create tips file in statistics folder
    $tipsFilePath = Join-Path $mainShortcutsFolder "!必读 - 提示和信息.txt"
    $tipsContent = @"
------------------------- 提示 -------------------------

• 要轻松查看快捷方式的位置，请在Windows资源管理器中启用“链接目标”列。（右键单击列标题>更多>链接目标）
        注意：该列不会显示它认为的“参数”（目标路径中空格之后的任何内容），因此该列主要用于 `"$urlProtocolsFolderName`", `"$URLProtocolPageLinksFolderName`", 和 `"$msSettingsFolderName`" 文件夹。

• 有些链接可能无法正常工作或显示错误，这是正常现象，因为许多链接没有文档记录，或者可能是旧版本Windows中不再使用的遗留链接。
        例如，`"$taskLinksFolderName`" 文件夹包含的链接通常在某些条件下才会显示，例如计算机是平板电脑、具有手写笔或使用特定语言。

• 脚本将根据Windows版本、启用的功能和安装的软件生成不同数量的快捷方式。
        - 脚本不会使用硬编码的快捷方式列表，而是实际读取系统以查找可用的内容。
        - 所有快捷方式都使用与系统中关联的实际图标和名称。只有主文件夹的名称和图标是我选择的。


------------------- 其他需要注意的 -------------------

• 关于 `"$URLProtocolPageLinksFolderName`" 文件夹需要注意的:
        - 您会注意到CSV统计文件中的URL列表比实际创建的快捷方式数长。
             > 这是因为找到的一些URL包含“可变”占位符（如{1}或以等号结尾），这些占位符需要在运行时填充信息，因此它们不能成为快捷方式。
             > 这些可以通过CSV文件中的“嵌入式变量”列来识别。它们仍然被收集以供参考。
        - 这些URL直接来自应用程序文件和二进制文件的文本，主要是未记录或用于内部使用的。这就是我称它们为“隐藏”的原因。
             > 因此，这些链接可能无法正常工作，或者可能包含奇怪的特定引用，例如“`xbox://search/?productType=games&query=angry%20birds`”
             > 这是因为该URL包含在某个应用程序文件中，可能作为示例、测试的一部分，甚至是帮助消息的一部分。我选择将它们全部包含在内。

• `"easy launcher`" 批处理文件不是运行脚本所必需的，它只是让双击运行脚本变得更容易。
        - 由于默认情况下Windows不会在没有特殊命令/设置（称为`"Execution Policy`"）的情况下运行PowerShell脚本，因此批处理文件使用命令允许脚本在该临时会话中运行。
        - 或者，您可以在运行脚本之前在PowerShell窗口中自己运行此命令：Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
            > 这也只会允许当前PowerShell会话中的脚本，然后您可以使用以下命令运行脚本：.\Super_God_Mode.ps1
            > 注意：在使用Set-ExecutionPolicy时，切勿忘记`-Scope Process`部分，否则可能会降低系统安全性，允许所有脚本永久运行。


---------------------------------------------------------------------------
由 `"Super God Mode`" 脚本 - 版本: $VERSION 创建
作者:         ThioJoe
汉化作者： 短臂猿-Short_Arm_Ape
项目链接:   https://github.com/ThioJoe/Windows-Super-God-Mode
汉化分支： https://github.com/Short-Arm-Ape/Windows-Super-God-Mode-Chinese-ver

"@
    Set-Content -Path $tipsFilePath -Value $tipsContent -Force
}

# ==================================================================================================================================
# ==================================================  TYPE DEFINITIONS  ============================================================
# ==================================================================================================================================

# The following block adds necessary .NET types to PowerShell for later use.
# The `Add-Type` cmdlet is used to add C# code that interacts with Windows API functions.
# These functions include loading and freeing DLLs, finding and loading resources, and more.
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    using System.Text;
    public class Windows
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int LoadString(IntPtr hInstance, uint uID, StringBuilder lpBuffer, int nBufferMax);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr LoadLibraryEx(string lpFileName, IntPtr hFile, uint dwFlags);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr FindResource(IntPtr hModule, int lpName, string lpType);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr LoadResource(IntPtr hModule, IntPtr hResInfo);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr LockResource(IntPtr hResData);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern uint SizeofResource(IntPtr hModule, IntPtr hResInfo);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool FreeLibrary(IntPtr hModule);
    }
"@

# P/Invoke definitions for icon extraction from executables
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class IconExtractor
{
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool DestroyIcon(IntPtr hIcon);
}
"@

# For the Get-LocalizedString function, add a type definition for the Win32 class to load indirect strings from DLLs
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    using System.Text;
    public class Win32 {
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode)]
        public static extern int SHLoadIndirectString(string pszSource, StringBuilder pszOutBuf, int cchOutBuf, IntPtr ppvReserved);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr LoadLibrary(string lpFileName);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int LoadString(IntPtr hInstance, uint uID, StringBuilder lpBuffer, int nBufferMax);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool FreeLibrary(IntPtr hModule);
    }
"@
}

# ======================================================================================================================================
# ==================================================  FUNCTION DEFINITIONS  ============================================================
# ======================================================================================================================================

# Prints a warning message with a yellow background and red border
function Print-SuperWarning {
    param(
        [string]$message
    )
    $paddingSize = 4  # Adjust this value to change the amount of padding
    $lineLength = $message.Length + ($paddingSize * 2)
    $yellowLine = (" " * $lineLength)
    $padding = " " * $paddingSize
    $centeredMessage = $padding + $message + $padding

    Write-Host $yellowLine -BackgroundColor Red
    Write-Host $centeredMessage -BackgroundColor Yellow -ForegroundColor Black
    Write-Host $yellowLine -BackgroundColor Red
}

# Function: Get-LocalizedString
# This function retrieves a localized (meaning in the user's language) string from a DLL based on a reference string given in the registry
# `StringReference` is a reference in the format "@<dllPath>,-<resourceId>".
function Get-LocalizedString {
    param (
        [string]$StringReference,
        [string]$CustomLanguageFolder,
        [string]$AppxManifestPath,
        [switch]$returnSanitizedOnFail = $false
    )
    if ($AppxManifestPath) {
        $manifestParentFolder = Split-Path $AppxManifestPath | Split-Path -Leaf
        Write-Debug "--------------------------------------------------------------------------------------"
        Write-Debug "正在检索资源: $StringReference  | 包名: $manifestParentFolder"
    } else {
        Write-Debug "正在检索资源: $StringReference"
    }

    # Check if it's the special case with multiple concatenated references
    if ($StringReference -match '^\@\@') {
        $references = $StringReference -split '@' | Where-Object { $_ -ne '' }
        $resolvedStrings = @()
        foreach ($ref in $references) {
            $resolved = Get-LocalizedString -StringReference "@$ref" -CustomLanguageFolder $CustomLanguageFolder -AppxManifestPath $AppxManifestPath -returnSanitizedOnFail:$false
            if ($resolved) {
                $resolvedStrings += $resolved -split ';' | ForEach-Object { $_.Trim() }
            }
        }
        return ($resolvedStrings | Select-Object -Unique) -join ';'
    }
    # Check if the string is a short ms-resource reference
    elseif ($StringReference -match '^ms-resource:') {
        return Get-FullMsResource -ShortReference $StringReference -AppxManifestPath $AppxManifestPath -returnSanitizedOnFail:$returnSanitizedOnFail
    }
    # Check if the string is a full ms-resource reference
    elseif ($StringReference -match '@\{.+\?ms-resource://.+}') {
        return Get-MsResource $StringReference -returnSanitizedOnFail:$returnSanitizedOnFail
    }
    # Typical case: Load the DLL and get the string
    elseif ($StringReference -match '@(.+),-(\d+)') {
        $dllPath = [Environment]::ExpandEnvironmentVariables($Matches[1])
        $resourceId = [uint32]$Matches[2]

        # If custom language folder is specified, check if there is a corresponding MUI file for the DLL within that folder.
        $muiNameToCheck = "$dllPath.mui"
        if ($CustomLanguageFolder){
            if (Test-Path-Safe (Join-Path $CustomLanguageFolder $muiNameToCheck)) {
                Write-Verbose "找到自定义语言文件夹中 $dllPath 的 MUI 文件。"
                $dllPath = Join-Path $CustomLanguageFolder $muiNameToCheck
            }
            else {
                Write-Verbose "在自定义语言文件夹中找不到 $dllPath 的 MUI 文件。使用默认系统语言。"
            }
        }

        $hModule = [Win32]::LoadLibrary($dllPath)
        if ($hModule -eq [IntPtr]::Zero) {
            Write-Warning "在典型的字符串引用查找期间加载库失败: $dllPath"
            return Sanitize-Unresolved-Reference -ReferenceString $StringReference -returnSanitizedOnFail:$returnSanitizedOnFail
        }

        $stringBuilder = New-Object System.Text.StringBuilder 1024
        $result = [Win32]::LoadString($hModule, $resourceId, $stringBuilder, $stringBuilder.Capacity)

        [void][Win32]::FreeLibrary($hModule)

        if ($result -ne 0) {
            return $stringBuilder.ToString()
        } else {
            Write-Warning "无法加载字符串资源，未返回结果: $resourceId 来自 $dllPath"
            return Sanitize-Unresolved-Reference -ReferenceString $StringReference -returnSanitizedOnFail:$returnSanitizedOnFail
        }
    } else {
        Write-Warning "无效或未知的区域化字符串引用格式: $StringReference"
        return Sanitize-Unresolved-Reference -ReferenceString $StringReference -returnSanitizedOnFail:$returnSanitizedOnFail
    }
}

function Sanitize-Unresolved-Reference {
    param (
        [string]$ReferenceString,
        [switch]$returnSanitizedOnFail = $false
    )
    $sanitizedReferenceDefault = "UnresolvedReference"

    if (-not $ReferenceString) {
        Write-Debug "No reference string provided to sanitize"
        if ($returnSanitizedOnFail -eq $true) {
            Write-Verbose "No reference string provided to sanitize. Using default: $sanitizedReferenceDefault"
            return $sanitizedReferenceDefault
        }
        Write-Error "No reference string provided to sanitize and returnSanitizedOnFail is set to false."
        return $null
    }

    if ($returnSanitizedOnFail -eq $false) {
        return $null
    }

    try {
        # Remove any leading or trailing whitespace
        $sanitizedReference = $ReferenceString.Trim()
        # Remove any characters that are not allowed in a file name
        $sanitizedReference = $sanitizedReference -replace '[<>:"/\\|?*]', '_'
        $sanitizedReference = "UnresolvedReference - $sanitizedReference"
    } catch {
        Write-Error "Failed to sanitize reference string: $ReferenceString"
        if ($returnSanitizedOnFail -eq $true) {
            Write-Verbose "Failed to sanitize reference string. Using default: $sanitizedReferenceDefault"
            return $sanitizedReferenceDefault
        }
        return $null
    }
    
    Write-Verbose "Sanitizing string to use for unresolved reference: $sanitizedReference"
    return $sanitizedReference
}

function Get-FullMsResource {
    param (
        [string]$ShortReference,
        [string]$AppxManifestPath,
        [switch]$returnSanitizedOnFail = $false
    )

    Write-Debug "Constructing Full Reference for Short Reference: $ShortReference"
    Write-Debug "   | AppxManifestPath: $AppxManifestPath"

    # Load the AppxManifest.xml file
    $manifest = [xml](Get-Content $AppxManifestPath)

    # Extract the package name from the manifest
    $packageName = $manifest.Package.Identity.Name
    Write-Debug "   | Package Name: $packageName"

    # Get the resource name from the short reference. The part after "ms-resource:". There may or may not be slashes
    $resourceName = $ShortReference -replace '^ms-resource:/*', ''
    Write-Debug "   | Resource Name: $resourceName"

    # If the resource name already contains the package name, just use it as is
    if ($resourceName -match "^$packageName/") {
        $fullReference = "@{$packageName`?ms-resource://$resourceName}"
    # Check if the resource name already contains "/Resources/" at beginning or middle, and construct the full reference accordingly
    } elseif ($resourceName -match '^Resources/') {
        $fullReference = "@{$packageName`?ms-resource://$packageName/$resourceName}"
    } elseif ($resourceName -match '/Resources/') {
        $fullReference = "@{$packageName`?ms-resource://$packageName/$resourceName}"
    } else {
        # If it doesn't, add "/Resources/" as before
        $fullReference = "@{$packageName`?ms-resource://$packageName/Resources/$resourceName}"
    }

    Write-Debug "   > Constructed Full Reference: $fullReference"

    # Use the existing Get-MsResource function to resolve the full reference
    return Get-MsResource $fullReference -returnSanitizedOnFail:$returnSanitizedOnFail
}

function Get-MsResource {
    param (
        [string]$ResourcePath,
        [switch]$returnSanitizedOnFail = $false
    )
    Write-Debug "Processing ResourcePath: $ResourcePath"

    $stringBuilder = New-Object System.Text.StringBuilder 1024

    $result = [Win32]::SHLoadIndirectString($ResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
    Write-Debug "   > SHLoadIndirectString result: $result"

    if ($result -eq 0) {
        $resolvedString = $stringBuilder.ToString()
        Write-Debug "   > Resolved string: $resolvedString"
        return $resolvedString
    } else {
        Write-Debug "   + SHLoadIndirectString failed. Attempting alternative methods..."

        # Extract package name and resource URI
        $packageFullName = ($ResourcePath -split '\?')[0].Trim('@{}')
        $resourceUri = ($ResourcePath -split '\?')[1].Trim('@{}')
        Write-Debug "      > Extracted package full name: $packageFullName"
        Write-Debug "      > Extracted resource URI: $resourceUri"

        # Extract package name without version and architecture
        $packageName = ($packageFullName -split '_')[0]
        Write-Debug "      > Extracted package name: $packageName"

        # Find the package installation path
        Write-Debug "      + Searching for package using Get-AppxPackage"
        $package = Get-AppxPackage | Where-Object { $_.Name -eq $packageName }
        if (-not $package) {
            Write-Debug "      + Exact package match not found. Trying to match by package family name."
            $packageFamilyName = ($packageFullName -split '_')[-1]
            $package = Get-AppxPackage | Where-Object { $_.PackageFamilyName -eq "${packageName}_$packageFamilyName" }
        }

        if ($package) {
            Write-Debug "      + Package found: $($package.Name)"
            $packagePath = $package.InstallLocation
            Write-Debug "      > Package installation path: $packagePath"
            $priPath = Join-Path $packagePath "resources.pri"
            Write-Debug "      + Attempting to use resources.pri at: $priPath"
            if (Test-Path-Safe $priPath) {
                $newResourcePath = "@{" + $priPath + "?" + $resourceUri + "}"
                Write-Debug "      > New resource path: $newResourcePath"
                Write-Debug "      + Attempting to call SHLoadIndirectString with new resource path"
                $result = [Win32]::SHLoadIndirectString($newResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
                Write-Debug "      > SHLoadIndirectString result with new path: $result"
                if ($result -eq 0) {
                    Write-Debug "      + Successfully retrieved resource using resources.pri"
                    $resolvedString = $stringBuilder.ToString()
                    Write-Debug "      > Resolved string: $resolvedString"
                    return $resolvedString
                }
                Write-Debug "      > Failed to retrieve using resources.pri. Error code: $result"
            } else {
                Write-Debug "      > resources.pri not found at expected location"
            }
        } else {
            Write-Debug "      + Package not found"
        }

        # If still failed, try without the /resources/ folder, if it's present
        if ($resourceUri -match '^/resources/') {
            Write-Debug "         + Attempting to retrieve resource without /resources/ folder"
            $resourceUriWithoutResources = $resourceUri -replace '/resources/', '/'
            $newResourcePath = "@{" + $priPath + "?" + $resourceUriWithoutResources + "}"
            Write-Debug "         > New resource path without /resources/: $newResourcePath"
            $result = [Win32]::SHLoadIndirectString($newResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
            Write-Debug "         > SHLoadIndirectString result without /resources/: $result"
            if ($result -eq 0) {
                Write-Debug "         + Successfully retrieved resource without /resources/ folder"
                $resolvedString = $stringBuilder.ToString()
                Write-Debug "         > Resolved string: $resolvedString"
                return $resolvedString
            }
            Write-Debug "         + Failed to retrieve without /resources/ folder. Error code: $result"
        }

        # If still failed, try removing parts of the package name in the resource path one at a time
        if ($package -and (Test-Path-Safe $priPath)) {
            # Split the package name into parts
            $packageParts = $packageName.Split('.')
            for ($i = 1; $i -lt $packageParts.Count; $i++) {
                $truncatedPackageName = $packageParts[$i..($packageParts.Count - 1)] -join '.'
                Write-Debug "            + Attempting to retrieve resource with truncated package name: $truncatedPackageName"
                $truncatedPackageResourceUri = $resourceUri -replace [regex]::Escape($packageName), $truncatedPackageName
                $newResourcePath = "@{" + $priPath + "?" + $truncatedPackageResourceUri + "}"
                Write-Debug "            > Iteration $i`: $newResourcePath"
                # Execute check
                $result = [Win32]::SHLoadIndirectString($newResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
                Write-Debug "            > SHLoadIndirectString result: $result"
                if ($result -eq 0) {
                    $resolvedString = $stringBuilder.ToString()
                    Write-Debug "            > Success: Resolved string: $resolvedString"
                    return $resolvedString
                }
            }
        } else {
            Write-Debug "         > Not trying truncated package because reference is not a package, or resources .pri is not found."
        }

        Write-Warning " All attempts to retrieve resource failed for ms-resource: $ResourcePath. Error code: $result"
        return Sanitize-Unresolved-Reference -ReferenceString $ResourcePath -returnSanitizedOnFail:$returnSanitizedOnFail
    }
}

# Function: Get-FolderName
# This function retrieves the name of a shell folder given its CLSID, to be used for the shortcuts later
# It attempts to find the name by checking several potential locations in the registry.
function Get-FolderName {
    param (
        [string]$clsid,  # The CLSID of the shell folder.
        [string]$CustomLanguageFolder  # Optional: Path to a folder containing language-specific MUI files for localized string references.
    )
    $fetchNameErrorVariable = $null

    # Initialize $nameSource to track where the folder name was found (for reporting purposes in CSV later)
    $nameSource = "Unknown"

    Write-Verbose "Attempting to get folder name for CLSID: $clsid"

    # Step 1: Check the default value in the registry at HKEY_CLASSES_ROOT\CLSID\<clsid>.
    $defaultPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid"
    Write-Debug "  Checking default value at: $defaultPath"
    $defaultName = (Get-ItemProperty -Path $defaultPath -ErrorAction SilentlyContinue -ErrorVariable $fetchNameErrorVariable).'(Default)'

    # If a default name is found, check if it's a reference to a localized string.
    if ($defaultName) {
        Write-Verbose "Found default name: $defaultName"
        if ($defaultName -match '@.+,-\d+') {
            Write-Debug "   > Default name is a localized string reference"
            $resolvedName = Get-LocalizedString -StringReference $defaultName -CustomLanguageFolder $CustomLanguageFolder -returnSanitizedOnFail:$false
            if ($resolvedName) {
                $nameSource = "Localized String"
                Write-Verbose " > Resolved default name to: $resolvedName"
                return @($resolvedName, $nameSource)
            }
            else {
                Write-Verbose " > Failed to resolve default name from reference, using original value"
            }
        }
        $nameSource = "Default Value"
        return @($defaultName, $nameSource)
    }
    else {
        Write-Verbose "No default name found"
    }

    # Step 2: Check for a `TargetKnownFolder` in the registry, which points to a known folder.
    $initPropertyBagPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid\Instance\InitPropertyBag"
    Write-Debug "  Checking for TargetKnownFolder at: $initPropertyBagPath"
    $targetKnownFolder = (Get-ItemProperty -Path $initPropertyBagPath -ErrorAction SilentlyContinue).TargetKnownFolder

    # If a TargetKnownFolder is found, check its description in the registry.
    if ($targetKnownFolder) {
        Write-Debug "  Found TargetKnownFolder: $targetKnownFolder"
        $folderDescriptionsPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$targetKnownFolder"
        Write-Debug "   > Checking for folder name at: $folderDescriptionsPath"
        $folderName = (Get-ItemProperty -Path $folderDescriptionsPath -ErrorAction SilentlyContinue).Name
        if ($folderName) {
            $nameSource = "Known Folder ID"
            Write-Verbose " > Found folder name: $folderName"
            return @($folderName, $nameSource)
        }
        else {
            Write-Verbose " > No folder name found in FolderDescriptions"
        }
    }
    else {
        Write-Verbose " > No TargetKnownFolder found"
    }

    # Step 3: Check for a `LocalizedString` value in the CLSID registry key.
    $localizedStringPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid"
    Write-Verbose "Checking for LocalizedString at: $localizedStringPath"
    $localizedString = (Get-ItemProperty -Path $localizedStringPath -ErrorAction SilentlyContinue).LocalizedString

    # If a LocalizedString is found, resolve it using the Get-LocalizedString function.
    if ($localizedString) {
        Write-Debug "   > Found LocalizedString: $localizedString"
        $resolvedString = Get-LocalizedString -StringReference $localizedString -CustomLanguageFolder $CustomLanguageFolder -returnSanitizedOnFail:$false
        if ($resolvedString) {
            $nameSource = "Localized String"
            Write-Verbose " > Resolved LocalizedString to: $resolvedString"
            return @($resolvedString, $nameSource)
        }
        else {
            Write-Verbose " > Failed to resolve LocalizedString"
        }
    }
    else {
        Write-Verbose " > No LocalizedString found"
    }

    # Step 4: Check the Desktop\NameSpace registry key for the folder name.
    $namespacePath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$clsid"
    Write-Verbose "Checking Desktop\NameSpace at: $namespacePath"
    $namespaceName = (Get-ItemProperty -Path $namespacePath -ErrorAction SilentlyContinue).'(default)'

    # If a name is found here, return it.
    if ($namespaceName) {
        $nameSource = "Desktop Namespace"
        Write-Verbose " > Found name in Desktop\NameSpace: $namespaceName"
        return @($namespaceName, $nameSource)
    }
    else {
        Write-Verbose " > No name found in Desktop\NameSpace"
    }

    # Step 5: New check - Recursively search in HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer
    $explorerPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    Write-Verbose "Recursively checking Explorer registry path for CLSID: $explorerPath"

    function Search-RegistryKey {
        param (
            [string]$Path,
            [string]$Clsid
        )

        $keys = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue

        foreach ($key in $keys) {
            if ($key.PSChildName -eq $Clsid) {
                $defaultValue = (Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue).'(default)'
                if ($defaultValue -and $defaultValue -ne "") {
                    return $defaultValue
                }
            }

            $subResult = Search-RegistryKey -Path $key.PSPath -Clsid $Clsid
            if ($subResult) {
                return $subResult
            }
        }

        return $null
    }

    $explorerName = Search-RegistryKey -Path $explorerPath -Clsid $clsid
    if ($explorerName) {
        $nameSource = "Explorer Registry"
        Write-Verbose " > Found name in Explorer registry: $explorerName"
        return @($explorerName, $nameSource)
    }
    else {
        Write-Verbose " > No name found in Explorer registry"
    }

    # Step 6: If no name is found, return the CLSID itself as a last resort to be used for the shortcut
    Write-Verbose " > Returning CLSID as folder name because no other name was found"
    $nameSource = "Unknown"
    return @($clsid, $nameSource)
}

# This function creates a shortcut for a given CLSID or shell folder.
# It assigns the appropriate target path, arguments, and icon based on the CLSID information.
function Create-CLSID-Shortcut {
    param (
        [string]$clsid,         # The CLSID of the shell folder
        [string]$name,          # The name of the shortcut
        [string]$shortcutPath,  # The full path where the shortcut will be created
        [string]$pageName = ""  # Optional: the name of a specific page within the shell folder (usually used for control panels)
    )

    try {
        Write-Verbose "Creating Shortcut For: $name"
        # Create a COM object representing the WScript.Shell, which is used to create shortcuts
        $shell = New-Object -ComObject WScript.Shell

        # Create the actual shortcut at the specified path
        $shortcut = $shell.CreateShortcut($shortcutPath)
        # Set the 'target' to explorer so it opens with File Explorer. The 'arguments' part of the target will be set next and contain the 'shell:' part of the command.
        $shortcut.TargetPath = "explorer.exe"

        # If a specific page is provided, include it in the arguments, otherwise just set the shell command used to open the folder
        if ($pageName) {
            $shortcut.Arguments = "shell:::$clsid\$pageName"
        } else {
            $shortcut.Arguments = "shell:::$clsid"
        }

        # Attempt to find a custom icon for the shortcut by checking the registry
        $iconPath = (Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid\DefaultIcon" -ErrorAction SilentlyContinue).'(default)'
        if ($iconPath) {
            Write-Verbose "Setting custom icon: $iconPath"
            $shortcut.IconLocation = $iconPath
        }
        # Otherwise use the Windows default folder icon
        else {
            Write-Verbose "No custom icon found. Setting default folder icon."
            $shortcut.IconLocation = "%SystemRoot%\System32\shell32.dll,3"
        }

        $shortcut.Save()

        # Release the COM object to free up resources.
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        return $true
    }
    catch {
        Write-Error "Error creating shortcut for $name`: $($_.Exception.Message)"
        return $false
    }
}

function Check-File-For-Icon {
    param (
        [string]$filePath
    )
    try {
        $hIcon = [IconExtractor]::ExtractIcon([IntPtr]::Zero, $filePath, 0)
        if ($hIcon -ne [IntPtr]::Zero) {
            Write-Verbose "Using embedded icon from $filePath"
            $iconPath = $filePath + ",0"
            [void][IconExtractor]::DestroyIcon($hIcon)
            return $iconPath
        } else {
            Write-Verbose "No embedded icon found in $filePath"
        }
    } catch {
        Write-Verbose "Failed to extract icon from $filePath`: $_"
    }
}

function Get-TaskIcon {
    param (
        [string]$controlPanelName,
        [string]$applicationId,
        [string]$commandTarget
    )

    $iconPath = $null

    if ($controlPanelName) {
        # Try to get icon from control panel name
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\$controlPanelName"
        $iconPath = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).Icon
    }

    if (-not $iconPath -and $applicationId) {
        # Try to get icon from application ID
        Write-Debug "    > No icon found for control panel name, trying registry via application ID: $applicationId"
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\$applicationId"
        $iconPath = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).Icon

        if (-not $iconPath) {
            # If not found, try CLSID path
            Write-Debug "    > No icon found for application ID, trying registry via CLSID"
            $regPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$applicationId\DefaultIcon"
            $iconPath = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).'(default)'
        }
    }

    # If icon path still not found but there is a command, see if the command calls an exe and use that exe's icon if so. Except if it's control.exe
    if (-not $iconPath -and $commandTarget) {
        Write-Debug "    > No icon found in registry. Checking if icon can be extracted from command target: $commandTarget"
        # Extract the file name from the path if it's not just the filename
        $commandFileName = Split-Path -Path $commandTarget -Leaf
        # Check if it's an exe. Also don't use icons from a few specific executables like control.exe
        $ignoredExeFiles = @("control.exe", "rundll32.exe")
        if ($commandFileName -match '\.exe$' -and $ignoredExeFiles -notcontains $commandFileName) {
            $iconPath = Check-File-For-Icon -filePath $commandTarget
        }
        else {
            Write-Debug "    > Command target is not an exe or is part of ignored exe list - Ignoring."
        }
    }

    if ($iconPath) {
        Write-Verbose "    > Using Icon: $iconPath"
        return Fix-CommandPath $iconPath
    }

    # Default icon if none found
    Write-Verbose "    > Using Default Icon - No available icon found for $controlPanelName or $applicationId"
    return "%SystemRoot%\System32\shell32.dll,0"
}

# Fix issues with command paths spotted in at least one XML entry, where double percent signs were present at the beginning like %%windir%
function Fix-CommandPath {
    param (
        [string]$command
    )

    # Fix double % at the beginning
    if ($command -match '^\%\%') {
        $command = $command -replace '^\%\%', '%'
    }

    # Expand environment variables
    #$command = [Environment]::ExpandEnvironmentVariables($command)

    return $command
}

function Create-TaskLink-Shortcut {
    param (
        [string]$name,
        [string]$shortcutPath,
        [string]$shortcutType,
        [string]$command,
        [string]$controlPanelName,
        [string]$applicationId,
        [string[]]$keywords
    )

    $targetAndPathRegex = '(?xi)
        ^(
            (?:[a-z]:|%%?\w+%)\\
            (?:[^\\/:*?"<>|\r\n]+?\\)*?
            [^\\/:*?"<>|\r\n]+?
            \.[a-z0-9]+
        |
            [^\\/:*?"<>|\r\n]+?\.[a-z0-9]+
        )
        (?=\s|$|["])
        \s*
        (.*)
    '

    # -------- Pattern Explanation --------
    #  (?xi)                                  # Enable case-insensitive mode, and ignore whitespace mode so we can indent for readability
    #  ^(
    #    (?:[a-z]:|%\w+%)\\                   # Match drive letter with colon or environment variable, followed by a backslash. Also handles weird commands where there are 2 percent signs at the beginning
    #    (?:[^\\\/:*?"<>|\r\n]+?\\)*?         # Match directories (lazy match)
    #    [^\\\/:*?"<>|\r\n]+?                 # Match the file name
    #    \.[a-z0-9]+                          # Match any file extension
    #  |
    #    [^\\\/:*?"<>|\r\n]+?\.[a-z0-9]+      # Or just match a filename with extension, also if with arguments
    #  )
    #  (?=\s|$|["])                           # Ensure that we stop at a space, end of line, or quote
    #  \s*
    #  (.*)                                   # Capture everything after the first match (second capture group)

    try {
        Write-Verbose "Creating Task Link Shortcut For: $name"

        $shell = New-Object -ComObject WScript.Shell
        $targetPath = ''
        $arguments = ''

        if ($shortcutType -eq "url") {
            Write-Debug "  | Setting URL target path: $command"
            # For URL shortcuts
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $command
            
        } else {
            Write-Debug "  | Determining LNK target path: $command"
            # For regular shortcuts
            $shortcut = $shell.CreateShortcut($shortcutPath)

            # Parse the command
            if ($command -match $targetAndPathRegex) {
                $targetPath = Fix-CommandPath $Matches[1]
                $arguments = Fix-CommandPath $Matches[2]
                Write-Debug "    >  Matched Regex with Target: $targetPath  and Arguments: $arguments"

                # Expand variables in the arguments such as %windir%, because shortcuts don't seem to work with them in the arguments
                $arguments = [Environment]::ExpandEnvironmentVariables($arguments)
                Write-Debug "    >  Expanded Arguments: $arguments"

                $shortcut.TargetPath = $targetPath
                $shortcut.Arguments = $arguments
                
            # If no match is found, should mean it's a direct command of some other kind (no file path), with no arguments
            } else {
                $fixedCommand = Fix-CommandPath $command
                Write-Debug "    >  No match for arguments, setting direct command: $fixedCommand"
                $shortcut.TargetPath = $fixedCommand
            }

            # Add keywords only if it's a .lnk type shortcut
            # Combine keywords into a single string and set as Description
            if ($keywords -and $keywords.Count -gt 0) {
                Write-Debug "  | Adding Keywords to Description. Keyword Count: $($keywords.Count)"
                $descriptionLimit = 259 # Limit for Description field in shortcuts or else it causes some kind of buffer overflow
                $keywordString = ""
                $separator = " "

                foreach ($keyword in $keywords) {
                    $potentialNewString = if ($keywordString) { $keywordString + $separator + $keyword } else { $keyword }
                    if ($potentialNewString.Length -le $descriptionLimit) {
                        $keywordString = $potentialNewString
                    } else {
                        break
                    }
                }

                $shortcut.Description = $keywordString
            }
        }
        
        Write-Verbose "  | Retrieving Icon for Shortcut"
        $iconPath = Get-TaskIcon -controlPanelName $controlPanelName -applicationId $applicationId -commandTarget $shortcut.TargetPath

        # Only add icon at this point if it's a .lnk type shortcut, not for .url which needs to be done after
        if ($shortcutType -eq "lnk") {
            $shortcut.IconLocation = $iconPath
        }
        $shortcut.Save()
        [void] [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)

        # For .url type shortcuts, open the plaintext url file and add the IconIndex= and IconFile= lines to the end
        if ($shortcutType -eq "url") {
            if ($iconPath) {
                $iconFile, $iconIndex = $iconPath -split ','
                # Append the icon information to the file
                Add-Content -Path $shortcutPath -Value "IconFile=$iconFile"
                if ($iconIndex) {
                    Add-Content -Path $shortcutPath -Value "IconIndex=$iconIndex"
                }
            }
        }

        return $true
    } catch {
        Write-Host "Error creating shortcut for $name`: $($_.Exception.Message)"
        return $false
    }
}

# Function: Get-Shell32XMLContent
# This function extracts and returns the XML content embedded in the shell32.dll file, which contains info about sub-pages within certain shell folders and control panel menus.
# Apparently these are sometimes referred to as "Task Links"
function Get-Shell32XMLContent {
    param(
        [switch]$SaveXML,
        [string]$CustomDLL
    )

    # If a custom DLL path is provided, use it; otherwise, use the default shell32.dll path
    if ($CustomDLL) {
        Write-Verbose "Using custom DLL path: $CustomDLL"
        $dllPath = $CustomDLL
    } else {
        Write-Verbose "Using default shell32.dll path"
        $dllPath = "shell32.dll"
        # Join to system path
        $dllPath = Join-Path $env:SystemRoot "System32\$dllPath"
    }

    # Constants used for loading the shell32.dll as a data file.
    $LOAD_LIBRARY_AS_DATAFILE = 0x00000002
    $DONT_RESOLVE_DLL_REFERENCES = 0x00000001

    # Initialize an empty string to hold the XML content
    $xmlContent = ""

    # Load shell32.dll as a data file, preventing the DLL from being fully resolved as it is not necessary
    $shell32Handle = [Windows]::LoadLibraryEx($dllPath, [IntPtr]::Zero, $LOAD_LIBRARY_AS_DATAFILE -bor $DONT_RESOLVE_DLL_REFERENCES)
    if ($shell32Handle -eq [IntPtr]::Zero) {
        Write-Error "Failed to load shell32 XML content from: $dllPath"
        return $null
    }

    try {
        # Attempt to find the XML resource within shell32.dll. '21' is necessary to use here.
        $hResInfo = [Windows]::FindResource($shell32Handle, 21, "XML")
        if ($hResInfo -eq [IntPtr]::Zero) {
            Write-Error "Failed to find XML resource"
            Write-Host  "Did you move the DLL from the original location? If so you may need to directly specify the corresponding .mun file instead of the DLL." -ForegroundColor Yellow
            Write-Host  "See the comments for the DLLPath argument at the top of the script for more info." -ForegroundColor Yellow
            return $null
        }

        # Load the XML resource data.
        $hResData = [Windows]::LoadResource($shell32Handle, $hResInfo)
        if ($hResData -eq [IntPtr]::Zero) {
            Write-Error "Failed to load XML resource"
            return $null
        }

        # Lock the resource in memory to access its data.
        $pData = [Windows]::LockResource($hResData)
        if ($pData -eq [IntPtr]::Zero) {
            Write-Error "Failed to lock XML resource"
            return $null
        }

        # Get the size of the XML resource and copy it into a byte array.
        $size = [Windows]::SizeofResource($shell32Handle, $hResInfo)
        $byteArray = New-Object byte[] $size
        [System.Runtime.InteropServices.Marshal]::Copy($pData, $byteArray, 0, $size)

        # Convert the byte array to a UTF-8 string.
        $xmlContent = [System.Text.Encoding]::UTF8.GetString($byteArray)
        $xmlContent = $xmlContent -replace "`0", "" # Remove any null characters from the string, though this probably isn't necessary
    }
    finally {
        # Ensure that the loaded DLL is always freed from memory.
        [void][Windows]::FreeLibrary($shell32Handle)
    }

    # Clean and trim any extraneous whitespace from the XML content
    $xmlContent = $xmlContent.Trim()

    # Save XML content if the SaveXML switch is used
    if ($SaveXML) {
        Save-PrettyXML -xmlContent $xmlContent -outputPath $xmlContentFilePath
    }

    # Return the XML content as a string
    return $xmlContent
}

# Save the XML content from shell32.dll to a file for reference
function Save-PrettyXML {
    param (
        [string]$xmlContent,
        [string]$outputPath
    )

    try {
        # Load the XML content
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.LoadXml($xmlContent)

        # Create XmlWriterSettings for pretty-printing
        $writerSettings = New-Object System.Xml.XmlWriterSettings
        $writerSettings.Indent = $true
        $writerSettings.IndentChars = "  "
        $writerSettings.NewLineChars = "`r`n"
        $writerSettings.NewLineHandling = [System.Xml.NewLineHandling]::Replace

        # Create XmlWriter and write the document
        $writer = [System.Xml.XmlWriter]::Create($outputPath, $writerSettings)
        $xmlDoc.Save($writer)
        $writer.Close()

        Write-Verbose "XML content formatted and saved: $outputPath"
    }
    catch {
        Write-Error "Failed to format and save XML: $_"
    }
}

# Function: Get-TaskLinks
# This function parses the XML content extracted from shell32.dll to find "task links", which are basically sub-menu pages, often in the Control Panel
function Get-TaskLinks {
    param(
        [switch]$SaveXML,
        [string]$DLLPath,
        [string]$CustomLanguageFolder
    )
    $xmlContent = Get-Shell32XMLContent -SaveXML:$SaveXML -CustomDLL:$DLLPath

    if (-not $xmlContent) {
        Write-Host "Failed to retrieve XML content from shell32.dll - Skipping Collecting Task Links." -ForegroundColor Yellow 
        return $null
    }

    try {
        $xml = [xml]$xmlContent
        Write-Verbose "XML parsed successfully."
    } catch {
        Write-Error "XML data was returned but failed to parse XML content: $_"
        Write-Host "Skipping Collecting Task Links because failed to parse XML data." -ForegroundColor Yellow
        return $null
    }

    # Create a copy of the XML for resolved content
    $resolvedXml = $xml.Clone()

    $nsManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $nsManager.AddNamespace("cpl", "http://schemas.microsoft.com/windows/cpltasks/v1")
    $nsManager.AddNamespace("sh", "http://schemas.microsoft.com/windows/tasks/v1")
    $nsManager.AddNamespace("sh2", "http://schemas.microsoft.com/windows/tasks/v2")

    $tasks = @()

    $allTasks = $xml.SelectNodes("//sh:task", $nsManager)

    foreach ($task in $allTasks) {
        $taskId = $task.GetAttribute("id")
        $nameNode = $task.SelectSingleNode("sh:name", $nsManager)
        $controlPanel = $task.SelectSingleNode("sh2:controlpanel", $nsManager)
        $commandNode = $task.SelectSingleNode("sh:command", $nsManager)
        $keywordsNodes = $task.SelectNodes("sh:keywords", $nsManager)

        # Resolve name
        $name = $null
        if ($nameNode -and $nameNode.InnerText) {
            if ($nameNode.InnerText -match '@(.+),-(\d+)') {
                $name = Get-LocalizedString -StringReference $nameNode.InnerText -CustomLanguageFolder $CustomLanguageFolder -returnSanitizedOnFail:$false
                # Update resolved XML if a localized string was found
                if ($name) {
                    try {
                        $resolvedNameNode = $resolvedXml.SelectSingleNode("//sh:task[@id='$taskId']/sh:name", $nsManager)
                        if ($resolvedNameNode) {
                            $resolvedNameNode.InnerText = $name
                        }
                    } catch {
                        Write-Verbose "Failed to update resolved XML for task $taskId`: $_"
                    }
                }
            } else {
                $name = $nameNode.InnerText
            }
        }
        if ($name) {
            $name = $name.Trim()
        } elseif ($task.Name -eq "sh:task" -and $task.GetAttribute("idref")) {
            Write-Verbose "Skipping category entry: $($task.OuterXml)"
            continue
        } else {
            Write-Warning "Task $taskId is missing a name and is not a category reference. This may indicate an issue: $($task.OuterXml)"
            continue
        }

        $command = $null
        $appName = $null
        $page = $null

        $appId = $task.ParentNode.id
        if (-not $appId) {
            $appId = $task.GetAttribute("id")
        }

        if ($controlPanel) {
            $appName = $controlPanel.GetAttribute("name")
            $page = $controlPanel.GetAttribute("page")
            $command = "control.exe /name $appName"
            if ($page) {
                $command += " /page $page"
            }
        } elseif ($commandNode) {
            $command = $commandNode.InnerText
        }

        $keywords = @()
        foreach ($keywordNode in $keywordsNodes) {
            $keyword = $null
            if ($keywordNode.InnerText -match '@(.+),-(\d+)') {
                $keyword = Get-LocalizedString -StringReference $keywordNode.InnerText -CustomLanguageFolder $CustomLanguageFolder
                # Update resolved XML
                $resolvedKeywordNode = $resolvedXml.SelectSingleNode("//sh:task[@id='$taskId']/sh:keywords[text()='$($keywordNode.InnerText)']", $nsManager)
                if ($resolvedKeywordNode -and $keyword) {
                    $resolvedKeywordNode.InnerText = $keyword
                }
            } else {
                $keyword = $keywordNode.InnerText
            }
            if ($keyword) {
                $splitKeywords = $keyword.Split(';', [StringSplitOptions]::RemoveEmptyEntries)
                foreach ($splitKeyword in $splitKeywords) {
                    if ($splitKeyword) {
                        $keywords += $splitKeyword.Trim()
                    }
                }
            }
        }

        # If no app name, look it up via CLSID in the registry
        if (-not $appName) {
            $appName = (Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\$appId" -ErrorAction SilentlyContinue)."System.ApplicationName"
        }
        # If still no app name, check if any other task has the same app ID with a name, and if so use that, but only the first instance
        if (-not $appName) {
            $otherTask = $tasks | Where-Object { $_.ApplicationId -eq $appId -and $_.ApplicationName } | Select-Object -First 1
            if ($otherTask) {
                $appName = $otherTask.ApplicationName
            }
        }

        if ($name -and ($command -or $appName)) {
            # Determine the ControlPanelName value before creating the object
            if ($controlPanel) {
                $controlPanelName = $controlPanel.GetAttribute("name")
            } else {
                $controlPanelName = $null
            }

            # Now create the $newTask object using the pre-determined $controlPanelName
            $newTask = [PSCustomObject]@{
                TaskId = $taskId
                ApplicationId = $appId
                Name = $name
                ApplicationName = $appName
                Page = $page
                Command = $command
                Keywords = $keywords
                ControlPanelName = $controlPanelName
            }

            # Check if a task with the same name and command already exists
            $isDuplicate = $tasks | Where-Object { $_.Name -eq $newTask.Name -and $_.Command -eq $newTask.Command }

            if (-not $isDuplicate) {
                $tasks += $newTask
            } else {
                Write-Verbose "Skipping duplicate task: $($newTask.Name)"
            }
        }
    }

    # Store the resolved XML content in a new variable
    $resolvedXmlContent = $resolvedXml.OuterXml

    # Save XML content if the SaveXML switch is used
    if ($SaveXML) {
        Save-PrettyXML -xmlContent $resolvedXmlContent -outputPath $resolvedXmlContentFilePath
    }

    return $tasks
}

# Function: Create-NamedShortcut
# This function creates a shortcut for a named special folder.
# The shortcut points directly to the folder using its name (e.g., "Documents", "Pictures").
function Create-NamedShortcut {
    param (
        [string]$name,          # The name of the special folder.
        [string]$shortcutPath,  # The full path where the shortcut will be created.
        [string]$iconPath       # The path to the folder's custom icon (if any).
    )

    try {
        Write-Verbose "Creating named shortcut for $name"
        # Create a COM object representing the WScript.Shell, which is used to create shortcuts.
        $shell = New-Object -ComObject WScript.Shell

        # Create the actual shortcut at the specified path.
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "explorer.exe"  # The shortcut will open in Windows Explorer.
        $shortcut.Arguments = "shell:$name"  # Set the shortcut to open the specified folder by name. This will also be in the target path box for the shortcut.

        # Set the custom icon if one is provided in the registry
        if ($iconPath) {
            Write-Verbose "Setting custom icon: $iconPath"
            $shortcut.IconLocation = $iconPath
        }
        else {
            Write-Verbose "Setting default folder icon"
            $shortcut.IconLocation = "%SystemRoot%\System32\shell32.dll,3"  # Default folder icon.
        }

        # Save the shortcut.
        $shortcut.Save()

        # Release the COM object to free up resources.
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        return $true
    }
    catch {
        Write-Host "创建 $name` 快捷方式失败: $($_.Exception.Message)"
        return $false
    }
}

# Function: Create-CLSIDCsvFile
# This function generates a CSV file containing details about all processed CLSID shell folders.
function Create-CLSIDCsvFile {
    param (
        [string]$outputPath,  # The full path where the CSV file will be saved.
        [array]$clsidData     # An array of objects containing CLSID data.
    )

    # Initialize the CSV content with headers.
    $csvContent = "CLSID,ExplorerCommand,Name,NameSource,CustomIcon`n"

    # Loop through each CLSID data object and append its details to the CSV content.
    foreach ($item in $clsidData) {
        $explorerCommand = "explorer shell:::$($item.CLSID)"  # The command to open the shell folder.
        $iconPath = if ($item.IconPath) {
            "`"$($item.IconPath -replace '"', '""')`""  # Escape double quotes in the icon path.
        } else {
            "None"
        }

        # Escape any double quotes in the name.
        $escapedName = $item.Name -replace '"', '""'

        # Convert the sub-items array to a string, separating items with a pipe character.
        #$subItemsString = ($item.SubItems | ForEach-Object { "$($_.Name):$($_.Page)" }) -join '|'

        # Append the CLSID details to the CSV content.
        $csvContent += "$($item.CLSID),`"$explorerCommand`",`"$escapedName`",$($item.NameSource),$iconPath`n"
    }

    # Write the CSV content to the specified output file.
    $csvContent | Out-File -FilePath $outputPath -Encoding utf8
}

# Function: Create-NamedFoldersCsvFile
# This function generates a CSV file containing details about all processed named special folders.
function Create-NamedFoldersCsvFile {
    param (
        [string]$outputPath  # The full path where the CSV file will be saved.
    )

    # Initialize the CSV content with headers.
    $csvContent = "Name,ExplorerCommand,RelativePath,ParentFolder`n"

    # Retrieve all named special folders from the registry.
    $namedFolders = Get-ChildItem -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions"

    # Loop through each named folder and append its details to the CSV content.
    foreach ($folder in $namedFolders) {
        $folderProperties = Get-ItemProperty -Path $folder.PSPath
        $name = $folderProperties.Name  # Extract the name of the folder.
        if ($name) {
            $explorerCommand = "explorer shell:$name"  # The command to open the folder.
            $relativePath = $folderProperties.RelativePath -replace ',', '","'  # Escape commas in the relative path.
            $parentFolderGuid = $folderProperties.ParentFolder  # Extract the parent folder GUID (if any).
            $parentFolderName = "None"  # Default value if there is no parent folder.
            if ($parentFolderGuid) {
                # If a parent folder GUID is found, retrieve the name of the parent folder.
                $parentFolderPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\$parentFolderGuid"
                $parentFolderName = (Get-ItemProperty -Path $parentFolderPath -ErrorAction SilentlyContinue).Name
            }

            # Append the named folder details to the CSV content.
            $csvContent += "`"$name`",`"$explorerCommand`",`"$relativePath`",`"$parentFolderName`"`n"
        }
    }

    # Write the CSV content to the specified output file.
    $csvContent | Out-File -FilePath $outputPath -Encoding utf8
}

# Function: Create-TaskLinksCsvFile
# This function generates a CSV file containing details about all processed 'task links' aka sub-pages.
function Create-TaskLinksCsvFile {
    param (
        [string]$outputPath,
        [array]$taskLinksData
    )

    $csvContent = "XMLTaskId,ApplicationId,ApplicationName,Name,Page,Command,Keywords`n"

    foreach ($item in $taskLinksData) {
        $taskId = $item.TaskId -replace '"', '""'
        $applicationId = $item.ApplicationId -replace '"', '""'
        $applicationName = $item.ApplicationName -replace '"', '""'
        $name = $item.Name -replace '"', '""'
        $page = $item.Page -replace '"', '""'
        $command = $item.Command -replace '"', '""'
        $keywords = ($item.Keywords -join ';') -replace '"', '""'

        $csvContent += "`"$taskId`",`"$applicationId`",`"$applicationName`",`"$name`",`"$page`",`"$command`",`"$keywords`"`n"
    }

    $csvContent | Out-File -FilePath $outputPath -Encoding utf8
}

function Create-MSSettingsCsvFile {
    param (
        [string]$outputPath,
        [array]$msSettingsList
    )

    $csvContent = "Setting Name,Full Setting Command`n"

    foreach ($fullLink in $msSettingsList) {
        # Split on the first colon to separate the command from the name
        $fullLinkParts = $fullLink -split ":", 2
        $name = $fullLinkParts[1].Trim()

        $csvContent += "`"$name`",`"$fullLink`"`n"
    }

    $csvContent | Out-File -FilePath $outputPath -Encoding utf8
}

# Take the app name like Microsoft.NetworkAndSharingCenter and prepare it to be displayed in the shortcut name like "Network and Sharing Center - Whatever Task name"
function Prettify-App-Name {
    param(
        [string]$AppName,
        [string]$TaskName
    )

    # List of words to rejoin if split
    $wordsToRejoin = @(
        "Bit Locker",
        "Side Show",
        "Auto Play"
        # Add more words as needed
    )

    # Remove "Microsoft." prefix if present
    $AppName = $AppName -replace '^Microsoft\.', ''

    # Split camelCase into separate words, handling consecutive uppercase letters
    $AppName = $AppName -creplace '(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|\b(?=[A-Z]{2,}\b)', ' '

    # Rejoin specific words
    foreach ($word in $wordsToRejoin) {
        $AppName = $AppName -replace $word, $word.Replace(' ', '')
    }

    # Combine AppName and TaskName
    $PrettyName = "$AppName - $TaskName"

    # Sanitize the name to remove invalid characters for file names
    $PrettyName = $PrettyName -replace '[\\/:*?"<>|]', '_'

    return $PrettyName
}

# Function to parse the ms-settings XML file and extract relevant data
function Get-AllSettings-Data {
    param (
        [string]$xmlFilePath,
        [switch]$SaveXML
    )

    if (-not (Test-Path-Safe $xmlFilePath)) {
        Write-Error "未找到所有系统 XML 文件: $xmlFilePath"
        return $null
    }

    try {
        Write-Verbose "正在解析 所有系统设置 XML : $xmlFilePath"
        [xml]$xmlContent = Get-Content $xmlFilePath
        $searchableContentData = $xmlContent.PCSettings.SearchableContent
        $settingsData = @()
    } catch {
        Write-Error "尝试检索和分析所有系统设置 XML 时出错。必须跳过收集深度链接。"
        Write-Error ": $_"
        return $null
    }

    $itemIndex = -1 # Start at -1 so that the first item is 0. Incrementing at start of loop in case of errors

    foreach ($content in $searchableContentData) {
        $itemIndex++
        # Try acquiring the data before creating object. If they fail then assign default values if not necessary, or be skipped if necessary.
        $entryName = $null
        $deepLink = $null
        $description = $null
        $highKeywords = $null
        $iconPath = $null

        # "FileName" property, but it's not actually a file name. It's more like the name of the setting or page, such as "AAA_BatterySaver_LandingPage_SettingsOverview"
        try {
            $entryName = $content.Filename
        }
        catch {
            Write-Warning "Failed to get 'FileName' property for DeepLink entry of index $itemIndex. Attempting to continue."
            $entryName = "[Unresolved Name]"
        }

        # If fail to get deep link property (the command), then skip because that's the main thing we need. Doing this after FileName to hopefully have more data for error message
        try { 
            $deepLink = $content.ApplicationInformation.DeepLink
        } catch {
            Write-Warning "Failed to get DeepLink for $($content.Filename) (index $itemIndex). Skipping."
            continue
        }
        
        # The 'Description' is the friendly name of the setting/page/menu
        try {
            $description = Get-LocalizedString $content.SettingInformation.Description -returnSanitizedOnFail:$true
            # Update the XML content with resolved strings to be saved to XML file if set
            $content.SettingInformation.Description = $description
        } catch {
            $description = "[Unresolved Description]"
        }
        if (-not $description) {
            $description = "[Unresolved Description]"
        }

        # Resolve HighKeywords if it exists, then update XML content
        try {
            if ($content.SettingInformation.HighKeywords) {
                $highKeywords = Get-LocalizedString $content.SettingInformation.HighKeywords -returnSanitizedOnFail:$false
                # Ensure it's a string if it's an array
                if ($highKeywords -is [array]) {
                    $highKeywords = $highKeywords -join "; "
                }
            }
            if ($highKeywords) {
                $content.SettingInformation.HighKeywords = $highKeywords
            }
        } catch {
            Write-Debug "Failed to get 'HighKeywords' property for DeepLink entry '$entryName' of index $itemIndex. These aren't used so this isn't a problem, continuing anyway."
            $highKeywords = ""
        }
        if (-not $highKeywords) {
            $highKeywords = ""
        }

        # Get IconPath if it exists
        try {
            if ($content.ApplicationInformation.Icon) {
                $iconPath = $content.ApplicationInformation.Icon
            }
        } catch {
            Write-Debug "Failed to get 'Icon' property for DeepLink entry '$entryName' of index $itemIndex. These aren't used so this isn't a problem, continuing anyway."
            $iconPath = ""
        }    

        # Create object with all data to go into array of $settingsData
        $settingInfo = @{
            Name         = $entryName
            Description  = $description
            HighKeywords = $highKeywords
            DeepLink     = $deepLink
            IconPath     = $iconPath
        }

        # Add all data and handle it elsewhere
        $settingsData += $settingInfo
    }

    if ($settingsData.Count -eq 0) {
        Write-Error "No Deep Link data was collected, something must have gone wrong Refer to any other prior errors. Skipping Deep Link creation."
        return $null
    }

    # Save the resolved XML to the main output folder if the SaveXML switch is used
    if ($SaveXML) {
        try {
            $xmlContent.Save($resolvedSettingsXmlContentFilePath)
            Write-Verbose "Resolved XML saved to: $resolvedSettingsXmlContentFilePath"
        } catch {
            Write-Error "Failed to save resolved XML content: $_"
        }
    }
    return $settingsData
}

# Function to extract ms-settings links from the SystemSettings.dll file which has the ms-settings links embedded in it
function Get-MS-SettingsFrom-SystemSettingsDLL {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DllPath
    )

    if (-not (Test-Path-Safe $DllPath)) {
        Write-Error "Could not find file path to search for for ms-settings: $DllPath"
        return $null
    }

    try {
        $content = [System.IO.File]::ReadAllText($DllPath, [System.Text.Encoding]::Unicode)
        $results = New-Object System.Collections.Generic.HashSet[string]

        $matchesList = [regex]::Matches($content, 'ms-settings:[a-z-]+')
        foreach ($match in $matchesList) {
            [void]$results.Add($match.Value)
        }
    } catch {
        Write-Error "Failed to extract ms-settings links from SystemSettings.dll: $_"
        return $null
    }
    
    if ($results.Count -eq 0) {
        Write-Error "Unknown Problem: No ms-settings links were found in the SystemSettings.dll file. Something must have gone wrong."
        return $null
    }
    Write-Host "Unique MS-Settings Matches Found: $($results.Count)"
    return $results | Sort-Object
}

# Function to create ms-settings shortcuts
function Create-MSSettings-Shortcut {
    param (
        [string]$fullName,
        [string]$shortcutPath
    )

    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $fullName

        # Use a default icon of settings gear for each ms-settings shortcut
        $shortcut.IconLocation = "%SystemRoot%\System32\shell32.dll,-16826"

        $shortcut.Save()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        return $true
    }
    catch {
        Write-Host "Error creating shortcut for $name`: $($_.Exception.Message)"
        return $false
    }
}

function Create-Deep-Link-Shortcut {
    param (
        [object]$settingArray
    )
    # settingsArray has string properties: Name, Description, HighKeywords, DeepLink, IconPath

    $rawTarget = $settingArray.DeepLink

    # If there's a description, use that as the name
    if ($settingArray.Description) {
        $name = $settingArray.Description
    } else {
        # Sanitize the name and use that
        $name = $rawTarget
    }

    $targetAndPathRegex = '(?xi)
        ^(
            (?:[a-z]:|%%?\w+%)\\
            (?:[^\\/:*?"<>|\r\n]+?\\)*?
            [^\\/:*?"<>|\r\n]+?
            \.[a-z0-9]+
        |
            [^\\/:*?"<>|\r\n]+?\.[a-z0-9]+
        )
        (?=\s|$|["])
        \s*
        (.*)
    '

    $target = ""
    $targetArgs = ""

    Write-Debug "Creating Deep Link shortcut for $name, with deep link rawTarget $rawTarget"
    
    # Method 1 - Determine type of link/command. First check if it matches application ID format like "Microsoft.Recovery"
    if ($rawTarget -match '^Microsoft\.[a-zA-Z]+$') {
        Write-Debug "  > Found format with Method 1 - Application ID"
        $shortcutType = "app"
        $target = "control.exe"
        $targetArgs = "/name $rawTarget"
        $fullCommand = "control.exe /name $rawTarget"
        Write-Debug "    >  Target: $target   |    Args: $targetArgs"
    # Method 2 - Check if it's an application name but with a backslash and therefore has a page like Microsoft.Mouse\2 or Microsoft.PowerOptions\pagePlanSettings
    } elseif ($rawTarget -match '^Microsoft\.[a-zA-Z]+\\.+$') {
        Write-Debug "  > Found format with Method 2 - Application ID with Page"
        $shortcutType = "appPage"
        $target = "control.exe"
        $targetArgs = "/name $($rawTarget.Split('\')[0]) /page $($rawTarget.Split('\')[1])"
        $fullCommand = "$target $targetArgs"
        Write-Debug "    >  Target: $target   |    Args: $targetArgs"
    # Method 3 - Check if it's a shell:::{CLSID} link. It may have stuff after it as part of the link
    } elseif ($rawTarget -match '^shell:::{[a-zA-Z0-9-]+}') {
        Write-Debug "  > Found format with Method 3 - CLSID"
        $shortcutType = "clsid"
        $fullCommand = "explorer $rawTarget"
        Write-Debug "    >  Full Command: $fullCommand"
    # Method 4 - If it starts with %windir% or %%windir% assume it's a full path to an executable or URL with or without arguments like %windir%\something
    } elseif ($rawTarget -match $targetAndPathRegex) {
        Write-Debug "  > Found format with Method 4 - Path Command"
        $shortcutType = "pathcommand"
        $fullCommand = Fix-CommandPath $rawTarget
        $target = Fix-CommandPath $Matches[1]
        $targetArgs = Fix-CommandPath $Matches[2]
        Write-Debug "    >  Full Fixed Command: $fullCommand   |    Target: $target   |    Args: $targetArgs"
    # Method 5 - If it's just letters and numbers and the <Filename> property starts with "Defender_" then it is a Windows Defender setting whcih is apparently a special case in this file
    } elseif ($rawTarget -match '^[a-zA-Z0-9]+$' -and $settingArray.Name -match '^Defender_') {
        Write-Debug "  > Found format with Method 5 - Windows Defender"
        $shortcutType = "windowsdefender"
        $fullCommand = "windowsdefender://$rawTarget"
        $target = "windowsdefender://$rawTarget"
        # Prepend "Windows Defender" to the name
        $name = "Windows Defender - $name"
        Write-Debug "    >  Full Command: $fullCommand"
    # Method 6 - If it's just letters deal with it later, do nothing
    } elseif ($rawTarget -match '^[a-zA-Z]+$') {
        Write-Debug "  > Found format with Method 6 - Letters only"
        $shortcutType = "unknown"
    # Assume it's a full path to an executable or URL with or without arguments like %windir%\something
    } else {
        Write-Debug "  >  No other format found, assuming it's a path to an exe or URL. Will try to split on space."
        $shortcutType = "assumedPath"
        # Try to split on the first space, set args to the 2nd match, otherwise assume no args
        if ($rawTarget -match '^(\S+)\s*(.*)$') {
            $target = $Matches[1]
            $targetArgs = $Matches[2]
            Write-Debug "    >  Split on space: Target: $target   |    Args: $targetArgs"
        } else {
            $target = $rawTarget
            Write-Debug "    >  No space found, assuming no args: Target: $target"
        }
    }

    # Expand variables in the arguments such as %windir%, because shortcuts don't seem to work with them in the arguments
    # Strangely the same commands do work when put in the run box, so more investigation might be needed
    if ($targetArgs) {
        $targetArgs = [Environment]::ExpandEnvironmentVariables($targetArgs)
    }

    # Sanitize the name to make it a valid filename
    $sanitizedName = $name -replace '[\\/:*?"<>|]', '_'
    $shortcutPath = Join-Path $deepLinksOutputFolder "$sanitizedName.lnk"
    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)

        # Set the target path and arguments based on the type of link
        if ($shortcutType -eq "app" -or $shortcutType -eq "appPage") {
            $shortcut.TargetPath = $target
            $shortcut.Arguments = $targetArgs
        } elseif ($shortcutType -eq "clsid") {
            $shortcut.TargetPath = "explorer.exe"
            $shortcut.Arguments = $rawTarget
        } elseif ($shortcutType -eq "pathcommand") {
            $shortcut.TargetPath = $target
            $shortcut.Arguments = $targetArgs
        } elseif ($shortcutType -eq "assumedPath") {
            $shortcut.TargetPath = $target
        } elseif ($shortcutType -eq "windowsdefender") {
            $shortcut.TargetPath = $target
        } else {
            $shortcut.TargetPath = $rawTarget
        }

        # If there's an icon property try using that
        if ($settingArray.IconPath) {
            $shortcut.IconLocation = $settingArray.IconPath
        } else {
            # Use a default icon of settings gear for each ms-settings shortcut
            $shortcut.IconLocation = "%SystemRoot%\System32\shell32.dll,-16826"
        }

        $shortcut.Save()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null

        #Add info about the full command and icon path to the settings array and return it updated
        $settingArray.FullCommand = $fullCommand
        $settingArray.ShortcutPath = $shortcutPath
        return $settingArray
    } catch {
        Write-Error "Error creating shortcut for $name`: $($_.Exception.Message)"
        return $false
    }
}

function Create-Deep-Link-CSVFile {
    param (
        [string]$outputPath,
        [array]$deepLinksDataArray
    )

    $csvContent = "Description,Deep Link,Full Command,IconPath`n"

    foreach ($item in $deepLinksDataArray) {
        $description = $item.Description -replace '"', '""'
        $deepLink = $item.DeepLink -replace '"', '""'
        $fullCommand = $item.FullCommand -replace '"', '""'
        $iconPath = if ($item.IconPath) {
            "`"$($item.IconPath -replace '"', '""')`""  # Escape double quotes in the icon path.
        } else {
            "None"
        }

        $csvContent += "`"$description`",`"$deepLink`",`"$fullCommand`",$iconPath`n"
    }

    $csvContent | Out-File -FilePath $outputPath -Encoding utf8
}

# Currently unused in favor of Get-AppDetails-From-AppxManifest
function Get-AppDetails-From-Registry {
    param(
        [Array]$urlProtocolData
    )

    # Make a deep copy of the input data
    $localUrlProtocolData = Make-DeepCopy $urlProtocolData

    # Gather protocol info from other registry locations to add to the data
    # For installed package Protocols, look in HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages
    # Search app subkeys for Capabilities > URLAssociations. Where entry besides (Default) will be named as the protocol, and will have value of the app class id

    # For debugging
    #$originalProtocolData = Make-DeepCopy $localUrlProtocolData
    #$regPackageDataOnlyArray = @() # Stores only data from packages, mostly for debugging

    $packagesRegPath = 'Registry::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages'
    # Get subkeys of the Package key but only where the URLAssociations key exists at Package/WhateverPackage/AppName/Capabilities/URLAssociations and the key has a value besides (Default)
    Get-ChildItem -Path $packagesRegPath -ErrorAction SilentlyContinue | ForEach-Object {
        $packagePath = $_.PSPath
        $packageFullName = $_.PSChildName
        $packageApps = Get-ChildItem -Path $packagePath
        # Get subkeys of the package
        foreach ($app in $packageApps) {
            # Truncate until the _ to get the package name
            $packageName = $_.PSChildName -replace '_.*$'
            $packageAppKeyName = $app.PSChildName
            $capabilitiesPath = Join-Path $app.PSPath "Capabilities"
            $urlAssociationsPath = Join-Path $capabilitiesPath "URLAssociations"

            if (Test-Path $urlAssociationsPath) {
                $urlAssociations = Get-ItemProperty -Path $urlAssociationsPath -ErrorAction SilentlyContinue

                # Get the properties but exclude the built in PSObject properties, leaving only the subkeys that are the protocol names
                $urlAssociations.PSObject.Properties | Where-Object { $_.Name -notin @("PSPath", "PSParentPath", "PSChildName", "PSDrive", "PSProvider") } | ForEach-Object {
                    $protocol = $_.Name
                    #$appClassId = $_.Value

                    # Get the ApplicationName and ApplicationDescription values from Capabilities key value
                    $packageLocalizedAppName = Get-ItemProperty -Path $capabilitiesPath -Name "ApplicationName" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ApplicationName
                    $packageLocalizedAppDescription = Get-ItemProperty -Path $capabilitiesPath -Name "ApplicationDescription" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ApplicationDescription

                    # Get the PackageRootFolder value
                    $packageRootFolder = Get-ItemProperty -Path $packagePath -Name "PackageRootFolder" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty PackageRootFolder
                    # Append AppxManifest.xml to the path to get the full path to the manifest
                    $appxManifestPath = Join-Path $packageRootFolder "AppxManifest.xml"

                    # If a displayname exists and starts with ms-resource: or @ then it needs to be resolved. It is an entry in the root of the packages path in the registry key
                    $packageLocalizedDisplayName = Get-ItemProperty -Path $packagePath -Name "DisplayName" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName
                    if ($packageLocalizedDisplayName -match '^ms-resource:|^@') {
                        $packageLocalizedDisplayName = Get-LocalizedString -StringReference $packageLocalizedDisplayName -AppxManifestPath $appxManifestPath
                    }

                    # If the values start with @{ they are a resource and need to be resolved. If they fail just set them blank
                    if ($packageLocalizedAppName -match '^@{') {
                        try{
                            $packageLocalizedAppName = Get-LocalizedString -StringReference $packageLocalizedAppName
                        } catch {
                            $packageLocalizedAppName = ""
                        }
                    }
                    if ($packageLocalizedAppDescription -match '^@{') {
                        try {
                            $packageLocalizedAppDescription = Get-LocalizedString -StringReference $packageLocalizedAppDescription
                        } catch {
                            $packageLocalizedAppDescription = ""
                        }
                    }

                    # Check if the protocol is already in the list, if so merge the data, otherwise create a new object to add to $localUrlProtocolData
                    if ($localUrlProtocolData.Protocol -contains $protocol) {
                        # Find the existing object and update the PackageName and ClassID properties
                        $existingProtocol = $localUrlProtocolData | Where-Object { $_.Protocol -eq $protocol }
                        $existingProtocol.PackageName = $packageName
                        $existingProtocol.PackageFullName = $packageFullName
                        $existingProtocol.PackageAppName = $packageLocalizedAppName
                        $existingProtocol.PackageAppDescription = $packageLocalizedAppDescription
                        #$existingProtocol.ClassID = $appClassId # Not needed at the moment
                        $existingProtocol.PackageAppKeyName = $packageAppKeyName

                         # If the package name starts with Microsoft* or Windows then it's a Microsoft package, update the IsMicrosoft property
                        if ($packageName -match '^Microsoft|^Windows') {
                            $existingProtocol.IsMicrosoft = $true
                        }
                    } else {
                        # Determine if microsoft by checking protocol name
                        $isMicrosoft = $false
                        if ($protocol -match '^ms-|^microsoft', 'IgnoreCase') {
                            $isMicrosoft = $true
                        }
                        # If the package name starts with Microsoft* or Windows then it's a Microsoft package
                        if ($packageName -match '^Microsoft|^Windows') {
                            $isMicrosoft = $true
                        }
                        $packageProtocolData = $null
                        # Create a new object to store the URL protocol data
                        $packageProtocolData = [PSCustomObject]@{
                            Protocol = $protocol
                            Name = $packageLocalizedAppName
                            Command = ""
                            IconPath = ""
                            PackageName = $packageName
                            PackageFullName = $packageFullName
                            PackageAppKeyName = $packageAppKeyName
                            PackageAppName = $packageLocalizedAppName
                            PackageAppDescription = $packageLocalizedAppDescription
                            #ClassID = $appClassId
                            IsMicrosoft = $isMicrosoft
                        }
                        #$regPackageDataOnlyArray += $packageProtocolData # For debugging
                        $localUrlProtocolData += $packageProtocolData
                    }
                }
            }
        }
    }

    return $localUrlProtocolData
}

function Get-AppDetails-From-AppxManifest {
    param(
        [string]$CustomLanguageFolder,
        [switch]$OnlyMicrosoftApps,
        [switch]$GetExtraData
    )

    $urlProtocolData = @()

    # Will also want to store data relative to the app to use for crawling app files for URL links
    $associatedProtocolsPerApp = @()


    foreach ($appx in Get-AppxPackage) {
        #$isMicrosoft = $appx.Publisher -match "^CN=Microsoft Corporation," -or $protocol -match "^ms-|^microsoft" -or $appx.PublisherId -eq "8wekyb3d8bbwe" -or $appx.PublisherId -eq "cw5n1h2txyewy"
        $isMicrosoft = ($appx.PublisherId -eq "8wekyb3d8bbwe") -or ($appx.PublisherId -eq "cw5n1h2txyewy")

        # Just store data for all apps for now. Create object to put into $associatedProtocolsPerApp
        $appInfo = [PSCustomObject]@{
            PackageFullName = $appx.PackageFullName
            PackageName = $appx.Name
            InstallLocation = $appx.InstallLocation
            Publisher = $appx.Publisher
            PublisherId = $appx.PublisherId
            IsMicrosoft = $isMicrosoft
            Protocols = @()
        }

        if ($OnlyMicrosoftApps -and -not $isMicrosoft) {
            continue
        }

        $location = $appx.InstallLocation
        $manifestPath = "$location\AppxManifest.xml"
        if ($null -ne $location  -and (Test-Path-Safe $manifestPath)) {
            [xml]$xml = Get-Content $manifestPath
            $ns = New-Object Xml.XmlNamespaceManager $xml.NameTable
            $ns.AddNamespace("main", "http://schemas.microsoft.com/appx/manifest/foundation/windows10")
            $ns.AddNamespace("uap", "http://schemas.microsoft.com/appx/manifest/uap/windows10")
            $ns.AddNamespace("uap2", "http://schemas.microsoft.com/appx/manifest/uap/windows10/2")
            $ns.AddNamespace("uap3", "http://schemas.microsoft.com/appx/manifest/uap/windows10/3")
            $ns.AddNamespace("uap4", "http://schemas.microsoft.com/appx/manifest/uap/windows10/4")
            $ns.AddNamespace("uap5", "http://schemas.microsoft.com/appx/manifest/uap/windows10/5")

            # Create an array of namespace prefixes to check
            $uapNamespaces = @("uap", "uap2", "uap3", "uap4", "uap5")

            # Build the XPath query dynamically
            $xpathQuery = ($uapNamespaces | ForEach-Object {
                "//$_`:Extension[@Category = 'windows.protocol']/$_`:Protocol | " +
                "//uap:Extension[@Category = 'windows.protocol']/$_`:Protocol"
            }) -join ' | '

            $protocolElements = $xml.SelectNodes($xpathQuery, $ns)

            foreach ($protocolElement in $protocolElements) {
                $protocol = $protocolElement.GetAttribute("Name")
                $appElement = $protocolElement.SelectSingleNode("ancestor::main:Application", $ns)
                $appId = $appElement.GetAttribute("Id")

                $displayNameElement = $appElement.SelectSingleNode(".//uap:VisualElements/@DisplayName", $ns)
                if ($displayNameElement) {
                    $displayName = $displayNameElement.Value
                } else {
                    $displayName = ""
                }

                $descriptionElement = $appElement.SelectSingleNode(".//uap:VisualElements/@Description", $ns)
                if ($descriptionElement) {
                    $description = $descriptionElement.Value
                } else {
                    $description = ""
                }

                # Get other values
                $executable = $appElement.GetAttribute("Executable")
                $command = if ($executable) { Join-Path $location $executable } else { "" }
                $PackageName = $appx.Name

                # See if it is necessary to get localized string for the various values if it starts with "ms-resource:"
                if ($displayName -match '^ms-resource:' -and $GetExtraData) {
                    $displayName = Get-LocalizedString -StringReference $displayName -AppxManifestPath $manifestPath -CustomLanguageFolder $CustomLanguageFolder -returnSanitizedOnFail
                }
                if ($description -match '^ms-resource:' -and $GetExtraData) {
                    $description = Get-LocalizedString -StringReference $description -AppxManifestPath $manifestPath -CustomLanguageFolder $CustomLanguageFolder -returnSanitizedOnFail
                }
                if ($PackageName -match '^ms-resource:' -and $GetExtraData) {
                    $PackageName = Get-LocalizedString -StringReference $PackageName -AppxManifestPath $manifestPath -CustomLanguageFolder $CustomLanguageFolder -returnSanitizedOnFail
                }

                # Add protocol data to the appInfo object
                $appInfo.Protocols += $protocol

                $protocolData = [PSCustomObject]@{
                    Protocol = $protocol
                    Name = $displayName
                    Command = $command
                    IconPath = ""  # AppxManifest doesn't typically include icon paths
                    DerivedIcon = ""
                    PackageName = $PackageName
                    PackageFullName = $appx.PackageFullName
                    PackageAppKeyName = $appId
                    PackageAppName = $displayName
                    PackageAppDescription = $description
                    #ClassID = ""  # AppxManifest doesn't include ClassID
                    IsMicrosoft = $isMicrosoft
                    #ManifestPath = $manifestPath
                    InstallLocation = $location
                }

                $urlProtocolData += $protocolData

            }
        }
        $associatedProtocolsPerApp+= $appInfo
    }
    # Sort $urlProtocolData by protocol
    $urlProtocolData = $urlProtocolData | Sort-Object -Property Protocol
    # Sort $associatedProtocolsPerApp by PackageName
    $associatedProtocolsPerApp = $associatedProtocolsPerApp | Sort-Object -Property PackageName

    # Return both arrays
    return @{
        UrlProtocolData = $urlProtocolData
        AssociatedProtocolsPerApp = $associatedProtocolsPerApp
    }
}

# Deep copy function using serialization and deserialization
function Make-DeepCopy {
    param (
        [Parameter(Mandatory=$true)]
        $object
    )
    # Serialize the object to an XML string
    $serializedData = [System.Management.Automation.PSSerializer]::Serialize($object)
    # Deserialize the XML string back to a new object (deep copy)
    $deepCopiedObject = [System.Management.Automation.PSSerializer]::Deserialize($serializedData)
    return $deepCopiedObject
}


function Get-And-Process-URL-Protocols {
    param(
        [string]$CustomLanguageFolder,
        [switch]$OnlyMicrosoftApps,
        [string[]]$permanentProtocolsIgnore,
        [switch]$GetExtraData
    )
    # Create object to store data. Will want to store multiple properties for each URL protocol
    $urlProtocols = @()
    $urlProtocolDataOriginal = @()

    Write-Verbose "Gathering URL Protocol data from the registry"
    $urlProtocols = @{}

    # Function store registry data structure for each protocol in an object so we don't need to make a bunch of registry calls later
    function Get-RegistryKeyData {
        param (
            [Microsoft.Win32.RegistryKey]$Key
        )
        $data = @{
            '(Default)' = $Key.GetValue('')
            Values = @{}
            SubKeys = @{}
        }
        foreach ($valueName in $Key.GetValueNames()) {
            if ($valueName -ne '') {
                $data.Values[$valueName] = $Key.GetValue($valueName)
            }
        }
        foreach ($subKeyName in $Key.GetSubKeyNames()) {
            $subKey = $Key.OpenSubKey($subKeyName)
            $data.SubKeys[$subKeyName] = Get-RegistryKeyData -Key $subKey
            $subKey.Close()
        }
        return $data
    }

    # Get all subkeys of HKEY_CLASSES_ROOT and filter out the URL protocols, and put them in a hashtable called $urlProtocols
    Get-ChildItem -Path 'Registry::HKEY_CLASSES_ROOT' -ErrorAction SilentlyContinue |
        Where-Object {
            $_.GetValue('(Default)') -match '^URL:' -or $null -ne $_.GetValue('URL Protocol')
        } | ForEach-Object {
            $urlProtocols[$_.PSChildName] = Get-RegistryKeyData -Key $_.OpenSubKey('')
        }

    foreach ($protocol in $urlProtocols.Keys) {
        Write-Verbose "Processing URL Protocol: $protocol"

        $protocolData = $urlProtocols[$protocol]
        $protocolName = $protocolData['(Default)']

        # If the protocol name is in the format "URL:WhateverName", extract the "WhateverName" part
        if ($protocolName -match '^URL:(.+)$') {
            $protocolName = $Matches[1]
        }

        # Get the URL protocol command from the shell\open\command subkey
        $command = $null
        if ($protocolData.SubKeys.ContainsKey('shell') -and
            $protocolData.SubKeys['shell'].SubKeys.ContainsKey('open') -and
            $protocolData.SubKeys['shell'].SubKeys['open'].SubKeys.ContainsKey('command')) {
            $command = $protocolData.SubKeys['shell'].SubKeys['open'].SubKeys['command']['(Default)']
        }

        # Get the URL protocol icon from the DefaultIcon subkey
        $iconPath = $null
        if ($protocolData.SubKeys.ContainsKey('DefaultIcon')) {
            $iconPath = $protocolData.SubKeys['DefaultIcon']['(Default)']
        }

        # Determine if the protocol is built or from Microsoft.
        $isMicrosoft = $protocol -match '^ms-|^microsoft'

        # Create a new object to store the URL protocol data
        $urlProtocol = [PSCustomObject]@{
            Protocol = $protocol
            Name = $protocolName
            Command = $command
            IconPath = $iconPath
            DerivedIcon = ""
            # Create empty properties for package data later
            PackageName = ""
            PackageFullName = ""
            PackageAppKeyName = ""
            PackageAppName = ""
            PackageAppDescription = ""
            #ClassID = ""
            IsMicrosoft = $isMicrosoft
        }

        # Add the URL protocol data object to the array
        $urlProtocolDataOriginal += $urlProtocol
    }

    #Sort the array by protocol name
    $urlProtocolDataOriginal = $urlProtocolDataOriginal | Sort-Object -Property Protocol

    # Returns two arrays, one with the original data and one with the appx data, so need to split it up
    $arrayProtocolAndAppxData = Get-AppDetails-From-AppxManifest -CustomLanguageFolder $CustomLanguageFolder -OnlyMicrosoftApps:$OnlyMicrosoftApps -GetExtraData:$GetExtraData
    $protocolAppxData = $arrayProtocolAndAppxData.UrlProtocolData
    $associatedProtocolsPerApp = $arrayProtocolAndAppxData.AssociatedProtocolsPerApp

    Write-host "Appx数据计数: $($protocolAppxData.Count)"

    # This makes it so Appx details are preferred over original existing
    $urlProtocolDataPreferredAppx = Make-DeepCopy $urlProtocolDataOriginal
    foreach ($protocol in $urlProtocolDataPreferredAppx) {
        $appxData = $protocolAppxData | Where-Object { $_.Protocol -eq $protocol.Protocol }
        if ($appxData) {
            $protocol.PackageName = $appxData.PackageName
            $protocol.PackageFullName = $appxData.PackageFullName
            $protocol.PackageAppKeyName = $appxData.PackageAppKeyName
            $protocol.PackageAppName = $appxData.PackageAppName
            $protocol.PackageAppDescription = $appxData.PackageAppDescription
            $protocol.Command = $appxData.Command
            #$protocol.ClassID = $appxData.ClassID
            $protocol.IsMicrosoft = $appxData.IsMicrosoft
            #$protocol.IconPath = $appxData.IconPath # Don't overwrite icon path, Appx doesn't contain icon paths
        }
    }

    $urlProtocolData = $urlProtocolDataPreferredAppx

    # Now have all data in $urlProtocolData array, but we want to filter it
    $filteredUrlProtocolData = @()

    # Based on the parameter $AllURLProtocols, only include Microsoft protocols if not specified
    if ($OnlyMicrosoftApps) {
        foreach ($protocol in $urlProtocolData) {
            if ($protocol.IsMicrosoft) {
                $filteredUrlProtocolData += $protocol
            } else {
                Write-Verbose "Not including non-Microsoft protocol: $($protocol.Protocol)"
            }
        }
    # Include any protocols not in the permanent list
    } else {
        #$filteredUrlProtocolData = $urlProtocolData | Where-Object { $_.IsMicrosoft -or $_.PackageName }
        foreach ($protocol in $urlProtocolData) {
            if ($permanentProtocolsIgnore -notcontains $protocol.Protocol) {
                $filteredUrlProtocolData += $protocol
            } else {
                Write-Verbose "Ignoring common protocol: $($protocol.Protocol)"
            }
        }
    }

    # Return both arrays
    return @{
        FilteredUrlProtocolData = $filteredUrlProtocolData
        AssociatedProtocolsPerApp = $associatedProtocolsPerApp
    }
}

function Create-URL-Protocols-CSVFile {
    param (
        [string]$outputPath,
        [array]$urlProtocolsData
    )

    $csvContent = "Protocol,Name,Command,Package Name,Package AppName,Package App Description,IsMicrosoft`n"

    foreach ($item in $urlProtocolsData) {
        $protocol = $item.Protocol -replace '"', '""'
        # Add :// to end of protocol to make it a valid URL
        $protocol += "://"

        $name = $item.Name -replace '"', '""'
        $command = $item.Command -replace '"', '""'
        $packageName = $item.PackageName -replace '"', '""'
        $packageAppName = $item.PackageAppName -replace '"', '""'
        $packageAppDescription = $item.PackageAppDescription -replace '"', '""'
        #$classID = $item.ClassID -replace '"', '""'
        $isMicrosoft = $item.IsMicrosoft

        $csvContent += "`"$protocol`",`"$name`",`"$command`",`"$packageName`",`"$packageAppName`",`"$packageAppDescription`",$isMicrosoft`n"
    }

    $csvContent | Out-File -FilePath $outputPath -Encoding utf8
}

# Alternate version of Create-Protocol-Shortcut that creates a .url file instead of a .lnk file
function Create-Protocol-Shortcut {
    param (
        [string]$protocol,
        [string]$name,
        #[string]$command,
        [string]$shortcutPath
    )
    Write-Verbose "Creating URL file for $protocol"
    # Write the URL file content to the file
    try {
        #Windows will automatically display the icon for the protocol, so we don't need to specify it in the URL file
        $urlFileContent = "[InternetShortcut]`nURL=$protocol`:///`n"
        $urlFileContent | Out-File -FilePath $shortcutPath -Encoding ascii
        return $true
    }
    catch {
        Write-Host "Error creating URL file for $name`: $($_.Exception.Message)"
        return $false
    }
}

# Function to format informaount about file output in grid
function Format-FileGrid {
    param (
        [array]$fileNames,
        [int]$columnsPerRow = 3,
        [int]$minSpacing = 4,
        [int]$indent = 5,
        [string]$prefix = "",
        [switch]$noSort
    )

    if ($fileNames.Count -eq 0) {
        return
    }

    $indentString = " " * $indent
    $sortedNames = if ($noSort) { $fileNames } else { $fileNames | Sort-Object }

    # If the number of $sortedNames is less than the columnsPerRow, just directly output them in a single row
    if ($sortedNames.Count -le $columnsPerRow) {
        # Create padding string of length $minSpacing
        $padding = " " * $minSpacing
        Write-Host ($indentString + $prefix + ($sortedNames -join $padding))
        return
    }

    # Calculate column widths
    $columnWidths = @()
    for ($i = 0; $i -lt $columnsPerRow; $i++) {
        $columnItems = @()
        for ($j = $i; $j -lt $sortedNames.Count; $j += $columnsPerRow) {
            $columnItems += $sortedNames[$j]
        }
        $maxLength = ($columnItems | Measure-Object Length -Maximum).Maximum
        if ($maxLength -gt 0) {
            $columnWidths += $maxLength
        }
    }

    # Output rows
    for ($i = 0; $i -lt $sortedNames.Count; $i += $columnsPerRow) {
        $row = @()
        for ($j = 0; $j -lt $columnsPerRow; $j++) {
            if ($i + $j -lt $sortedNames.Count) {
                $item = $sortedNames[$i + $j]
                $padding = if ($j -lt ($columnWidths.Count - 1)) {
                    $paddingLength = [Math]::Max(0, $columnWidths[$j] - $item.Length + $minSpacing)
                    " " * $paddingLength
                } else {
                    ""
                }
                $row += $item + $padding
            }
        }
        Write-Host ($indentString + $prefix + ($row -join ""))
    }
}

# Function to search for protocol URLs in AppX package files
function Search-HiddenLinks {
    param (
        [Parameter(Mandatory=$true)]
        $associatedProtocolsPerApp,
        $URLProtocolsData,
        [switch]$SkipAppXURLSearch,
        [switch]$DeepScanHiddenLinks
    )

    if ($SkipAppXURLSearch) {
        Write-Host "Skipping AppX URL search as requested."
        return $null
    }

    # Set a max file size for searching to 70% of memory. Might not need this later but currently ReadAllText loads entire file into memory
    $availableRAM = [System.Math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory)
    $maxFileSize = [System.Math]::Round($availableRAM * 0.70)

    # DEBUGGING - Can use variables $debugSkipAppxSearch and $debugSearchOnlyProtocolList to only search certain protocols or skip AppX search. Must be passed in as arguments
    # $debugSkipAppxSearch - Set by argument

    # $debugSearchOnlyProtocolList - Will parse the string into an array of protocols to search
    if ($debugSearchOnlyProtocolList) {
        $debugSearchOnlyProtocolList = $debugSearchOnlyProtocolList -split ','
        $debugSearchOnlyProtocolList = $debugSearchOnlyProtocolList | ForEach-Object { $_.Trim() }
    } else { $debugSearchOnlyProtocolList = $null }
    
    if ($debugSkipAppxSearch) { Print-SuperWarning "!!! DEBUGGING VARIABLE ENABLED TO SKIP APPX SEARCH !!!" }
    if ($debugSearchOnlyProtocolList) { Print-SuperWarning "!!! DEBUGGING VARIABLE SET ONLY SEARCH CERTAIN PROTOCOLS !!!" }

    $ignoredExtensions = @(
        # Media Filetypes
        '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.svg', '.ico', '.ogg', '.mp4',
        '.webm', '.webp', '.flac', '.wav', '.mp3', '.m4a', '.aac', '.wma', '.flv',
        '.avi', '.mov', '.wmv', '.mpg', '.mpeg', '.m4v', '.mkv', '.3gp', '.3g2',
        '.mxf', '.psd', '.psb', '.heif', '.heic', '.hevc', '.tiff', '.tif', '.ogv',

        # Other
        '.p7x', '.ttf', '.onnxe', '.bundle', '.vsix', '.nupkg', '.asar', '.resS',
        '.bnk', '.onnx', '.opq', '.safetensors', '.cat', '.sig'

        # Archives
        '.7z', '.a', '.aar', '.ace', '.afa', '.alz', '.apk', '.ar', '.arc', '.arj', 
        '.ark', '.b1', '.b6z', '.ba', '.bh', '.cab', '.car', '.cdx', '.cfs', '.cpio', 
        '.cpt', '.dar', '.dd', '.dgc', '.dmg', '.ear', '.ecc', '.ecsbx', '.gca', 
        '.genozip', '.ha', '.hki', '.ice', '.iso', '.jar', '.kgb', '.LBR', '.lbr', 
        '.lha', '.lzh', '.lzx', '.mar', '.pak', '.paq6', '.paq7', '.paq8', '.par',
        '.par2', '.partimg', '.pea', '.phar', '.pim', '.pit', '.qda', '.rar', '.rev', 
        '.rk', '.s7z', '.sbx', '.sda', '.sea', '.sen', '.sfx', '.shar', '.shk', '.sit',
        '.sitx', '.sqx', '.tar', 'bz2', '.tbz2', '.gz', '.lz', '.xz', 
        '.Z', '.zst', '.tgz', '.tlz', '.txz', '.uc', '.uc0', '.uc2', '.uca', 
        '.ucn', '.ue2', '.uha', '.ur2', '.war', '.wim', '.xar', '.xp3', '.yz1', '.zip', 
        '.zipx', '.zoo', '.zpaq', '.zz',

        # Virtual Disks
        '.vdi', '.vmdk', '.vhd', '.hdd', '.vhdx', '.avhdx', '.vmrs', '.ovf', '.qed', '.qcow'
    )

    $encodingMap = @{
        ".txt" = "UTF-8";
        ".xml" = "UTF-8";
        ".json" = "UTF-8";
        ".dll" = "Unicode";
        ".exe" = "Unicode";
        ".js" = "UTF-8";
        ".ts" = "UTF-8";
        ".map" = "UTF-8";
        ".bin" = "Unicode";
        ".css" = "UTF-8";
        ".data" = "Unicode";
        ".layout" = "UTF-8";
        '.menu' = "UTF-8";
        '.html' = "UTF-8";
        '.htm' = "UTF-8";
        '.inf' = "UTF-8";
        '.sys' = "Unicode";
    }

    # Only want to search packages that are in $URLProtocolsData
    $packagesToSearchList = $URLProtocolsData.PackageName
    # Remove empty lines from the list and deduplicate
    $packagesToSearchList = $packagesToSearchList | Where-Object { $_ -ne "" }
    $packagesToSearchList = $packagesToSearchList | Sort-Object -Unique

    # Create new object by extracting out from $associatedProtocolsPerApp only the entries that are in $packagesToSearch
    $packagesToSearch = $associatedProtocolsPerApp | Where-Object { $packagesToSearchList -contains $_.PackageName }
    # Add FilesToSearch property to each object so we can search them later in a loop of each package
    $packagesToSearch | Add-Member -MemberType NoteProperty -Name FilesToSearch -Value @()

    # Prepare a list of files to search for each package and keep count of total to show progress later
    $totalFiles = 0
    [Int64]$totalFilesSize = 0
    foreach ($appPackage in $packagesToSearch) {
        $filesPerPackage = Get-ChildItem -Path $appPackage.InstallLocation -Recurse -File | Where-Object { $_.Extension -notin $ignoredExtensions -and $_.Length -gt 0 -and $_.Length -lt $maxFileSize }
        $appPackage.FilesToSearch = $filesPerPackage
        $totalFiles += $filesPerPackage.Count
        $totalFilesSize += ($filesPerPackage | Measure-Object -Property Length -Sum).Sum
    }

    
    #DEBUGGING - Print out the files that WILL be searched
    if ($Debug) {
        # Combine lists of searched files
        $willSearchFiles1 = @()
        $willSearchFiles1 = $packagesToSearch.FilesToSearch.FullName
        $willSearchFiles1 | Out-File -FilePath "$debugLogFolderPath\DEBUG - FilesWillSearch-Appx $timestamp.txt" -Encoding utf8
        Write-Debug "  -- Wrote debug file containing Appx files to be searched..."
    }

    #DEBUG - Remove all items from packagesToSearch if set to skip AppX search. Or if set to only search certain protocols, remove all others
    if ($debugSkipAppxSearch) {
        $packagesToSearch = @()
    } elseif ($debugSearchOnlyProtocolList) {
        $packagesToSearch = $packagesToSearch | Where-Object { $_.Protocols -in $debugSearchOnlyProtocolList }
    }

    # ------------------------------------------------------ Appx Files Search --------------------------------------------------------------------------
    # Go through Appx Packages. Each object in $packagesToSearch will be updated in-place with results
    $processedFiles = 0
    [Int64]$processedFilesSize = 0
    
    $resultsAppx = @()
    if ($Verbose -or $timing) { $stopwatch = [System.Diagnostics.Stopwatch]::StartNew() }
    
    Write-Host "[1/2] 搜索Appx程序文件中的隐藏链接:"
    foreach ($appPackage in $packagesToSearch) {
        #DEBUGGING ONLY - Limit the number of packages to search to get to the next part faster
        #if ($resultsAppx.Count -gt 3) { Write-Host "DEBUGGING ONLY - Limiting number of packages to search. IF YOU SEE THIS I FORGOT TO TAKE THIS OUT!"; break }

        $appxPackageResult, $processedFiles, $processedFilesSize = Get-ProtocolsInProgramFiles -encodingMap $encodingMap -program $appPackage -totalFiles $totalFiles -processedFiles $processedFiles -totalFilesSize $totalFilesSize -processedFilesSize $processedFilesSize
        $resultsAppx += $appxPackageResult
    }
    Write-Host "" # Write blank line because we were using carriage return
    if ($Verbose -or $timing) { $stopwatch.Stop(); Write-Host "   > STOPWATCH - Appx Files Search Time: $($stopwatch.Elapsed)" -ForegroundColor Green }
    # --------------------------------------------------------------------------------------------------------------------------------------------------

    # Create hashtable to store information about what to search
    $programFilesSearchData = @()
    # Array with list of folders to eventually calculate total files
    $otherProgramFoldersToSearch = @()

    # For other protocols not in resultsAppx.Protocol, see if it has an associated command, and use that directory as a search location next
    foreach ($protocol in $URLProtocolsData | Where-Object { $_.Protocol -notin $resultsAppx.Protocol }) {

        foreach ($command in $protocol.Command) {
            Write-Verbose "Processing command for $($protocol.Protocol): $command"
            $target = ""
            #$targetArgs = ""
            $installDir = ""

            if ($command) {
                $foundValidTarget = $false
                $Matches = $null

                # Method 1 - Try general matching pattern
                if (-not $foundValidTarget -and $command -match '(?i)[a-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]+\.[^\\/:*?"<>|\r\n ]+') {
                    $target = $Matches[0]
                    Write-Debug "Method 1 - Extracted target: $target"
                    if (Test-Path-Safe -Path $target) {
                        $foundValidTarget = $true
                        Write-Debug "Method 1 - Valid target found: $target"
                    } else {
                        Write-Debug "Method 1 - File not found: $target"
                    }
                }

                # Method 2
                if (-not $foundValidTarget -and $command -match '^"([^"]+)"?') {
                    $target = $Matches[1].Trim()
                    Write-Debug "Method 2 - Extracted target: $target"
                    if (Test-Path-Safe $target) { 
                        $foundValidTarget = $true
                        Write-Debug "Method 2 - Valid target found: $target"
                    }
                }

                # Method 3 - Try just trimming quotes
                if (-not $foundValidTarget -and $command -match '^"?(.*?)"?$') {
                    $target = $Matches[1].Trim()
                    Write-Debug "Method 3 - Extracted target: $target"
                    if (Test-Path-Safe $target) { 
                        $foundValidTarget = $true
                        Write-Debug "Method 3 - Valid target found: $target"
                    }
                }

                # Method 4 - Try splitting on the first space and trimming any quotes
                if (-not $foundValidTarget -and $command -match '^\s*"?([^ ]+)"?(.*)') {
                    $target = $Matches[1].Trim()
                    Write-Debug "Method 4 - Extracted target: $target"
                    if (Test-Path-Safe $target) { 
                        $foundValidTarget = $true
                        Write-Debug "Method 4 - Valid target found: $target"
                    }
                }

                # Method 5 - Try splitting on a space between quotes
                if (-not $foundValidTarget -and $command -match '^\s*"?([^"]+)"\s+"([^"]+)"') {
                    $target = $Matches[1].Trim()
                    Write-Debug "Method 5 - Extracted target: $target"
                    if (Test-Path-Safe $target) { 
                        $foundValidTarget = $true
                        Write-Debug "Method 5 - Valid target found: $target"
                    }
                }

                # Method 6 - At this point try assuming it's a direct path
                if (-not $foundValidTarget) {
                    Write-Debug "Method 6 - Trying direct path: $command"
                    if (Test-Path-Safe $command) {
                        $target = $command
                        $foundValidTarget = $true
                        Write-Debug "Method 6 - Valid target found: $target"
                    }
                }

                # Method 7 - Finally try without quotes
                if (-not $foundValidTarget) {
                    $unquotedCommand = $command.Trim('"')
                    Write-Debug "Method 7 - Trying without quotes: $unquotedCommand"
                    if (Test-Path-Safe $unquotedCommand) {
                        $target = $unquotedCommand
                        $foundValidTarget = $true
                        Write-Debug "Method 7 - Valid target found: $target"
                    }
                }

                if (-not $foundValidTarget) {
                    Write-Verbose "Command for $($protocol.Protocol) is invalid or has unknown structure: $command"
                    continue
                }


                
                # Wildcard Patterns & Applies within Program Files or Program Files x86 only: Will ensure the direct parent directory of the exe is searched, not the whole Publisher name directory for example
                $moreRestrictiveProgramFilesPaths = @("*\Common Files\*", "*\WindowsApps\*", "*\Adobe\*", "*\Microsoft Office\*", "*\Epic Games\*")

                # Wildcard Patterns: If the path starts with something in this list, then it will only search the specific file, not the whole directory. Not regex but uses wildcards, and a * will be added to the end
                $foldersToOnlySearchBinary = @("$env:WINDIR\*", "*\SteamLibrary\*")
                # Regex Patterns: These are literal regex path patterns that will be ignored while searching within the program files directory. Will be escaped later, and not case sensitive.
                $ignorePaths = @("\steamapps\")
                # Regex Pattern: Same as $ignorePaths but you must escape it yourself, but allows for more complex patterns
                $ignorePathsRegex = @()

                # Prepare variables if necessary - Regex escape ignorePaths
                $ignorePaths = $ignorePaths | ForEach-Object { [regex]::Escape($_) }
                # Combine with $ignorePathsRegex which must be already escaped
                $ignorePaths = $($ignorePaths ; $ignorePathsRegex)

                # Determine the program's install directory based on the target.
                # If it the path contains "\Program Files" or "\Program Files (x86)", then use the path until the next backslash, otherwise match to the last backslash
                if ($target -match '^(.*\\[Pp]rogram [Ff]iles( \(x86\))?\\[^\\]+)') {
                    $installDir = $Matches[1]
                    $Matches = $null
                    $containsRestrictivePath = $false
                    # Exceptions for more restrictive paths for 'Program Files' paths. If the install directory is in one of these paths, then use the immediate parent directory of the executable
                    foreach ($exception in $moreRestrictiveProgramFilesPaths) {
                        # Matches using wildcards already in each variable item. Explicitly case insensitive even though it already would be by default
                        if (($installDir -ilike "$exception") -or ($($installDir + "\") -ilike "$exception")) {
                            $containsRestrictivePath = $true
                            break
                        }
                    }
                    if ($containsRestrictivePath) {
                        # Use the immediate parent directory of the executable
                        $installDir = Split-Path -Path $target -Parent
                    }
                } else {
                    $installDir = Split-Path -Path $target -Parent
                }

                # If the install directory is in a list of exclusions, only search that specific file, not the whole directory
                foreach ($excludedFolder in $foldersToOnlySearchBinary) {
                    if (($installDir -ilike "$excludedFolder") -or (($installDir + "\") -ilike "$excludedFolder")) {
                        $installDir = $null
                        break
                    }
                }

                # Find if there's a matching package with the same name in $packagesToSearch
                $matchingPackage = $packagesToSearch | Where-Object { $_.PackageName -eq $protocol.PackageName }
                # If the matching package is found and $installdir matches or is within the package's install location, then skip it
                if ($matchingPackage -and $installDir -like "$($matchingPackage.InstallLocation)*") {
                    Write-Verbose "Skipping $($protocol.Protocol) because it's in the same package"
                    continue
                }
                # Create search item object
                $searchItem = [PSCustomObject]@{
                    PackageFullName = $protocol.PackageFullName
                    PackageName     = $protocol.PackageName
                    InstallLocation = $installDir # Assumed install directory
                    Publisher       = "N/A"
                    PublisherId     = "N/A"
                    IsMicrosoft     = $protocol.IsMicrosoft
                    Protocols       = @($protocol.Protocol)
                    FilesToSearch   = @()
                    # Additional properties for non-appx
                    Command = $command
                    Target = $target
                }
                if ($installDir) {
                    $otherProgramFoldersToSearch += $installDir
                }
                $programFilesSearchData += $searchItem
            }
        }
    }

    #DEBUG - If set to only search certain protocols, remove all others
    if ($debugSearchOnlyProtocolList) {
        $programFilesSearchData = $programFilesSearchData | Where-Object { $_.Protocols -in $debugSearchOnlyProtocolList }
    }

    # Get total files to search in other program folders. There might be duplicate folders, but we need to still count them because they'll be searched separately
    $totalFiles = 0
    [Int64]$totalFilesSize = 0
    Write-Host "`n正在创建文件列表以搜索非Appx程序包中的隐藏链接...`n"
    foreach ($program in $programFilesSearchData) {
        $files = @()
        $folder = $program.InstallLocation
        Write-Verbose "Gathering list of files to search for $($program.Protocols)"
        # Gather files from entire folder of each program if folder is accessible (not null), and deep scan is enabled
        if ($null -ne $folder -and $DeepScanHiddenLinks) {
            Write-Verbose " > Gathering in $folder"
            $searchErrorVariable = $null
            try {
                # Recursively get all files in the folder that are not in the ignored extensions list
                $files = Get-ChildItem -Path $folder -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable searchErrorVariable | Where-Object { 
                    $currentCheckingFile = $_
                    $currentCheckingFile.Length -lt $maxFileSize -and
                    $currentCheckingFile.Extension -notin $ignoredExtensions -and 
                    $currentCheckingFile.Length -gt 0 -and
                    # Check if the file is in an ignored path. The $_ variable is each regex pattern within $ignorePaths, and is already escaped earlier. Case insensitive
                    ($ignorePaths | ForEach-Object { $currentCheckingFile.FullName -inotmatch $_ }) -notcontains $false
                }
                $program.FilesToSearch = $files
                Write-Verbose "Got $($files.Count) files in $folder for $($program.Protocols)"
            # If it's an unauthorizedaccessexception, make AssumeInstallDir null so it's counted as a single file search
            } catch [System.UnauthorizedAccessException] {
                Write-Verbose "Unauthorized access to $folder, assuming it's a single file search for $($program.Protocols)"
                $program.InstallLocation = $null
                $program.FilesToSearch = @($program.Target | Get-Item)
                continue
            # Do the same for any other exceptions
            } catch {
                Write-Verbose "Error getting files in $folder for $($program.Protocols)`: $_"
                $program.InstallLocation = $null
                $program.FilesToSearch = @($program.Target | Get-Item)
                continue
            }
            # If errors occurred, print them out
            if ($searchErrorVariable) {
                Write-Warning "*** Some errors occurred in the directory search:"
                foreach ($errorEntry in $searchErrorVariable) {
                    if ($errorEntry.CategoryInfo.Reason -eq "UnauthorizedAccessException") {
                        Write-Warning " *** Permission denied to access $($errorEntry.TargetObject) -- Will assume it's a single file to search for $($program.Protocols)"
                    } else {
                        Write-Warning " *** Error getting files in $($errorEntry.TargetObject): $($errorEntry.Exception.Message)  -- Will assume it's a single file to search for $($program.Protocols)"
                    }
                    $program.FilesToSearch = @($program.Target | Get-Item)
                }
            }

        # Only set single target file to be searched
        } else {
            Write-Verbose " > Folder for $($program.Protocols) is null, assuming it's a single file search"
            try {
                $files = @($program.Target | Get-Item)
                $program.FilesToSearch = $files
                Write-Verbose "Got $($files.Count) files for $($program.Protocols)"
            } catch {
                Write-Verbose "Error getting file $($program.Target) for $($program.Protocols)`: $_"
                $program.FilesToSearch = @()
                continue
            }
        }
        $totalFiles += $files.Count
        $totalFilesSize += ($files | Measure-Object -Property Length -Sum).Sum
    }
    Write-Verbose "Found $totalFiles total files"

    #DEBUGGING - Print out the other program files that WILL be searched
    if ($Debug) {
        $willSearchFiles2 = @()
        $willSearchFiles2 = $programFilesSearchData.FilesToSearch.FullName
        $willSearchFiles2 | Out-File -FilePath "$debugLogFolderPath\DEBUG - FilesWillSearch-OtherPrograms $timestamp.txt" -Encoding utf8
        Write-Debug "  -- Wrote debug file containing other program files to be searched..."
    }

    # ------------------------------------------------------ Non-Appx Files Search --------------------------------------------------------------------------
    $processedFiles = 0
    [Int64]$processedFilesSize = 0
    $resultsNonAppx = @()
    if ($Verbose -or $timing) { $stopwatch = [System.Diagnostics.Stopwatch]::StartNew() }

    Write-Host "`n[2/2] 搜索非Appx程序文件中的隐藏链接:"
    foreach ($itemToSearch in $programFilesSearchData) {
        # Search Display Location
        $protocolsString = $itemToSearch.Protocols -join ", "
        if ($Verbose -and $itemToSearch.InstallLocation) {
            Write-Host "`rVERBOSE: Scanning: $($itemToSearch.InstallLocation)\ | For File Protocol: $protocolsString".PadRight(100) -Verbose -ForegroundColor Yellow
        } elseif ($Verbose) { 
            Write-Host "`rVERBOSE: Scanning: $($itemToSearch.Target) | For File Protocol: $protocolsString".PadRight(100) -Verbose -ForegroundColor Yellow
        }

        $programResult, $processedFiles, $processedFilesSize = Get-ProtocolsInProgramFiles -encodingMap $encodingMap -program $itemToSearch -totalFiles $totalFiles -processedFiles $processedFiles -totalFilesSize $totalFilesSize -processedFilesSize $processedFilesSize
        $resultsNonAppx += $programResult
    }
    Write-Host "" # Write blank line because we were using carriage return
    if ($Verbose -or $timing) { $stopwatch.Stop(); Write-Host "   > STOPWATCH - Non-Appx Files Search Time: $($stopwatch.Elapsed)" -ForegroundColor Green }
    # -----------------------------------------------------------------------------------------------------------------------------------------------------

    #DEBUGGING - Print out the files that were searched to a file
    if ($Debug) {
        $searchedFiles = @()
        $searchedFiles = $packagesToSearch.FilesToSearch.FullName
        $searchedFiles | Out-File -FilePath "$debugLogFolderPath\DEBUG - SearchedFilesAppx $timestamp.txt" -Encoding utf8

        $searchedFiles2 = @()
        $searchedFiles2 = $programFilesSearchData.FilesToSearch.FullName
        $searchedFiles2 | Out-File -FilePath "$debugLogFolderPath\DEBUG - SearchedFilesSecondaryPrograms $timestamp.txt" -Encoding utf8
        Write-Debug "  -- Wrote debug files containing searched files..."
    }

    # Remove any entries where the fullpath is a duplicate of another
    $resultsUniqueFullURL = $resultsAppx | Sort-Object -Property FullURL -Unique
    # If there are any secondary results, merge them with the primary results by adding any that aren't in there already
    if ($resultsNonAppx.Count -gt 0) {
        $resultsUniqueFullURL += $resultsNonAppx | Sort-Object -Property FullURL -Unique
        foreach ($result in $resultsNonAppx) {
            if ($resultsUniqueFullURL.FullURL -notcontains $result.FullURL) {
                $resultsUniqueFullURL += $result
            }
        }
    }
    return $resultsUniqueFullURL
}

function Get-ProtocolsInProgramFiles {
    param (
        [hashtable]$encodingMap,
        [PSCustomObject]$program,
        [int]$totalFiles,
        [int]$processedFiles,
        [Int64]$totalFilesSize = 0,
        [Int64]$processedFilesSize = 0
    )

    $protocolsList = $program.Protocols
    $filesToSearch = $program.FilesToSearch
    $resultsForProgram = [System.Collections.Generic.List[object]]::new() # Using a typed generic list for better performance instead doing addition of arrays

    # This makes sure it prints progress at least once per package
    $currentPercentageDetailed = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
    $currentPercentage = [math]::Floor($currentPercentageDetailed)
    if ($Verbose) {
        $totalFilesSizeMB = ("{0:N0}" -f ($totalFilesSize / 1MB))
        $processedFileSizeMB = ("{0:N0}" -f ($processedFilesSize / 1MB)).PadLeft($totalFilesSizeMB.Length) # Pad to the length of the total size so it doesn't jump around
        $processedFilesString = $processedFiles.ToString().PadLeft($totalFiles.ToString().Length)
        Write-Host "`r   搜索进度: $($currentPercentageDetailed.ToString("F2"))%".PadLeft(7) -NoNewline
        Write-Host "   ($processedFilesString / $totalFiles files   |   $processedFileSizeMB / $totalFilesSizeMB MB ) "  -NoNewline
    }
    else {
        if (-not $psISE){
            Write-Host "`r   搜索进度: $currentPercentage% " -NoNewline
        } else {
            Write-Progress -Activity "查找文件中" -Status "进度: $currentPercentage%" -PercentComplete $currentPercentage
        }
    }

    $lastPercentage = $currentPercentage

    # Prepare regex 
    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    $utf8Regex = @{}
    $unicodeRegex = @{}
    foreach ($protocol in $protocolsList) {
        $utf8Regex[$protocol] = [regex]::Escape($protocol) + "://[^`"\s<>()\\``\x00-\x1F\x7F]+"
        $unicodeRegex[$protocol] = [regex]::Escape($protocol) + "://[ -~]+"
    }

    # Skip the file if it doesn't exist
    foreach ($file in $filesToSearch) {
        try {
            $null = Test-Path -LiteralPath $file.FullName -PathType Leaf -ErrorAction Stop
        }
        catch {
            Write-Debug "Error checking path - $Path : $_"
            Continue
        }

        $fileResults = [System.Collections.Generic.List[object]]::new() # Again using a typed generic list for better performance
        $fileExtension = $file.Extension # Containskey is case-insensitive so no need to convert to lower
        $encodingsToTry = if ($encodingMap.ContainsKey($fileExtension)) { @($encodingMap[$fileExtension]) } else { @("UTF-8", "Unicode") }
        if ($Verbose) {
            $processedFilesSize += $file.Length
        }

        foreach ($encodingName in $encodingsToTry) {
            $encoding = [System.Text.Encoding]::GetEncoding($encodingName)
            try {
                $content = [System.IO.File]::ReadAllText($file.FullName, $encoding)
                foreach ($protocol in $protocolsList) {
                    $uriPattern = if ($encodingName -eq "UTF-8") { $utf8Regex[$protocol] } else { $unicodeRegex[$protocol] }
                    $URImatches = [regex]::Matches($content, $uriPattern, $regexOptions)
                    if ($URImatches.Count -gt 0) {
                        $fileResults.AddRange(@($URImatches | ForEach-Object {
                            [PSCustomObject]@{
                                FullURL       = $_.Value -replace '".*$', ''
                                EncodingUsed  = $encodingName
                                UsesVariables = $_.Value -match "[<>()\[\]{}]|=$|:$"
                                FilePath      = $file.FullName
                                Protocol      = $protocol
                            }
                        }))
                    }
                }
                if ($fileResults.Count -gt 0) { break }
            }
            catch {
                Write-Warning "Error processing file $($file.FullName) with $encodingName encoding: $_"
            }
        }

        # After processing all encodings for a file
        if ($fileResults.Count -gt 0) {
            $resultsForProgram.AddRange($fileResults)
        }

        $processedFiles++
        $currentPercentageDetailed = [math]::Round(($processedFiles / $totalFiles) * 100, 2)
        $currentPercentage = [math]::Floor($currentPercentageDetailed)

        if ($currentPercentage -ne $lastPercentage) {
            if ($Verbose) {
                $totalFilesSizeMB = ("{0:N0}" -f ($totalFilesSize / 1MB))
                $processedFileSizeMB = ("{0:N0}" -f ($processedFilesSize / 1MB)).PadLeft($totalFilesSizeMB.Length) # Pad to the length of the total size so it doesn't jump around
                $processedFilesString = $processedFiles.ToString().PadLeft($totalFiles.ToString().Length)
                Write-Host "`r   搜索进度: $($currentPercentageDetailed.ToString("F2"))%".PadLeft(7) -NoNewline
                Write-Host "   ($processedFilesString / $totalFiles files   |   $processedFileSizeMB / $totalFilesSizeMB MB ) "  -NoNewline
            }
            else {
                if (-not $psISE) {
                    Write-Host "`r   搜索进度: $currentPercentage% " -NoNewline
                }
                else {
                    Write-Progress -Activity "查找文件中" -Status "进度: $currentPercentage%" -PercentComplete $currentPercentage
                }
            }
            $lastPercentage = $currentPercentage
        }
    }
    $content = $null # Make sure file content is cleared from memory next time garbage collection runs to free up memory

    return $resultsForProgram, $processedFiles, $processedFilesSize
}

# Function to create CSV for AppX URL search results
function Create-AppXURLSearchResultsToCSV {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$urlItemsData,
        [Parameter(Mandatory=$true)]
        [string]$outputPath
    )

    # Manually create CSV data
    # Create the column headers
    $csvContent = "Protocol,Full URL,Encoding Used,Embedded Variables, Found in File`n"

    # Loop through each URL item and add it to the CSV content
    foreach ($urlItem in $urlItemsData) {
        $protocol = $urlItem.Protocol
        $fullURL = $urlItem.FullURL
        $encodingUsed = $urlItem.EncodingUsed
        $usesVariables = $urlItem.UsesVariables
        $filePath = $urlItem.FilePath

        # Escape double qoutes in everything
        $fullURL = $fullURL -replace '"', '""'
        $protocol = $protocol -replace '"', '""'
        $encodingUsed = $encodingUsed -replace '"', '""'
        $usesVariables = $usesVariables -replace '"', '""'
        $filePath = $filePath -replace '"', '""'

        # Add the URL item to the CSV content
        $csvContent += "`"$protocol`",`"$fullURL`",`"$encodingUsed`",`"$usesVariables`",`"$filePath`"`n"
    }

    # Write to csv file
    $csvContent | Out-File -FilePath $outputPath -Encoding utf8

}

# Function to create shortcuts for AppX URL search results
function Create-AppXURLShortcuts {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$foundURLsItems,
        [Parameter(Mandatory=$true)]
        [string]$shortcutFolder
    )

    # Create list of created shortcut names to avoid duplicates
    $createdShortcuts = @()

    foreach ($urlItem in $foundURLsItems) {
        # If the URL uses variables, skip creating a shortcut for it
        if ($urlItem.UsesVariables) {
            Write-Verbose "Skipping URL with variables: $($urlItem.FullURL)"
            continue
        }

        $fullURL = $urlItem.FullURL
        Write-Verbose "Creating URL file for $fullURL"

        # Crop off any parameter part of the URL
        $simplifiedURL = $fullURL -replace '\?.*$', ''

        # Sanitize the URL to make it a valid filename
        $sanitizedURLForName = $simplifiedURL -replace '://', ' - ' # Replace the :// with a space dash space
        $sanitizedURLForName = $sanitizedURLForName -replace '[\\/:*?"<>|]', '_'
        $sanitizedURLForName = $sanitizedURLForName -replace '_+$', '' # Cut off any extra underscore at the end

        # If shortcut of same name was already created, append a number to the name.
        $i = 2
        $originalSanitizedURLForName = $sanitizedURLForName
        while ($createdShortcuts -contains $sanitizedURLForName) {
            $sanitizedURLForName = "$originalSanitizedURLForName ($i)"
            $i++
        }

        $shortcutPath = Join-Path $shortcutFolder "$sanitizedURLForName.url"

        # Write the URL file content to the file
        try {
            #Windows will automatically display the icon for the protocol, so we don't need to specify it in the URL file
            $urlFileContent = "[InternetShortcut]`nURL=$fullURL`n"
            $urlFileContent | Out-File -FilePath $shortcutPath -Encoding ascii
            $createdShortcuts += $sanitizedURLForName
        }
        catch {
            Write-Host "Error creating URL file for $fullURL`: $($_.Exception.Message)"
        }
    }
}

# =============================================================================================================================
# ==================================================  MAIN SCRIPT  ============================================================
# =============================================================================================================================

# Create empty arrays for each type of data to be stored
$clsidInfo = @()
$namedFolders = @()
$taskLinks = @()
$settingsData = @()
$msSettingsList = @()
$deepLinkData = @()
$deepLinksProcessedData = @()
$URLProtocolsData = @()

# Loop for CLSID Links
if (-not $SkipCLSID) {
    Write-Host "`n----- 正在处理 Shell 文件夹 -----"
    # Retrieve all CLSIDs with a "ShellFolder" subkey from the registry.
    # These CLSIDs represent shell folders that are embedded within Windows.
    try {
        $shellFolders = Get-ChildItem -Path 'Registry::HKEY_CLASSES_ROOT\CLSID' |
        Where-Object { $_.GetSubKeyNames() -contains "ShellFolder" } |
        Select-Object PSChildName
    } catch {
        Write-Error "从注册表检索 CLSID 时出错`: $_"
        $shellFolders = $null
    }

    $usedNames = @()  # Track used names to avoid duplicates

    # Loop through each relevant CLSID that was found and process it to create shortcuts.
    foreach ($folder in $shellFolders) {
        $clsid = $folder.PSChildName  # Extract the CLSID.
        Write-Verbose "正在处理CLSID: $clsid"

        # Retrieve the name of the shell folder using the Get-FolderName function and the source of the name within the registry
        $resultArray = Get-FolderName -clsid $clsid -CustomLanguageFolder $CustomLanguageFolderPath
        $name = $resultArray[0]
        $nameSource = $resultArray[1]

        # Sanitize the folder name to make it a valid filename.
        $sanitizedName = $name -replace '[\\/:*?"<>|]', '_'

        # Ensure the folder name is unique by appending a number if necessary.
        $i = 2
        $originalSanitizedName = $sanitizedName
        while ($usedNames -contains $sanitizedName) {
            $sanitizedName = "$originalSanitizedName ($i)"
            $i++
        }
        $usedNames += $sanitizedName

        $shortcutPath = Join-Path $CLSIDshortcutsOutputFolder "$sanitizedName.lnk"

        Write-Verbose "正在尝试创建快捷方式: $shortcutPath"
        $success = Create-CLSID-Shortcut -clsid $clsid -name $name -shortcutPath $shortcutPath

        if ($success) {
            Write-Host "创建 CLSID 快捷方式成功: $name"
        }
        else {
            Write-Host "创建快捷方式失败: $name"
        }

        # Check for sub-items (pages) related to the current CLSID (e.g., control panel items).
        $appName = (Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid" -ErrorAction SilentlyContinue)."System.ApplicationName"

        # Store the CLSID information for later use (e.g., in CSV file generation).
        $iconPath = (Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid\DefaultIcon" -ErrorAction SilentlyContinue).'(default)'
        $clsidInfo += [PSCustomObject]@{
            CLSID = $clsid
            Name = $name
            NameSource = $nameSource
            IconPath = $iconPath
        }
    }

}

# Loop for special named folders
if (-not $SkipNamedFolders) {
    Write-Host "`n----- 正在处理特殊名称文件夹 -----"

    try {
        # Retrieve all named special folders from the registry.
        $namedFolders = Get-ChildItem -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions"
    } catch {
        Write-Error "从注册表检索特殊名称文件夹时出错`: $_"
        $namedFolders = $null
    }

    # Loop through each named folder and create a shortcut for it.
    foreach ($folder in $namedFolders) {
        $folderProperties = Get-ItemProperty -Path $folder.PSPath
        $folderName = $folderProperties.Name  # Extract the name of the folder.
        $iconPath = $folderProperties.Icon  # Extract the custom icon path (if any).

        if ($folderName) {
            Write-Verbose "正在处理特殊名称文件夹: $folderName"

            # Sanitize the folder name to make it a valid filename.
            $sanitizedName = $folderName -replace '[\\/:*?"<>|]', '_'
            $shortcutPath = Join-Path $namedShortcutsOutputFolder "$sanitizedName.lnk"

            Write-Verbose "正在尝试创建快捷方式: $shortcutPath"
            $success = Create-NamedShortcut -name $folderName -shortcutPath $shortcutPath -iconPath $iconPath

            if ($success) {
                Write-Host "创建特殊名称文件夹快捷方式成功: $folderName"
            }
            else {
                Write-Host "创建特殊名称文件夹快捷方式失败: $folderName"
            }
        }
        else {
            Write-Verbose "跳过没有名称的文件夹: $($folder.PSChildName)"
        }
    }
}

# Loop for Task Links
if (-not $SkipTaskLinks) {
    # Process Task Links - Use the extracted XML data from Shell32 to create shortcuts for task links
    Write-Host "`n ----- 正在处理任务链接 -----"
    # Retrieve task links from the XML content in shell32.dll.
    $taskLinks = Get-TaskLinks -SaveXML:(!$NoStatistics) -DLLPath:$CustomDLLPath -CustomLanguageFolder:$CustomLanguageFolderPath
    $createdShortcutNames = @{} # Track created shortcuts to be able to tasks with the same name but different commands by appending a number

    if ($taskLinks) {
        # Sort by name
        $taskLinks = $taskLinks | Sort-Object -Property Name
    }
    
    foreach ($task in $taskLinks) {
        $originalName = $task.Name
        $sanitizedName = ""

        # Prepend category names to tasks if DontGroupTasks is not specified
        if (-not $DontGroupTasks) {
            if ($UseAlternativeCategoryNames) {
                # Try looking up the application ID default name by CLSID in the registry
                $trueApplicationName = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\$($task.ApplicationId)" -ErrorAction SilentlyContinue)."(Default)"
                if ($trueApplicationName) {
                    # If found then prepend it to the task name and use that
                    $sanitizedName = "$trueApplicationName - $originalName"
                }
            }

            # If not set to use alternative categories, or one was not found, then use the default Prettify-App-Name function
            if ($task.ApplicationName -and -not $sanitizedName) {
                # Use Prettify-App-Name function by default, unless DontGroupTasks is specified
                $sanitizedName = Prettify-App-Name -AppName $task.ApplicationName -TaskName $originalName
            } elseif (-not $task.ApplicationName -and -not $sanitizedName) {
                $sanitizedName = $originalName -replace '[\\/:*?"<>|]', '_'
            }
        } else {
            $sanitizedName = $originalName -replace '[\\/:*?"<>|]', '_'
        }

        # Check if a shortcut with this name already exists, if so set a unique number to the end of the name
        $nameCounter = 1
        $uniqueName = $sanitizedName
        while ($createdShortcutNames.ContainsKey($uniqueName)) {
            $nameCounter++
            $uniqueName = "${sanitizedName} ($nameCounter)"
        }

        # Determine the command based on available information. Some task XML entries have the entire command already given, others are implied to be used with control.exe
        if ($task.Command) {
            $command = $task.Command
        } elseif ($task.ApplicationName -and $task.Page) {
            $command = "control.exe /name $($task.ApplicationName) /page $($task.Page)"
        } else {
            Write-Verbose "跳过任务 $originalName，原因: 命令信息不足"
            continue
        }


        # Determine whether to create a URL or LNK shortcut based on the command
        $shortcutType = ""
        # If the command starts with a protocol (e.g., http://, https://, or even mshelp://), create a URL shortcut
        if ($command -match '^[a-zA-Z0-9]+:\/\/') {
            $shortcutType = "url"
        # Match ms-protocol shortcuts such as ms-settings: or ms-availablenetworks:, and create a URL if so
        #} elseif ($command -match '^ms-[a-zA-Z0-9]+:') {
        #    $shortcutType = "url"
        # Otherwise default to lnk
        } else {
            $shortcutType = "lnk"
        }

        $shortcutPath = Join-Path $taskLinksOutputFolder "$uniqueName.$shortcutType"
        $createdShortcutNames[$uniqueName] = $true

        $success = Create-TaskLink-Shortcut -name $uniqueName -shortcutPath $shortcutPath -shortcutType $shortcutType -command $command -controlPanelName $task.ControlPanelName -applicationId $task.ApplicationId -keywords $task.Keywords

        if ($success) {
            Write-Host "创建任务链接快捷方式成功: $uniqueName"
        } else {
            Write-Host "创建任务链接快捷方式失败: $uniqueName"
        }
    }
}

# Loop for Deep Links
if (-not $SkipDeepLinks -and $allSettingsXmlPath) {
    Write-Host "`n----- 正在处理深度链接 -----"

    $deepLinkData = Get-AllSettings-Data -xmlFilePath $allSettingsXmlPath -SaveXML:(!$NoStatistics)

    if ($null -eq $deepLinkData) {
        Write-Host "未找到深度链接数据，跳过深度链接创建。"
    }

    # If deep links data was found, process it to create shortcuts. If $deepLinkData is null or empty, this will be skipped.
    foreach ($deepLink in $deepLinkData) {
        # Each $deepLink object contains properties
        # -----------------------------
            # Name          (string)
            # Description   (string)
            # HighKeywords  (string)
            # DeepLink      (string)
            # IconPath      (string)
        # -----------------------------

        # Set empty variable to use later when checking for duplicate task links
        $existingTaskLink = "" 

        # It should always have a DeepLink property, but check just in case
        if ($deepLink.DeepLink) {

            # If set to not create duplicate deeplinks:
            # This block checks if a task link ($task.Command in $tasklinks) with the same command already exists, and skips if so
            if (-not $AllowDuplicateDeepLinks -and -not $SkipTaskLinks) {

                foreach ($taskLink in $taskLinks) {
                    $trimmedCommand = $taskLink.Command.Trim()
                    $trimmedDeepLink = $deepLink.DeepLink.Trim()

                    # Test if the deep link has the same command or same  application name/page structure
                    if (($trimmedCommand -eq $trimmedDeepLink) -or ($trimmedDeepLink -eq "$($taskLink.ApplicationName)\$($taskLink.Page)".Trim("\\"))) {
                        $existingTaskLink = $taskLink
                        break
                    }
                }

                if ($existingTaskLink) {
                    Write-Verbose "跳过深度链接: $($deepLink.Description)，原因: 已存在相同命令的任务链接"
                    continue
                }
            }

            $result = Create-Deep-Link-Shortcut -settingArray $deepLink

            if ($result) {
                Write-Host "创建深度链接快捷方式成功: $($deepLink.Description)"
                # Add the updated deepLink object to the processed data array. Will also now contain FullCommand and ShortcutPath
                $deepLinksProcessedData += $result
            } else {
                Write-Host "创建深度链接快捷方式失败: $($deepLink.Description)"
                $deepLink.FullCommand = "[Failed to create shortcut]"
                $deepLink.ShortcutPath = "[Failed to create shortcut]"
                $deepLinksProcessedData += $deepLink
            }
        }
    }

} elseif ($SkipDeepLinks) {
    Write-Host "`n 跳过深度链接创建...`n"
} elseif ($null -eq $allSettingsXmlPath) {
    Write-Warning "跳过深度链接创建，因为未找到 AllSystemSettings XML 文件。"
}

# Loop for MS-settings: Links
if (-not $SkipMSSettings) {
    Write-Host "`n----- 正在处理 MS-Settings 链接 -----"
    $msSettingsList = Get-MS-SettingsFrom-SystemSettingsDLL -DllPath $SystemSettingsDllPath

    foreach ($setting in $msSettingsList) {
        # Get the short name from the second part of the ms-settings: link
        $settingName = $setting.Split(':')[1]
        # Use policyId as the shortcut name
        $fullShortcutName = $setting

        # Sanitize the shortcut name (although policyId should already be safe)
        $sanitizedName = $settingName -replace '[\\/:*?"<>|]', '_'

        $shortcutPath = Join-Path $msSettingsOutputFolder "$sanitizedName.lnk"

        $success = Create-MSSettings-Shortcut -fullName $fullShortcutName -shortcutPath $shortcutPath

        if ($success) {
            Write-Host "创建 MS Settings 快捷方式成功: $fullShortcutName"
        } else {
            Write-Host "创建 MS Settings 快捷方式失败: $fullShortcutName"
        }
    }
}

# Loop for URL Protocols
if (-not $SkipURLProtocols){
    Write-Host "`n----- 正在处理 URL 协议 -----"
    if ($AllURLProtocols){
        $OnlyMicrosoftApps = $false
    } else {
        $OnlyMicrosoftApps = $true
    }

    $protocolAndAppxData = Get-And-Process-URL-Protocols -CustomLanguageFolder $CustomLanguageFolderPath -OnlyMicrosoftApps:$OnlyMicrosoftApps -permanentProtocolsIgnore $permanentURIProtocols -GetExtraData:$CollectExtraURLProtocolInfo
    $URLProtocolsData = $protocolAndAppxData.FilteredUrlProtocolData
    $associatedProtocolsPerApp = $protocolAndAppxData.AssociatedProtocolsPerApp

    foreach ($protocol in $URLProtocolsData) {
        $success = Create-Protocol-Shortcut -protocol $protocol.Protocol -name $protocol.Name -command $protocol.Command -shortcutPath (Join-Path $URLProtocolLinksOutputFolder "$($protocol.Protocol).url")
        if ($success) {
            Write-Host "创建 URL 协议快捷方式成功: $($protocol.Protocol)"
        } else {
            Write-Host "创建 URL 协议快捷方式失败: $($protocol.Protocol)"
        }
    }

    if (-not $SkipHiddenAppLinks) {
        Write-Host "`n----- 正在搜索隐藏的 URL 链接 -----"
        # Search for URLs in AppX package files by brute force
        $appXURLSearchResults = Search-HiddenLinks -associatedProtocolsPerApp $associatedProtocolsPerApp -URLProtocolsData $URLProtocolsData -SkipAppXURLSearch:$SkipHiddenAppLinks -DeepScanHiddenLinks:$DeepScanHiddenLinks

        if ($appXURLSearchResults) {
            Create-AppXURLShortcuts -foundURLsItems $appXURLSearchResults -shortcutFolder $URLProtocolPageLinksOutputFolder
        }
    }
}

# ===================================================================================================================================
# ==================================================  CSV FILE CREATION  ============================================================
# ===================================================================================================================================

# Create the CSV files using stored data. Skip each depending on the corresponding switch.
if (-not $NoStatistics) {
    if (-not $SkipCLSID) {
        Create-CLSIDCsvFile -outputPath $clsidCsvPath -clsidData $clsidInfo
    }
    if (-not $SkipNamedFolders) {
        Create-NamedFoldersCsvFile -outputPath $namedFoldersCsvPath
    }
    if (-not $SkipTaskLinks) {
        Create-TaskLinksCsvFile -outputPath $taskLinksCsvPath -taskLinksData $taskLinks
    }
    if (-not $SkipMSSettings) {
        Create-MSSettingsCsvFile -outputPath $msSettingsCsvPath -msSettingsList $msSettingsList
    }
    if (-not $SkipDeepLinks) {
        Create-Deep-Link-CSVFile -outputPath $deepLinksCsvPath -deepLinksDataArray $deepLinksProcessedData
    }
    if (-not $SkipURLProtocols) {
        Create-URL-Protocols-CSVFile -outputPath $URLProtocolLinksCsvPath -urlProtocolsData $URLProtocolsData
    }
    if (-not $SkipHiddenAppLinks -and -not $SkipURLProtocols) {
        Create-AppXURLSearchResultsToCSV -urlItemsData $appXURLSearchResults -outputPath $URLProtocolPageLinksCsvPath
    }
}

# Output information about the CSV and XML files that were created
if (-not $NoStatistics) {
    $displayCsvFiles = @($csvFiles.Values | Where-Object { -not $_.Skip } | ForEach-Object { $_.Value })
    $displayXmlFiles = @($xmlFiles.Values | Where-Object { -not $_.Skip } | ForEach-Object { $_.Value })
}

# Output results
if ($displayCsvFiles -or $displayXmlFiles) {
    Write-Host "`n--------------------------------------------------------------------------------"
    Write-Host "统计数据保存在文件夹: `"$statisticsFolderName`""

    if ($displayCsvFiles) {
        Write-Host "`n   - CSV 文件:"
        Format-FileGrid -fileNames $displayCsvFiles -Indent 7
    }

    if ($displayXmlFiles) {
        Write-Host "`n   - XML 文件:"
        Format-FileGrid -fileNames $displayXmlFiles -Indent 7
    }
}

# ================================================================================================================================
# ==================================================  SCRIPT RESULTS  ============================================================
# ================================================================================================================================

# Only count hidden app shortcuts created - those without UsesVariables property
$appXURLSearchResultsCreated = $appXURLSearchResults | Where-Object { -not $_.UsesVariables }

# Display total counts
$totalCount = $clsidInfo.Count + $namedFolders.Count + $taskLinks.Count + $msSettingsList.Count + $deepLinksProcessedData.Count + $URLProtocolsData.Count + $appXURLSearchResultsCreated.Count

# Output a message indicating that the script execution is complete and the CSV files have been created.
Write-Host "`n------------------------------------------------"
Write-Host   "      Windows Super God Mode 脚本执行结果     " -ForeGroundColor Yellow
Write-Host   "------------------------------------------------`n"

# Output the total counts of each, and color the numbers to stand out. Done by writing the text and then the number separately with -NoNewLine. If it was skipped, also add that but not colored.
Write-Host "         创建的快捷方式总数: " -NoNewline
Write-Host $totalCount -ForegroundColor Green

Write-Host "           > CLSID 链接:       " -NoNewline
Write-Host $clsidInfo.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipCLSID) { "   (跳过)" }) # If skipped, add the skipped text, otherwise still write empty string because we used -NoNewline previously

Write-Host "           > 特殊文件夹:       " -NoNewline
Write-Host $namedFolders.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipNamedFolders) { "   (跳过)" })

Write-Host "           > 任务链接:       " -NoNewline
Write-Host $taskLinks.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipTaskLinks) { "   (跳过)" })

Write-Host "           > 设置链接:       " -NoNewline
Write-Host $msSettingsList.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipMSSettings) { "   (跳过)" })

Write-Host "           > 深度链接:       " -NoNewline
Write-Host $deepLinksProcessedData.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipDeepLinks) { "   (跳过)" })

Write-Host "           > URL 协议:       " -NoNewline
Write-Host $URLProtocolsData.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipURLProtocols) { "   (跳过)" })

Write-Host "           > 隐藏的应用链接:  " -NoNewline
Write-Host $appXURLSearchResultsCreated.Count -ForegroundColor Cyan -NoNewline
Write-Host $(if ($SkipHiddenAppLinks -or $SkipURLProtocols) { "   (跳过)" })

Write-Host "`n------------------------------------------------`n"

if ($Debug) {
    Stop-Transcript
}

if (-not $NoGUI) {
    if (-not $psISE) {
        Write-Host "按任意键退出...`n" -NoNewline
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Read-Host "按回车键退出..."
    }
}
