# Track file edits for openwolf — reads hook JSON from stdin, logs to .wolf/.edit-log.jsonl
$stdin = [Console]::In.ReadToEnd()
if (-not $stdin) { exit 0 }

try {
    $data = $stdin | ConvertFrom-Json
    $filePath = $data.tool_input.file_path
    if (-not $filePath) { exit 0 }

    $wolfDir = Join-Path $env:USERPROFILE ".claude\.wolf"
    if (-not (Test-Path $wolfDir)) { New-Item -ItemType Directory -Path $wolfDir -Force | Out-Null }

    $logFile = Join-Path $wolfDir ".edit-log.jsonl"
    $entry = @{
        file = $filePath -replace [regex]::Escape("$env:USERPROFILE\"), ""
        tool = $data.tool_name
        time = (Get-Date -Format "o")
    } | ConvertTo-Json -Compress

    Add-Content -Path $logFile -Value $entry
} catch {
    # Silently ignore parse errors
    exit 0
}
