<#
.SYNOPSIS
Prueft erzeugte Assurance-Befehle in einem isolierten Projekt.
Tests generated assurance commands in an isolated project.
.DESCRIPTION
Installiert ausschliesslich in einem neuen temporaeren Git-Projekt. Prueft
alle vier Agentenoberflaechen und fuehrt deren Validatorpfade ohne Evidence aus.
Installs only into a new temporary Git project. Checks all four agent surfaces
and executes their validator paths against deliberately missing evidence.
.PARAMETER ArchiveUrl
Optionales HTTPS-Release-ZIP statt der lokalen Preset-Quelle.
Optional HTTPS release archive instead of the local preset source.
.EXAMPLE
pwsh -NoProfile -File tests/test-installed-surfaces.ps1
#>
[CmdletBinding()]
param(
    [ValidatePattern('^https://')][string]$ArchiveUrl = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$presetRoot = Split-Path -Parent $PSScriptRoot
$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ('sda-install-' + [guid]::NewGuid().ToString('N'))

function Invoke-SDAInstalledCommand {
    param(
        [Parameter(Mandatory)][string]$Executable,
        [Parameter(Mandatory)][string[]]$ArgumentList,
        [int]$ExpectedExitCode = 0
    )
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $Executable
    $info.WorkingDirectory = $temporaryRoot
    $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in $ArgumentList) { $null = $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::Start($info)
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit(120000)) {
        $process.Kill($true)
        throw "Timeout: $Executable"
    }
    $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    if ($process.ExitCode -ne $ExpectedExitCode) {
        throw "$Executable returned $($process.ExitCode), expected ${ExpectedExitCode}: $output"
    }
    return $output
}

try {
    foreach ($command in @('git', 'bash', 'pwsh', 'jq', 'specify')) {
        $null = Get-Command $command -ErrorAction Stop
    }
    foreach ($directory in @('.specify', '.agents/skills', '.claude/skills', '.github/agents', '.opencode/command', 'docs/security/secure-development')) {
        $null = New-Item -ItemType Directory -Path (Join-Path $temporaryRoot $directory) -Force
    }
    $null = Invoke-SDAInstalledCommand git @('init', '--quiet')
    $sourceArguments = if ($ArchiveUrl) { @('--from', $ArchiveUrl) } else { @('--dev', $presetRoot) }
    $null = Invoke-SDAInstalledCommand specify (@('preset', 'add') + $sourceArguments + @('--priority', '15'))
    $surfacePatterns = @(
        '.agents/skills/speckit-secure-development-{0}/SKILL.md',
        '.claude/skills/speckit-secure-development-{0}/SKILL.md',
        '.github/agents/speckit.secure-development-{0}.agent.md',
        '.opencode/command/speckit.secure-development-{0}.md'
    )
    foreach ($action in @('status', 'review')) {
        foreach ($pattern in $surfacePatterns) {
            $surface = $pattern -f $action
            $text = Get-Content -LiteralPath (Join-Path $temporaryRoot $surface) -Raw
            foreach ($extension in @('sh', 'ps1')) {
                $validator = ".specify/presets/secure-development-assurance-governance/scripts/validate-secure-development-assurance.$extension"
                if (-not $text.Contains($validator) -or $text.Contains(".specify/scripts/validate-secure-development-assurance.$extension")) {
                    throw "Generated surface has an invalid validator path: $surface ($extension)"
                }
                if (-not (Test-Path -LiteralPath (Join-Path $temporaryRoot $validator) -PathType Leaf)) {
                    throw "Generated validator does not exist: $validator"
                }
                # DE: Exitcode 2 beweist den ausgefuehrten Fail-Closed-Pfad, nicht fehlende Skripte.
                # EN: Exit code 2 proves an executed fail-closed path, not a missing script.
                $missingContext = 'docs/security/secure-development/2099-01-01-missing'
                if ($extension -eq 'sh') {
                    $arguments = @($validator, $action)
                    if ($action -eq 'review') { $arguments += @('baseline', 'missing', 'mixed') }
                    else { $arguments += $missingContext }
                    $validationOutput = Invoke-SDAInstalledCommand bash $arguments -ExpectedExitCode 2
                }
                else {
                    $arguments = @('-NoProfile', '-File', $validator, '-Action', $action)
                    if ($action -eq 'review') { $arguments += @('-Gate', 'baseline', '-ContextId', 'missing', '-Mode', 'mixed') }
                    else { $arguments += @('-EvidenceDirectory', $missingContext) }
                    $validationOutput = Invoke-SDAInstalledCommand pwsh $arguments -ExpectedExitCode 2
                }
                $expectedCause = if ($action -eq 'review') { 'Kontext nicht gefunden: missing' } else { 'Evidence-Verzeichnis fehlt' }
                if (-not $validationOutput.Contains($expectedCause)) {
                    throw "Expected evidence diagnostic missing: $surface ($extension): $validationOutput"
                }
            }
            Write-Output "PASS: $surface (Bash and PowerShell fail closed)"
        }
    }
}
finally {
    # DE: Nur das von diesem Test angelegte, eindeutig benannte Fixture-Verzeichnis entfernen.
    # EN: Remove only the uniquely named fixture directory created by this test.
    if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
}
