# Quick session-end check for openwolf
# Reads .wolf/.edit-log.jsonl and flags files edited >=2 times
$wolfDir = Join-Path $env:USERPROFILE ".claude\.wolf"
$logFile = Join-Path $wolfDir ".edit-log.jsonl"

Write-Host "`n[openwolf] Session check..." -ForegroundColor Cyan

# Check edit log
if (Test-Path $logFile) {
    $edits = Get-Content $logFile | ForEach-Object { $_ | ConvertFrom-Json }
    $grouped = $edits | Group-Object file | Where-Object { $_.Count -ge 2 }
    if ($grouped) {
        Write-Host "[openwolf] Files edited >=2 times (potential bugs):" -ForegroundColor Yellow
        $grouped | ForEach-Object { Write-Host "  $($_.Name) ($($_.Count)x)" }
    }
    # Clean up for next session
    Remove-Item $logFile -Force
}

# Check anatomy existence
$anatomy = Join-Path $wolfDir "anatomy.md"
if (-not (Test-Path $anatomy)) {
    Write-Host "[openwolf] No anatomy.md found — run /openwolf check" -ForegroundColor Yellow
}

# Check buglog
$buglog = Join-Path $wolfDir "buglog.json"
if (Test-Path $buglog) {
    $bugs = Get-Content $buglog | ConvertFrom-Json
    Write-Host "[openwolf] $(($bugs | Measure-Object).Count) bugs in log" -ForegroundColor Gray
}

Write-Host "[openwolf] Done.`n" -ForegroundColor Cyan
