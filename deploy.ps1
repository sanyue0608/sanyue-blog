# 一键构建 + 打包上传包
#
# 用法：右键「使用 PowerShell 运行」，或在 PowerShell 里执行 .\deploy.ps1
# 作用：用 Node 26 + pnpm 11 构建站点，成功后把 dist/ 压成 dist.zip（可直接拖到 EdgeOne Pages）
#
# 想跳过压缩：.\deploy.ps1 -NoZip

param(
    [switch]$NoZip
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# 1. 选择工具链：优先用便携版 Node 26（与主题要求一致），没有就退回系统 Node
$portable = 'D:\tools\use-node26.ps1'
if (Test-Path $portable) {
    . $portable
    Write-Host "[1/3] 使用便携版工具链 (Node 26 / pnpm 11)" -ForegroundColor Cyan
} else {
    Write-Host "[1/3] 未找到便携版工具链，改用系统 Node：$(node --version)" -ForegroundColor Yellow
}

# 2. 构建
Write-Host "[2/3] 构建中（首次或改了字体/内容会慢一些，约 30-90 秒）..." -ForegroundColor Cyan
& pnpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n构建失败。常见原因：" -ForegroundColor Red
    Write-Host "  - frontmatter 字段写错（报错里会指出是哪个文件的哪一行）" -ForegroundColor Red
    Write-Host "  - 网络抖动导致字体度量下载失败（重跑一次通常就好）" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. 打包
$dist = Join-Path $PSScriptRoot 'dist'
$fileCount = (Get-ChildItem $dist -Recurse -File | Measure-Object).Count
$sizeMB = [math]::Round(((Get-ChildItem $dist -Recurse -File | Measure-Object Length -Sum).Sum / 1MB), 1)
Write-Host "[3/3] 构建完成：$fileCount 个文件，$sizeMB MB" -ForegroundColor Green

if (-not $NoZip) {
    $zip = Join-Path $PSScriptRoot 'dist.zip'
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path (Join-Path $dist '*') -DestinationPath $zip -CompressionLevel Optimal
    $zipMB = [math]::Round((Get-Item $zip).Length / 1MB, 1)
    Write-Host "      上传包：$zip ($zipMB MB)" -ForegroundColor Green
}

# EdgeOne 直接上传的硬限制，提前提醒，别等上传才失败
if ($fileCount -gt 1000) {
    Write-Host "`n注意：文件数超过 1000，EdgeOne「直接上传」会拒绝。改用 Git 构建，或精简 public/ 里的大文件。" -ForegroundColor Yellow
}
$biggest = Get-ChildItem $dist -Recurse -File | Sort-Object Length -Descending | Select-Object -First 1
if ($biggest.Length -gt 25MB) {
    Write-Host "`n注意：$($biggest.Name) 超过 25MB，EdgeOne 单文件上限。建议压缩或外链托管。" -ForegroundColor Yellow
}

Write-Host "`n下一步：把 dist 文件夹（或 dist.zip）拖到 EdgeOne Pages → 新建部署" -ForegroundColor Cyan
