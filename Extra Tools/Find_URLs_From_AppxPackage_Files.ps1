# 此脚本通过每个已安装的 AppxPackage 的 AppxManifest.xml 文件获取其URI协议，然后在应用程序安装目录中的所有文件中暴力搜索这些URI。

# 获取应用程序详细信息的函数，包括URI协议和安装路径
function Get-AppDetails {
    $result = [System.Collections.ArrayList]@()
    foreach ($appx in Get-AppxPackage) {
        $location = $appx.InstallLocation
        $manifest = "$location\AppxManifest.xml"
        if ($null -ne $location -and (Test-Path $manifest -PathType Leaf)) {
            [xml]$xml = Get-Content $manifest
            $ns = New-Object Xml.XmlNamespaceManager $xml.NameTable
            $ns.AddNamespace("main", "http://schemas.microsoft.com/appx/manifest/foundation/windows10")
            $ns.AddNamespace("uap", "http://schemas.microsoft.com/appx/manifest/uap/windows10")
            $ns.AddNamespace("uap2", "http://schemas.microsoft.com/appx/manifest/uap/windows10/2")
            $ns.AddNamespace("uap3", "http://schemas.microsoft.com/appx/manifest/uap/windows10/3")
            $ns.AddNamespace("uap4", "http://schemas.microsoft.com/appx/manifest/uap/windows10/4")
            $ns.AddNamespace("uap5", "http://schemas.microsoft.com/appx/manifest/uap/windows10/5")

            $uapNamespaces = @("uap", "uap2", "uap3", "uap4", "uap5")
            $uriXpathQuery = ($uapNamespaces | ForEach-Object {
                "//$_`:Extension[@Category = 'windows.protocol']/$_`:Protocol/@Name"
            }) -join ' | '

            $uris = $xml.SelectNodes($uriXpathQuery, $ns) | Select-Object -ExpandProperty '#text'

            if ($uris.Count -gt 0) {
                $tmp = [PSCustomObject]@{
                    Name = $appx.Name
                    URIs = $uris
                    Folder = $appx.InstallLocation
                }
                $null = $result.Add($tmp)
            }
        }
    }
    return $result
}

# 为不同的文件扩展名定义编码映射
$encodingMap = @{
    ".txt"  = "UTF-8"
    ".xml"  = "UTF-8"
    ".json" = "UTF-8"
    ".dll"  = "Unicode"
    ".exe"  = "Unicode"
    ".js"   = "UTF-8"
    ".map"  = "UTF-8"
    # 根据需要添加更多映射
}

function Get-ProtocolsInFile {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$protocolsList,
        [Parameter(Mandatory=$true)]
        [string]$filePathToCheck,
        [Parameter(Mandatory=$true)]
        [hashtable]$encodingMap
    )

    if (-not (Test-Path $filePathToCheck)) {
        Write-Error "未找到文件: $filePathToCheck"
        return $null
    }

    $results = @{}
    $fileExtension = [System.IO.Path]::GetExtension($filePathToCheck).ToLower()
    $encodingsToTry = @()

    if ($encodingMap.ContainsKey($fileExtension)) {
        $encodingsToTry += $encodingMap[$fileExtension]
    } else {
        $encodingsToTry += "UTF-8", "Unicode"
    }

    foreach ($encodingName in $encodingsToTry) {
        $encoding = [System.Text.Encoding]::GetEncoding($encodingName)

        try {
            $content = [System.IO.File]::ReadAllText($filePathToCheck, $encoding)

            foreach ($protocol in $protocolsList) {
                # UTF-8和Unicode的不同模式
                if ($encodingName -eq "UTF-8") {
                    $uriPattern = [regex]::Escape($protocol) + "://[^""\s<>()\\``]+"
                } else {
                    $uriPattern = [regex]::Escape($protocol) + "://[\x20-\x7E]+"
                }

                $matches = [regex]::Matches($content, $uriPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

                if ($matches.Count -gt 0) {
                    # 将匹配项与使用的编码和其他数据一起存储
                    $results[$protocol] = @($matches | ForEach-Object {
                        # 如果匹配包含括号或以等号结束，将其标记为 "UsesVariables"
                        $usesVariables = $_.Value -match "[<>()\[\]]|=$"

                        [PSCustomObject]@{
                            FullURL = $_.Value
                            EncodingUsed = $encodingName
                            UsesVariables = $usesVariables
                        }
                    })
                }
            }

            # 如果找到匹配项，则无需尝试其他编码
            if ($results.Count -gt 0) {
                break
            }
        }
        catch {
            Write-Warning "使用 $encodingName 编码处理文件 $filePathToCheck 时出错: $_"
        }
    }

    return @{
        FilePath = $filePathToCheck
        Matches = $results
    }
}


