# llm-env.ps1 — set the translation pipeline's model configuration for LOCAL use.
#
#   DOT-SOURCE it, do not run it:
#
#       . .\scripts\llm-env.ps1
#
# The PowerShell twin of scripts/llm-env.sh; see that file for the reasoning.
# The short version: the model endpoint is a configuration value (R3 §8.1) held
# nowhere in the repository. In CI it comes from GitHub repository variables and
# secrets; locally it comes from your shell. There is no .env file and nothing
# in the pipeline reads one.

# Ollama, two routes. Both probed from this machine on 2026-09-18. THE MODEL ID
# DIFFERS BETWEEN THEM, which is the easy mistake:
#
#   A. LOCAL OLLAMA, proxying the cloud model   <-- the default below
#        endpoint  http://host.docker.internal:11434/v1
#        model     deepseek-v4.1-flash:cloud     (WITH the cloud suffix)
#        key       none needed -- `ollama signin` holds the ollama.com
#                  credential on this machine and Ollama forwards the call
#      EVERY cloud model needs the suffix on this route; it is what tells the
#      local Ollama to proxy rather than look for a pulled model. A model that
#      already carries a tag takes it with a hyphen: 'gpt-oss:120b-cloud'.
#      Without it the call returns 404 'model not found'.
#
#   B. OLLAMA CLOUD, called directly
#        endpoint  https://ollama.com/v1
#        model     deepseek-v4.1-flash           (NO :cloud suffix -- that is
#                                                 the LOCAL Ollama's marker for
#                                                 a proxied model)
#        key       REQUIRED -- /v1/chat/completions returns 401 without one
#
# Route A is the default because it keeps the key off this repository entirely.
# For route B put all three lines in scripts\llm-env.local.
#
# The endpoint is what the CONTAINER sees — not localhost, which inside a
# container is the container. Must be the BASE url ending at /v1: translate.py
# appends "/chat/completions".
if (-not $env:LLM_ENDPOINT)   { $env:LLM_ENDPOINT   = "http://host.docker.internal:11434/v1" }
if (-not $env:LLM_MODEL)      { $env:LLM_MODEL      = "deepseek-v4.1-flash:cloud" }

# translate.py defaults to 120s; a whole procedure through a reasoning model
# needs longer, and a timeout surfaces as a HELD document rather than an error.
if (-not $env:LLM_TIMEOUT)    { $env:LLM_TIMEOUT    = "900" }
if (-not $env:PROMPT_VERSION) { $env:PROMPT_VERSION = "1.0" }

# REVIEWED_BY / REVIEW_DATE are deliberately left unset: they name whoever
# signed off the English rendering, and a local test run is not a review.

# No API key is needed for a ":cloud" model through a local Ollama — `ollama
# signin` holds the credential on this machine and Ollama proxies the call.
# Put any real secret in scripts\llm-env.local (git-excluded):  LLM_API_KEY=...
$localFile = Join-Path $PSScriptRoot "llm-env.local"
if (Test-Path $localFile) {
    Get-Content $localFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $parts = $line.Split("=", 2)
            Set-Item -Path ("env:" + $parts[0].Trim()) -Value $parts[1].Trim()
        }
    }
    Write-Host "loaded overrides from scripts\llm-env.local"
}

Write-Host "LLM_ENDPOINT   = $env:LLM_ENDPOINT"
Write-Host "LLM_MODEL      = $env:LLM_MODEL"
Write-Host "LLM_TIMEOUT    = $env:LLM_TIMEOUT"
Write-Host "PROMPT_VERSION = $env:PROMPT_VERSION"
if ($env:LLM_API_KEY) {
    Write-Host "LLM_API_KEY    = (set, $($env:LLM_API_KEY.Length) chars)"
} else {
    Write-Host "LLM_API_KEY    = (unset - correct for a local Ollama)"
}
