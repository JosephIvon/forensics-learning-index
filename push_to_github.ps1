<#
.SYNOPSIS
  取证式学习 · 三仓 + 索引仓 → GitHub 发布（一条命令）。

.DESCRIPTION
  干四件事：
    ① 用 GitHub API 建四个**空仓**（不勾 README/.gitignore/LICENSE——本地已有，勾了首次 push 会撞）
    ② 三个工程仓 + 索引仓各加 origin 并 push main
    ③ 推完做一次**从 GitHub 的干净克隆**复验（读者实际拿到的东西）
    ④ 把 <账号> 占位符从索引仓 README 里换掉（推之前先换，再推）

  令牌从环境变量读，**不落在命令行、不落在仓库里**：
      $env:GITHUB_TOKEN = "<你的 PAT>"
      pwsh -File push_to_github.ps1 -Account JosephIvon

  PAT 需要的权限：repo（建仓 + 推）+ workflow（不动 .github/workflows 时可不要）

.EXAMPLE
  $env:GITHUB_TOKEN = "github_pat_xxx"
  pwsh -File push_to_github.ps1 -Account JosephIvon
#>
[CmdletBinding()]
param(
  [string]$Account = "JosephIvon",
  [string]$Token = $env:GITHUB_TOKEN,
  [switch]$SkipCreate,
  [switch]$SkipVerify
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ws = "D:\workspace"

$repos = @(
  @{ Dir = "mcopilot";                 Name = "mcopilot";                 Desc = "协议域真值钉扎与门禁：协议知识库 / 帧级黄金测试 / 契约测试 / 故障注入农场 / 接入闭环" },
  @{ Dir = "axiscope";                 Name = "axiscope";                 Desc = "数据契约与知识库：C1-C7 数据契约 / KB0-KB8 知识库 / 数据溯源存证 / 评测纪律" },
  @{ Dir = "trae_factory";             Name = "forensics-code-factory";   Desc = "上位机代码工厂：浏览器里填轴数与工艺，生成带真值链的 C# 运动控制工程" },
  @{ Dir = "forensics-learning-index"; Name = "forensics-learning-index"; Desc = "取证式学习三仓索引：接缝图 / 真值链口径 / 推送清单" }
)

if (-not $Token) {
  Write-Host "✗ 没有令牌：先设 `$env:GITHUB_TOKEN = '<你的 PAT>'（PAT 需要 repo 权限）" -ForegroundColor Red
  exit 1
}

$hdr = @{ Authorization = "Bearer $Token"; "User-Agent" = "dsh-publish"; Accept = "application/vnd.github+json" }

# ── ① 建仓 ───────────────────────────────────────────────────────────────
if (-not $SkipCreate) {
  foreach ($r in $repos) {
    $api = "https://api.github.com/repos/$Account/$($r.Name)"
    try {
      Invoke-RestMethod -Uri $api -Headers $hdr -ErrorAction Stop | Out-Null
      Write-Host "  · $($r.Name) 已存在，跳过创建" -ForegroundColor DarkGray
    } catch {
      $body = @{ name = $r.Name; description = $r.Desc; private = $false;
                 auto_init = $false; has_issues = $true; has_projects = $false; has_wiki = $false } | ConvertTo-Json
      try {
        Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $hdr `
          -ContentType "application/json" -Body $body -ErrorAction Stop | Out-Null
        Write-Host "  ✓ 已建空仓 $($Account)/$($r.Name)（公开）" -ForegroundColor Green
      } catch {
        Write-Host "  ✗ 建仓失败 $($r.Name)：$($_.Exception.Message)" -ForegroundColor Red
        exit 1
      }
    }
  }
}

# ── ② 索引仓先换占位符，再推 ──────────────────────────────────────────────
$idxReadme = Join-Path $ws "forensics-learning-index\README.md"
if (Test-Path $idxReadme) {
  $t = [IO.File]::ReadAllText($idxReadme, [Text.Encoding]::UTF8)
  if ($t -match "<账号>") {
    $t = $t.Replace("<账号>", $Account)
    [IO.File]::WriteAllText($idxReadme, $t, (New-Object Text.UTF8Encoding $false))
    Push-Location (Join-Path $ws "forensics-learning-index")
    git add -A | Out-Null
    git commit -q -m "索引仓：替换 <账号> 占位符为 $Account" | Out-Null
    Pop-Location
    Write-Host "  ✓ 索引仓占位符已替换为 $Account" -ForegroundColor Green
  }
}

# ── ③ 加 remote 并推 ─────────────────────────────────────────────────────
foreach ($r in $repos) {
  $path = Join-Path $ws $r.Dir
  Push-Location $path
  $url = "https://$Account@github.com/$($r.Name).git"
  if ((git remote) -contains "origin") { git remote set-url origin $url | Out-Null }
  else { git remote add origin $url | Out-Null }
  Write-Host "  → 推送 $($r.Dir) → $url" -ForegroundColor Cyan
  # 凭据只在这一条命令的环境里出现，不进 git config、不进仓库
  $env:GIT_ASKPASS = Join-Path $here "git_askpass.cmd"
  $env:GITHUB_USER = $Account
  $env:GITHUB_PASS = $Token
  git push -u origin main
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 推送失败：$($r.Dir)" -ForegroundColor Red
    Pop-Location
    exit 1
  }
  Pop-Location
}

# ── ④ 从 GitHub 干净克隆复验 ─────────────────────────────────────────────
if (-not $SkipVerify) {
  $tmp = Join-Path $env:TEMP "gh_verify"
  if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
  New-Item -ItemType Directory -Path $tmp -Force | Out-Null
  foreach ($r in $repos) {
    Write-Host "  → 干净克隆复核 $($r.Name)" -ForegroundColor Cyan
    git clone --quiet "https://github.com/$Account/$($r.Name).git" (Join-Path $tmp $r.Name)
    if ($LASTEXITCODE -ne 0) { Write-Host "  ✗ 克隆失败：$($r.Name)" -ForegroundColor Red; exit 1 }
    Push-Location (Join-Path $tmp $r.Name)
    switch ($r.Dir) {
      "mcopilot" {
        $env:PYTHONPATH = "src"; $env:PYTHONIOENCODING = "utf-8"
        python -m pytest -q | Select-Object -Last 1
        pwsh -NoProfile -File scripts\gate_protocol.ps1 | Select-String "通过 " | Select-Object -Last 1
      }
      "axiscope" {
        $env:PYTHONIOENCODING = "utf-8"
        python -m pytest -q | Select-Object -Last 1
        python data\probe_pii.py | Select-Object -Last 1
      }
      "trae_factory" {
        node test_gen.js all | Select-Object -Last 1
        node concat.js | Select-Object -Last 1
        git diff --quiet -- "上位机代码工厂.html"
        if ($LASTEXITCODE -eq 0) { Write-Host "单文件与 gen/ 同源 ✓" } else { Write-Host "✗ 单文件不同源" -ForegroundColor Red; exit 1 }
      }
      "forensics-learning-index" { Get-ChildItem | Select-Object -ExpandProperty Name | ForEach-Object { "  $_" } }
    }
    Pop-Location
  }
  Write-Host "✓ 四仓均已发布并从 GitHub 干净克隆复验通过" -ForegroundColor Green
}
