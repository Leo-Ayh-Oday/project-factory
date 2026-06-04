# Detect user corrections from UserPromptSubmit hook stdin JSON
$stdin = [Console]::In.ReadToEnd()
if (-not $stdin) { exit 0 }

try {
    $data = $stdin | ConvertFrom-Json
    $prompt = $data.prompt
    if (-not $prompt) { exit 0 }

    if ($prompt -match '(?:不对|错了|不要|不要这样|不是|no|wrong|broken|fix)') {
        $msg = "[openwolf] Correction detected: `"$($prompt.Substring(0, [Math]::Min(80, $prompt.Length)))`" — suggest cerebrum Do-Not-Repeat"
        Write-Output $msg
    }
} catch { exit 0 }