function OutputCSV {
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$data,
        [Parameter(Mandatory=$true)]
        [string]$outputPath
    )

    try {
        $data | Export-Csv -Path $outputPath -NoTypeInformation
        Write-Host "结果导出至: $outputPath"
    }
    catch {
        Write-Error "导出至 CSV 时出错: $_"
        $outputPath = Read-Host "`n输入 CSV 文件保存路径"
        $outputPath = $outputPath.Trim('"')
        if (-not (Test-Path $outputPath)) {
            New-Item -Path $outputPath -ItemType File -Force | Out-Null
        }
        $data | Export-Csv -Path $outputPath -NoTypeInformation
        Write-Host "如果没有错误，则将结果导出到: $outputPath"
    }
}

# 主脚本执行
$appDetails = Get-AppDetails

$results = @()
$searchedFiles = @()

# 定义忽略的文件扩展名
$ignoredExtensions = @(
    # 图像
    '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.svg', ".ico",
    # 其他不相关的文件类型
    ".p7x", ".ttf", ".onnxe",
    # 压缩或其他不产生可靠结果的文件
    ".bundle", '.vsix'
)

# 主脚本执行
$appDetails = Get-AppDetails

$results = @()
$searchedFiles = @()

$totalFiles = ($appDetails | ForEach-Object {
    Get-ChildItem -Path $_.Folder -Recurse -File | Where-Object { $_.Extension -notin $ignoredExtensions }
}).Count

$processedFiles = 0
$lastPercentage = -1  # 初始化为 -1 以确保初始显示 0%
$processedFiles = 0
$currentPercentage = 0

foreach ($app in $appDetails) {
    Write-Verbose "`r搜索 $($app.Name) | URIs: $($app.URIs -join ', ')"
    $files = Get-ChildItem -Path $app.Folder -Recurse -File | Where-Object { $_.Extension -notin $ignoredExtensions }
    foreach ($file in $files) {
        $searchedFiles += $file.FullName
        $fileResults = Get-ProtocolsInFile -protocolsList $app.URIs -filePathToCheck $file.FullName -encodingMap $encodingMap
        if ($fileResults -and $fileResults.Matches.Count -gt 0) {
            $results += $fileResults
        }
        $processedFiles++
        $currentPercentage = [math]::Floor(($processedFiles / $totalFiles) * 100)
        if ($currentPercentage -ne $lastPercentage) {
            Write-Host "`r进度: $currentPercentage%" -NoNewline
            $lastPercentage = $currentPercentage
        }
    }
}

Write-Host "`n处理完毕.$(" " * $paddingLength)"

# 准备 CSV 导出数据
$csvData = @()
foreach ($result in $results) {
    if ($result -and $result.Matches) {
        foreach ($protocol in $result.Matches.Keys) {
            foreach ($match in $result.Matches[$protocol]) {
                $csvData += [PSCustomObject]@{
                    FilePath = $result.FilePath
                    Protocol = $protocol
                    FullURL = $match.FullURL
                    EncodingUsed = $match.EncodingUsed
                    UsesVariables = $match.UsesVariables
                }
            }
        }
    }
}

# 如果输出目录不存在，则创建该目录
$outputDir = ".\ProtocolMatches"
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

# 获取用于输出文件名的日期
$date = Get-Date -Format 'yyyyMMdd_HHmmss'

# 导出搜索的文件列表
$searchedFilesPath = Join-Path $outputDir "files_searched_$date.txt"
$searchedFiles | Out-File -FilePath $searchedFilesPath -Encoding utf8

# 导出至 CSV
$outputPath = Join-Path $outputDir "protocol_matches_$date.csv"

OutputCSV -data $csvData -outputPath $outputPath

Write-Host "搜索的文件列表导出至: $searchedFilesPath"
Write-Host "协议匹配导出至: $outputPath"
