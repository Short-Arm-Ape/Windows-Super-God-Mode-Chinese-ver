# 检查当前PowerShell环境是否已定义了 "Win32" 类型，如果没有，则添加其定义
# 否则，如果已添加，它将抛出错误，就像有时在不关闭窗口的情况下重新运行脚本一样
# "Win32" 类型提供对某些关键 Windows API 函数的访问
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
}
"@
}

function Get-LocalizedString {
    [CmdletBinding()]
    param (
        [string]$StringReference
    )
    if ($StringReference -match '@\{.+\?ms-resource://.+}') {
        return Get-MsResource $StringReference -Verbose:$VerbosePreference
    }
    elseif ($StringReference -match '@(.+),-(\d+)') {
        $dllPath = [Environment]::ExpandEnvironmentVariables($Matches[1])
        $resourceId = [uint32]$Matches[2]
        return Get-StringFromDll $dllPath $resourceId -Verbose:$VerbosePreference
    }
    else {
        Write-Error "字符串引用格式无效: $StringReference"
        return
    }
}

function Get-MsResource {
    param (
        [string]$ResourcePath
    )
    Write-Verbose "正在尝试检索资源: $ResourcePath"
    $stringBuilder = New-Object System.Text.StringBuilder 1024
    $result = [Win32]::SHLoadIndirectString($ResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
    if ($result -eq 0) {
        Write-Verbose "成功在第一次尝试中检索资源"
        return $stringBuilder.ToString()
    } else {
        Write-Verbose "初始尝试失败，错误代码: $result. 尝试其他方法..."

        # 提取包名称和资源URI
        $packageFullName = ($ResourcePath -split '\?')[0].Trim('@{}')
        $resourceUri = ($ResourcePath -split '\?')[1]
        Write-Verbose "提取的包完整名称: $packageFullName"
        Write-Verbose "提取的资源 URI: $resourceUri"

        # 提取不带版本和体系结构的包名称
        $packageName = ($packageFullName -split '_')[0]
        Write-Verbose "提取的包名称: $packageName"

        # 查找包安装路径
        $package = Get-AppxPackage | Where-Object { $_.Name -eq $packageName }
        if (-not $package) {
            # 如果完全匹配失败，请尝试按包族名称进行匹配
            $packageFamilyName = ($packageFullName -split '_')[-1]
            $package = Get-AppxPackage | Where-Object { $_.PackageFamilyName -eq "${packageName}_$packageFamilyName" }
        }

        if ($package) {
            $packagePath = $package.InstallLocation
            Write-Verbose "包安装路径: $packagePath"
            $priPath = Join-Path $packagePath "resources.pri"
            Write-Verbose "尝试使用 resources.pri: $priPath"
            if (Test-Path $priPath) {
                $newResourcePath = "@{" + $priPath + "?" + $resourceUri
                Write-Verbose "新资源路径: $newResourcePath"
                $result = [Win32]::SHLoadIndirectString($newResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
                if ($result -eq 0) {
                    Write-Verbose "成功使用 resources.pri 检索资源"
                    return $stringBuilder.ToString()
                }
                Write-Error "使用 resources.pri 检索资源失败。错误代码: $result"
            } else {
                Write-Verbose "未找到预期位置的 resources.pri"
            }
        } else {
            Write-Verbose "未找到包"
        }

        # 如果仍然失败，请尝试不使用 /resources/ 文件夹
        $resourceUriWithoutResources = $resourceUri -replace '/resources/', '/'
        $newResourcePath = "@{" + $priPath + "?" + $resourceUriWithoutResources
        Write-Verbose "尝试不使用 /resources/ 文件夹。新路径: $newResourcePath"
        $result = [Win32]::SHLoadIndirectString($newResourcePath, $stringBuilder, $stringBuilder.Capacity, [IntPtr]::Zero)
        if ($result -eq 0) {
            Write-Verbose "成功检索不带 /resources/ 文件夹的资源"
            return $stringBuilder.ToString()
        }
        Write-Host "未能检索不带 /resources/ 文件夹的资源。错误代码: $result"

        Write-Error "未能检索 ms-resource: $ResourcePath。错误代码: $result"
        return $null
    }
}

function Get-StringFromDll {
    [CmdletBinding()]
    param (
        [string]$DllPath,
        [uint32]$ResourceId
    )
    Write-Verbose "正在尝试从 DLL 加载字符串: $DllPath, 资源 ID: $ResourceId"
    $hModule = [Win32]::LoadLibrary($DllPath)
    if ($hModule -eq [IntPtr]::Zero) {
        Write-Error "未能加载库: $DllPath"
        return
    }

    $stringBuilder = New-Object System.Text.StringBuilder 1024
    $result = [Win32]::LoadString($hModule, $ResourceId, $stringBuilder, $stringBuilder.Capacity)

    if ($result -ne 0) {
        Write-Verbose "已成功从 DLL 加载字符串"
        return $stringBuilder.ToString()
    } else {
        Write-Error "未能从 $DllPath 加载字符串资源: $ResourceId"
    }
}

Write-Host "在任意时刻输入 x 退出程序。"
while ($true) {
    Write-Verbose "详细模式。"
    Write-Host "`n------------------------------------------------------------------------"
    Write-Host "输入要获取的字符串资源引用。（输入 x 退出）"
    Write-Host " > 示例 1: @%SystemRoot%\system32\shell32.dll,-9227"
    Write-Host " > 示例 2: @{windows?ms-resource://Windows.UI.SettingsAppThreshold/SearchResources/SystemSettings_CapabilityAccess_Gaze_UserGlobal/Description}"
    Write-Host " > 示例 3: @{Microsoft.SecHealthUI_8wekyb3d8bbwe?ms-resource://Microsoft.SecHealthUI/Resources/AccountTileMenuEntryAndTitle}"
    Write-Host "`n资源引用:  " -NoNewline
    $userInput = Read-Host
    if ($userInput.ToLower() -eq 'x') {
        Write-Host "程序已退出。再见！"
        break
    }
    $localizedString = Get-LocalizedString $userInput
    if ($localizedString) {
        Write-Host "`n   返回值: " -NoNewline
        Write-Host $localizedString -ForegroundColor Yellow
    }
}