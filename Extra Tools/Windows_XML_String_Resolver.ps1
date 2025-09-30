# Windows XML字符串解析程序
# 作者：ThioJoe
#
# 用途：此脚本接受一个包含字符串引用的XML文件（例如，"@shell32.dll,-1234"）
# 并将其解析为实际的字符串值。它对于处理Windows资源文件或使用类似字符串引用格式的任何XML特别有用
#
# 使用方法：
# 1.打开 PowerShell ，使用 "cd" 命令导航到包含此脚本的路径。
# 2.运行以下命令以允许运行当前会话的脚本：
# Set-ExecutionPolicy -ExecutionPolicy unrestricted -Scope Process
# 3.在不关闭 PowerShell 窗口的情况下，键入以 ".\" 开头的脚本文件名来运行脚本，例如：
# .\Windows_XML_String_Resolver.ps1
# ------------------参数-------------------------
# -XmlFilePath
# 字符串（必填）
# 需要处理的 XML 文件的路径。可以是相对路径或绝对路径。
#
# -CustomResourcePaths
# 字符串数组（可选）
# 为 DLL 或 MUI 文件指定自定义路径。每个条目的格式应为 "dllName=path" 。
# dllName 可以带有或不带有 .dll 扩展名，不区分大小写。
# 示例："shell32=C:\custom\path\shell32.dll", "user32=C:\another\path\user32.mui"
#
# -Debug
# 开关（不接受任何值）
# 在脚本执行期间启用调试输出以获取更详细的信息。
# 显示正在加载的 DLL 的完整路径，并列出所有自定义资源路径。
#
# ---------------------------------------------------------------------
#
# 命令行中的示例用法：
#       .\Windows_XML_String_Resolver.ps1 -XmlFilePath "path\to\your\file.xml" -CustomResourcePaths "shell32=C:\custom\path\shell32.dll", "user32=C:\another\path\user32.mui" -Debug
#
# ---------------------------------------------------------------------

param(
    [string]$XmlFilePath,
    [string[]]$CustomResourcePaths,
    [switch]$Debug
)

# 导入必要的 .NET 类
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class Windows {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern IntPtr LoadLibraryEx(string lpFileName, IntPtr hFile, uint dwFlags);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int LoadString(IntPtr hInstance, uint uID, StringBuilder lpBuffer, int nBufferMax);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool FreeLibrary(IntPtr hModule);
}
"@

# 初始化不区分大小写的哈希表以存储自定义 DLL 路径
$customDllPathMap = New-Object System.Collections.Hashtable([System.StringComparer]::OrdinalIgnoreCase)

# 解析自定义 DLL 路径
if ($CustomResourcePaths) {
    foreach ($pair in $CustomResourcePaths) {
        $parts = $pair -split '='
        if ($parts.Length -eq 2) {
            $dllName = $parts[0].Trim().TrimEnd('.dll')  # 删除 .dll （如果存在）
            $dllPath = $parts[1].Trim()
            $customDllPathMap[$dllName] = $dllPath
        }
        else {
            Write-Warning "自定义DLL路径格式无效: $pair 。 预期格式: 'dllName=path'"
        }
    }
}

function Get-LocalizedString {
    param ( [string]$StringReference )

    if ($StringReference -match '@(.+),-(\d+)') {
        $dllName = $Matches[1].TrimEnd('.dll')  # 删除 .dll （如果存在）
        $resourceId = [uint32]$Matches[2]

        # 检查是否有此 DLL 的自定义路径
        if ($customDllPathMap.ContainsKey($dllName)) {
            $dllPath = $customDllPathMap[$dllName]
        }
        else {
            $dllPath = [Environment]::ExpandEnvironmentVariables($Matches[1])
        }

        if ($Debug) {
            Write-Host "加载 DLL: $dllPath" -ForegroundColor Cyan
        }

        $hModule = [Windows]::LoadLibraryEx($dllPath, [IntPtr]::Zero, 0x00000800) # 将库作为数据文件加载
        if ($hModule -eq [IntPtr]::Zero) {
            $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            Write-Warning "加载库失败: $dllPath. 错误代码: $errorCode"
            return $StringReference
        }

        $stringBuilder = New-Object System.Text.StringBuilder 1024
        $result = [Windows]::LoadString($hModule, $resourceId, $stringBuilder, $stringBuilder.Capacity)

        [void][Windows]::FreeLibrary($hModule)

        if ($result -ne 0) {
            return $stringBuilder.ToString()
        } else {
            $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            Write-Warning "未能从 $dllPath 加载字符串资源：$resourceId 。错误代码: $errorCode"
            return $StringReference
        }
    } else {
        return $StringReference
    }
}

function Resolve-XmlStringReferences {
    param (
        [string]$XmlContent
    )

    $resolvedXml = $XmlContent

    $stringRefPattern = '@[^,]+,-\d+'
    $stringMatches = [regex]::Matches($XmlContent, $stringRefPattern)

    foreach ($match in $stringMatches) {
        $originalString = $match.Value
        $resolvedString = Get-LocalizedString $originalString
        if ($resolvedString -ne $originalString) {
            $resolvedXml = $resolvedXml.Replace($originalString, [System.Security.SecurityElement]::Escape($resolvedString))
        }
    }

    return $resolvedXml
}

# 主脚本逻辑
if (-not $XmlFilePath) {
    $XmlFilePath = Read-Host "请输入 XML 文件的路径"
}

# 删除引号（如果存在）
$XmlFilePath = $XmlFilePath.Trim('"')

if (-not (Test-Path $XmlFilePath)) {
    Write-Error "指定的文件不存在: $XmlFilePath"
    exit 1
}

if ($Debug) {
    Write-Host "自定义 DLL 路径:" -ForegroundColor Yellow
    $customDllPathMap.GetEnumerator() | ForEach-Object {
        Write-Host "$($_.Key) = $($_.Value)" -ForegroundColor Yellow
    }
}

try {
    $xmlContent = Get-Content $XmlFilePath -Raw
    $resolvedXml = Resolve-XmlStringReferences $xmlContent

    $outputPath = [System.IO.Path]::Combine(
        [System.IO.Path]::GetDirectoryName($XmlFilePath),
        [System.IO.Path]::GetFileNameWithoutExtension($XmlFilePath) + "-resolved.xml"
    )

    $resolvedXml | Out-File $outputPath -Encoding UTF8
    Write-Host "已保存解析后的 XML 到: $outputPath"
} catch {
    Write-Error "发生错误: $_"
    exit 1
}