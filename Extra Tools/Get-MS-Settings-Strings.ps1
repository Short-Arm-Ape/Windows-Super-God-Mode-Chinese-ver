# 此脚本将在DLL文件中查找 "ms-settings:" 的文本字符串，并将其输出到文本文件。
# 应在 C:\Windows\ImmersiveControlPanel\ 中的 "SystemSettings.dll" 上运行
#
# 可选参数:
#    -DllPath: 要搜索的DLL文件的路径
#    -OutputFilePath: 输出文本文件的路径
#
# 如果没有提供参数，脚本将提示用户输入DLL文件路径，并将文本文件结果输出到与脚本相同的目录
#
# 示例用法:
#    .\Get-MS-Settings-Strings.ps1 -DllPath "C:\Windows\ImmersiveControlPanel\SystemSettings.dll" -OutputFilePath "SystemSettings-MS-Settings.txt"
#

param (
    [string]$DllPath,
    [string]$OutputFilePath
)

function Get-DllMsSettings {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DllPath
    )

    if (-not (Test-Path $DllPath)) {
        Write-Error "未找到文件: $DllPath"
        return @()
    }

    $content = [System.IO.File]::ReadAllText($DllPath, [System.Text.Encoding]::Unicode)
    $results = New-Object System.Collections.Generic.HashSet[string]

    $matches = [regex]::Matches($content, 'ms-settings:[a-z-]+')
    foreach ($match in $matches) {
        [void]$results.Add($match.Value)
    }

    Write-Host "找到唯一匹配项: $($results.Count)"
    return $results | Sort-Object
}

# 如果没有提供DLL路径的参数，则提示用户
if (-not $DllPath) {
    Write-Host "`n请输入 DLL 文件的路径。或者按回车键使用默认路径: C:\Windows\ImmersiveControlPanel\SystemSettings.dll"
    $DllPath = Read-Host "`n输入路径"
    if (-not $DllPath) {
        Write-Host "使用默认路径: C:\Windows\ImmersiveControlPanel\SystemSettings.dll"
        $DllPath = "C:\Windows\ImmersiveControlPanel\SystemSettings.dll"
    }
}
# 检查 DLL 文件的路径
if (-not (Test-Path $DllPath)) {
    Write-Error "未找到文件: $DllPath"
    return
}

# 如果没有提供输出路径参数，则根据输入文件名设置文本文件，位于与脚本工作目录相同的目录中
if (-not $OutputFilePath) {
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($DllPath)
    $OutputFilePath = [System.IO.Path]::Combine($PSScriptRoot, "$fileName-MS-Settings.txt")
} else {
    # 检查它是相对路径还是绝对路径，如果是相对路径，则相对于脚本进行处理
    if (-not [System.IO.Path]::IsPathRooted($OutputFilePath)) {
        $OutputFilePath = [System.IO.Path]::Combine($PSScriptRoot, $OutputFilePath)
    }
}

# 调用主功能
Write-Host "`n开始搜索...`n"
$results = Get-DllMsSettings -DllPath $DllPath

# 将结果输出到文本文件
$results | Out-File -FilePath $OutputFilePath

Write-Host "结果已写入文件: $OutputFilePath`n"