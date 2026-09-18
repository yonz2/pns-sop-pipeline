# translate-local.ps1 — translate, validate and render ONE procedure on this
# machine, without GitHub Actions and without touching any branch.
#
# Usage (PowerShell):
#     . .\scripts\llm-env.ps1                                    # once per shell
#     .\scripts\translate-local.ps1 sop\LAB-ACC-access-authorisation.md
#
#     .\scripts\translate-local.ps1 sop\X.md -Image other:tag     # override image
#
# The PowerShell twin of scripts/translate-local.sh. It runs the same three
# steps in the same order and enforces the same gate —
#
#     translate  ->  validate  ->  render
#
# — writing only to .\out and never publishing. Validation is a GATE, not a
# warning (R1b §4): a rendering that fails the eleven deterministic checks is
# deleted rather than left on disk, because a bad English procedure that exists
# will be read as a procedure.
#
# The Indonesian document remains the source of record; nothing here writes to sop\.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Path,
    [string] $Image = "document-pipeline:latest"
)

$ErrorActionPreference = "Stop"

# Run from the repository root regardless of where the caller stands.
$repo = Split-Path -Parent $PSScriptRoot
Push-Location $repo
try {
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Error "not a file: $Path"; exit 1
    }
    if (-not $env:LLM_ENDPOINT -or -not $env:LLM_MODEL) {
        Write-Host "LLM_ENDPOINT and LLM_MODEL are not set." -ForegroundColor Red
        Write-Host "Run:  . .\scripts\llm-env.ps1"
        exit 2
    }

    # The path the container will see, relative to the repository root and with
    # forward slashes. Windows backslashes are not a container path.
    $full = (Resolve-Path -LiteralPath $Path).Path
    $rel  = $full.Substring($repo.Length).TrimStart('\', '/') -replace '\', '/'
    $base = [System.IO.Path]::GetFileNameWithoutExtension($full)

    New-Item -ItemType Directory -Force -Path (Join-Path $repo "out") | Out-Null

    # Only variables that are actually SET are passed through. `docker run -e VAR`
    # with an empty value sets it to the empty string inside the container, which
    # overrides translate.py's own defaults — an empty LLM_TIMEOUT is not 120, it
    # is a ValueError. Same rule as translate-main.sh.
    $envArgs = @()
    foreach ($v in "LLM_ENDPOINT", "LLM_MODEL", "LLM_API_KEY", "LLM_TIMEOUT",
                   "PROMPT_VERSION", "REVIEWED_BY", "REVIEW_DATE") {
        if ([Environment]::GetEnvironmentVariable($v)) { $envArgs += @("-e", $v) }
    }

    function Invoke-Pipe {
        param([string[]] $PipeArgs)
        $dockerArgs = @("run", "--rm", "--add-host=host.docker.internal:host-gateway") +
                      $envArgs +
                      @("-v", "${repo}:/docs:ro", "-v", "${repo}\out:/out", $Image) +
                      $PipeArgs
        & docker @dockerArgs
        return $LASTEXITCODE
    }

    Write-Host "==> translating $rel  (model: $env:LLM_MODEL)" -ForegroundColor Cyan
    if ((Invoke-Pipe @("translate", "/docs/$rel", "/out/$base.en.md")) -ne 0) {
        Write-Error "translation failed for $base"; exit 1
    }

    Write-Host "==> validating against the source (the eleven checks of R1b section 6)" -ForegroundColor Cyan
    if ((Invoke-Pipe @("validate", "/docs/$rel", "/out/$base.en.md")) -ne 0) {
        Write-Host ""
        Write-Host "VALIDATION FAILED - $base is HELD and its output removed." -ForegroundColor Red
        Write-Host "The rendering did not correspond to the source; it is not kept."
        foreach ($f in "$base.en.md", "$base.en.docx", "$base.en.pdf") {
            Remove-Item -LiteralPath (Join-Path $repo "out\$f") -Force -ErrorAction SilentlyContinue
        }
        exit 1
    }

    Write-Host "==> rendering the English document through the institutional form" -ForegroundColor Cyan
    if ((Invoke-Pipe @("render", "/out/$base.en.md", "/out/$base.en.docx")) -ne 0) {
        Write-Error "render failed for $base"; exit 1
    }

    Write-Host ""
    Write-Host "done:" -ForegroundColor Green
    Get-ChildItem -Path (Join-Path $repo "out") -Filter "$base.en.*" |
        Select-Object Length, Name | Format-Table -AutoSize
}
finally {
    Pop-Location
}
