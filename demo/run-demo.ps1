[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $repoRoot

$contentPath = Join-Path $repoRoot 'site\content.json'
$actionsUrl = 'https://github.com/venketraj/kls-cicd-demo/actions'
$liveUrl = 'https://venketraj.github.io/kls-cicd-demo/'
$requirementPath = Join-Path $repoRoot 'requirements\REQ-001-call-to-action.md'
$baselineRaw = [System.IO.File]::ReadAllText($contentPath, [System.Text.Encoding]::UTF8)
$baselineContent = $baselineRaw | ConvertFrom-Json

function Confirm-Step {
  param([string]$Message)
  $answer = Read-Host "$Message [y/N]"
  return $answer -match '^(y|yes)$'
}

function Invoke-Git {
  param([string[]]$GitArgs)
  & git @GitArgs
  if ($LASTEXITCODE -ne 0) {
    throw "git $($GitArgs -join ' ') failed with exit code $LASTEXITCODE."
  }
}

function Write-Utf8File {
  param([string]$Path, [string]$Text)
  [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Invoke-Tests {
  & npm test
  if ($LASTEXITCODE -ne 0) {
    throw 'npm test failed.'
  }
}

function Find-FreePort {
  foreach ($candidate in @(8080, 8081)) {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $candidate)
    try {
      $listener.Start()
      return $candidate
    }
    catch {
    }
    finally {
      $listener.Stop()
    }
  }
  throw 'Ports 8080 and 8081 are both in use.'
}

if ((& git branch --show-current) -ne 'main') {
  throw 'Run this demo from the main branch.'
}
if ((& git remote get-url origin) -ne 'https://github.com/venketraj/kls-cicd-demo.git') {
  throw 'The origin remote is not the expected demo repository.'
}
& git diff --quiet
if ($LASTEXITCODE -ne 0) { throw 'Commit or discard tracked changes before starting the demo.' }
& git diff --cached --quiet
if ($LASTEXITCODE -ne 0) { throw 'The Git index must be clean before starting the demo.' }
if ($baselineContent.headline -ne 'Hello KLS!' -or $baselineContent.ctaText) {
  throw 'The site is not at the original baseline. Reset it before starting the demo.'
}
if (-not (Get-Command git -ErrorAction SilentlyContinue) -or -not (Get-Command npm -ErrorAction SilentlyContinue)) {
  throw 'Git and Node.js/npm must be installed and available in PATH.'
}

Write-Host 'Starting the three-part CI/CD demo from the original Hello KLS! baseline.'
Write-Host 'Part 1 runs locally. Parts 2 and 3 require your confirmation before pushing to main.'

$pythonCommand = Get-Command py -ErrorAction SilentlyContinue
if ($pythonCommand) {
  $pythonPath = ((& $pythonCommand.Source -c 'import sys; print(sys.executable)') -join '').Trim()
  if ($LASTEXITCODE -ne 0) { throw 'Could not locate the Python interpreter through py.' }
}
else {
  $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
  if (-not $pythonCommand) { throw 'Python is required to serve the local Part 1 demo.' }
  $pythonPath = $pythonCommand.Source
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "kls-cicd-demo-$PID"
$webRoot = Join-Path $tempRoot 'www'
New-Item -ItemType Directory -Path $webRoot -Force | Out-Null
$server = $null
try {
  $stagedContent = $baselineContent | Select-Object *
  $stagedContent.headline = 'CI/CD is magic'
  $brokenJson = $stagedContent | ConvertTo-Json -Depth 10
  $brokenJson = $brokenJson -replace '("headline"\s*:\s*"CI/CD is magic")\s*,', '$1'
  if ($brokenJson -eq ($stagedContent | ConvertTo-Json -Depth 10)) {
    throw 'Could not prepare the intentional JSON syntax error.'
  }
  Write-Utf8File (Join-Path $webRoot 'content.json') $brokenJson
  Copy-Item (Join-Path $repoRoot 'site\index.html') $webRoot -Force

  $port = Find-FreePort
  $stdout = Join-Path $tempRoot 'server.out.log'
  $stderr = Join-Path $tempRoot 'server.err.log'
  $server = Start-Process -FilePath $pythonPath `
    -ArgumentList "-m http.server $port --directory `"$webRoot`"" `
    -PassThru -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr
  $localUrl = "http://localhost:$port"
  $ready = $false
  for ($attempt = 0; $attempt -lt 20; $attempt++) {
    try {
      $null = Invoke-WebRequest -Uri $localUrl -UseBasicParsing -TimeoutSec 1
      $ready = $true
      break
    }
    catch {
    }
  }
  if (-not $ready) { throw "The local demo server did not start. See $stderr" }

  Write-Host "Part 1: the intentionally broken manual release is at $localUrl"
  Start-Process $localUrl
  Read-Host 'Show the broken page, then press Enter to continue'
}
finally {
  if ($server -and -not $server.HasExited) { Stop-Process -Id $server.Id -Force }
  Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

if (Confirm-Step 'Part 2 will commit and push invalid JSON to main, causing tests to fail while the live site stays unchanged. Continue?') {
  $part2Started = $false
  $brokenCommitCreated = $false
  try {
    $stagedContent = $baselineContent | Select-Object *
    $stagedContent.headline = 'CI/CD is magic'
    $validJson = $stagedContent | ConvertTo-Json -Depth 10
    $brokenJson = $validJson -replace '("headline"\s*:\s*"CI/CD is magic")\s*,', '$1'
    if ($brokenJson -eq $validJson) { throw 'Could not prepare the intentional JSON syntax error.' }
    Write-Utf8File $contentPath $brokenJson
    $part2Started = $true

    Write-Host 'The next test failure is intentional.'
    $testOutput = & npm test 2>&1
    $testExitCode = $LASTEXITCODE
    $testOutput | ForEach-Object { Write-Host $_ }
    if ($testExitCode -eq 0) { throw 'Expected npm test to fail for invalid JSON, but it passed.' }

    Invoke-Git -GitArgs @('add', '--', 'site/content.json')
    Invoke-Git -GitArgs @('commit', '-m', 'Demo: intentionally break content JSON')
    $brokenCommitCreated = $true
    Invoke-Git -GitArgs @('push', 'origin', 'main')

    Write-Host "Watch the failing run: $actionsUrl"
    Write-Host "The live site should remain unchanged: $liveUrl"
    Start-Process $actionsUrl
    Start-Process $liveUrl
    Read-Host 'After Run tests fails and Deploy is skipped, press Enter to restore the valid baseline'

    Write-Utf8File $contentPath $baselineRaw
    Invoke-Tests
    Invoke-Git -GitArgs @('add', '--', 'site/content.json')
    Invoke-Git -GitArgs @('commit', '-m', 'Demo: restore valid content')
    Invoke-Git -GitArgs @('push', 'origin', 'main')
    $part2Started = $false
    Write-Host 'Part 2 is repaired and the passing deployment has been triggered.'
  }
  finally {
    if ($part2Started) {
      Write-Warning 'Recovering the original valid content before stopping.'
      Write-Utf8File $contentPath $baselineRaw
      Invoke-Tests
      & git diff --quiet -- site/content.json
      if ($LASTEXITCODE -ne 0) {
        Invoke-Git -GitArgs @('add', '--', 'site/content.json')
        Invoke-Git -GitArgs @('commit', '-m', 'Demo: restore valid content')
      }
      if ($brokenCommitCreated) { Invoke-Git -GitArgs @('push', 'origin', 'main') }
    }
  }
}
else {
  Write-Host 'Part 2 skipped.'
}

if (Confirm-Step 'Part 3 opens the requirement for your coding agent. After its edits pass tests, this script will commit and push them. Continue?') {
  Write-Host 'In Copilot Agent mode or Claude Code, use this prompt:'
  Write-Host 'Implement requirements/REQ-001-call-to-action.md following AGENTS.md. Do not commit or push; the demo script will do that after tests pass.'
  $codeCommand = Get-Command code -ErrorAction SilentlyContinue
  if ($codeCommand) { Start-Process -FilePath $codeCommand.Source -ArgumentList @('--reuse-window', $requirementPath) }
  Read-Host 'When the agent has finished editing, press Enter to run tests and publish'

  Invoke-Tests
  $newContent = [System.IO.File]::ReadAllText($contentPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
  $expectedCtaText = [string][char]0x2B50 + ' Get the starter repo'
  $html = [System.IO.File]::ReadAllText((Join-Path $repoRoot 'site\index.html'), [System.Text.Encoding]::UTF8)
  $testSource = [System.IO.File]::ReadAllText((Join-Path $repoRoot 'test\site.test.js'), [System.Text.Encoding]::UTF8)
  if ($newContent.ctaText -ne $expectedCtaText -or $newContent.ctaUrl -ne 'https://github.com/venketraj/kls-cicd-demo') {
    throw 'The CTA content does not match REQ-001.'
  }
  if ($newContent.ctaText.Length -gt 25 -or $html -notmatch 'min-height:\s*44px') {
    throw 'The CTA text length or tap-target height does not meet REQ-001.'
  }
  foreach ($marker in @('ctaText', 'ctaUrl', 'target="_blank"', 'min-height', '25')) {
    if ($testSource -notlike "*$marker*") { throw "The automated tests do not cover '$marker'." }
  }

  & git diff --quiet -- site/content.json site/index.html test/site.test.js
  $worktreeChanged = $LASTEXITCODE -ne 0
  & git diff --cached --quiet -- site/content.json site/index.html test/site.test.js
  $indexChanged = $LASTEXITCODE -ne 0
  if (-not ($worktreeChanged -or $indexChanged)) { throw 'No REQ-001 changes found in the expected files.' }
  Invoke-Git -GitArgs @('add', '--', 'site/content.json', 'site/index.html', 'test/site.test.js')
  Invoke-Git -GitArgs @('commit', '-m', 'REQ-001: add call-to-action button')
  Invoke-Git -GitArgs @('push', 'origin', 'main')
  Write-Host "Part 3 is pushed. Watch tests and deployment at $actionsUrl"
  Start-Process $actionsUrl
  Start-Process $liveUrl
}
else {
  Write-Host 'Part 3 skipped.'
}

Write-Host 'Demo script finished.'