function Export-NcJson {
    param(
        [Parameter(Mandatory)] $Object,
        [Parameter(Mandatory)] [string] $ExportFolder,
        [Parameter(Mandatory)] [string] $BaseName
    )
    if (-not (Test-Path -LiteralPath $ExportFolder)) { New-Item -ItemType Directory -Path $ExportFolder -Force | Out-Null }
    $path = Join-Path $ExportFolder "$BaseName.json"
    $Object | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

function Export-NcCsv {
    param(
        [Parameter(Mandatory)] $Object,
        [Parameter(Mandatory)] [string] $ExportFolder,
        [Parameter(Mandatory)] [string] $BaseName
    )
    if (-not (Test-Path -LiteralPath $ExportFolder)) { New-Item -ItemType Directory -Path $ExportFolder -Force | Out-Null }
    $path = Join-Path $ExportFolder "$BaseName.csv"
    $Object | Export-Csv -NoTypeInformation -LiteralPath $path -Encoding UTF8
    return $path
}

function Export-NcText {
    param(
        [Parameter(Mandatory)] [string] $Text,
        [Parameter(Mandatory)] [string] $ExportFolder,
        [Parameter(Mandatory)] [string] $BaseName
    )
    if (-not (Test-Path -LiteralPath $ExportFolder)) { New-Item -ItemType Directory -Path $ExportFolder -Force | Out-Null }
    $path = Join-Path $ExportFolder "$BaseName.txt"
    $Text | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

function Copy-NcText {
    param([Parameter(Mandatory)][string] $Text)
    try {
        if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
            Set-Clipboard -Value $Text
        }
        else {
            $Text | clip.exe
        }
    } catch {}
}
