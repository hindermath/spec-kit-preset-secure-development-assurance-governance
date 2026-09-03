<#
.SYNOPSIS
Prüft den Secure-Development-Assurance-Vertrag und die Shell-Parität.

.DESCRIPTION
Erzeugt eine isolierte Fixture mit zwölf Checklisten und prüft positive,
negative, Read-only-, UTF-8-BOM-, CRLF- und Bash-/PowerShell-Paritätsfälle.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$presetRoot = Split-Path -Parent $PSScriptRoot
$bashValidator = Join-Path $presetRoot 'scripts/validate-secure-development-assurance.sh'
$powerShellValidator = Join-Path $presetRoot 'scripts/validate-secure-development-assurance.ps1'
$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ('sda-' + [guid]::NewGuid().ToString('N'))
$contextRelative = 'docs/security/secure-development/2099-01-01-contract-test'
$boundary = 'HOSK/GWDG: ExternalComparison only; never local evidence'
$utf8 = [Text.UTF8Encoding]::new($false)

function Write-SDATestText {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Text,
        [switch]$Bom,
        [switch]$CrLf
    )
    $directory = Split-Path -Parent $Path
    if ($directory) { [IO.Directory]::CreateDirectory($directory) | Out-Null }
    $content = $Text
    if ($CrLf) {
        $content = $content.Replace(([string][char]13 + [char]10), [string][char]10)
        $content = $content.Replace([string][char]10, ([string][char]13 + [char]10))
    }
    $encoding = [Text.UTF8Encoding]::new([bool]$Bom)
    [IO.File]::WriteAllText($Path, $content, $encoding)
}

function Write-SDATestJson {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][object]$Value
    )
    Write-SDATestText $Path (($Value | ConvertTo-Json -Depth 30) + [Environment]::NewLine)
}

function Get-SDATestHash {
    param([Parameter(Mandatory)][string]$Path)
    $strictUtf8 = [Text.UTF8Encoding]::new($false, $true)
    $text = $strictUtf8.GetString([IO.File]::ReadAllBytes($Path))
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
    $text = $text.Replace(([string][char]13 + [char]10), [string][char]10)
    $text = $text.Replace([string][char]13, [string][char]10)
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($strictUtf8.GetBytes($text))).ToLowerInvariant()
}

function Read-SDATestJson {
    param([Parameter(Mandatory)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 100 -DateKind String
}

function Get-SDATestReview {
    return [ordered]@{
        owner = 'Fixture owner'
        reviewer = 'Fixture reviewer'
        reviewedAt = '2099-01-01T00:00:00Z'
        reviewDue = '2099-12-31'
        residualRisk = 'None identified in the fixture.'
        reevaluationTrigger = 'Any fixture change.'
    }
}

function Get-SDATestAssessment {
    param([string]$Id = 'TEST-001')
    return [ordered]@{
        id = $Id
        applicability = 'Applicable'
        implementation = 'Fulfilled'
        evidence = 'tests/evidence.md'
    }
}

function Get-SDATestGate {
    param(
        [Parameter(Mandatory)][string]$Gate,
        [string]$Outcome = 'Ready'
    )
    return [ordered]@{
        schemaVersion = '1.0'
        documentType = 'SecureDevelopmentGateEvidence'
        contextId = 'contract-test'
        gate = $Gate
        mode = 'mixed'
        createdAt = '2099-01-01T00:00:00Z'
        review = Get-SDATestReview
        assessments = @(Get-SDATestAssessment)
        outcome = $Outcome
        externalComparisonBoundary = $boundary
    }
}

function Update-SDATestBindings {
    $manifestPath = Join-Path $temporaryRoot 'docs/secure-development/baseline-manifest.json'
    $manifest = Read-SDATestJson $manifestPath
    $baselinePath = Join-Path $temporaryRoot (Join-Path $contextRelative 'baseline.json')
    $baseline = Read-SDATestJson $baselinePath
    $documents = @(
        $manifest.guideline
        $manifest.compendium
        $manifest.checklists
        $manifest.relatedDocuments
        $manifest.learningDocuments
    )
    $baseline.baselineBinding = [ordered]@{
        manifestPath = 'docs/secure-development/baseline-manifest.json'
        baselineVersion = $manifest.baselineVersion
        manifestNormalizedSha256 = Get-SDATestHash $manifestPath
        documentBindings = @(
            $documents | ForEach-Object {
                [ordered]@{
                    path = $_.path
                    version = $_.version
                    normalizedSha256 = Get-SDATestHash (Join-Path (Split-Path $manifestPath) $_.path)
                }
            }
        )
    }
    Write-SDATestJson $baselinePath $baseline
}

function New-SDATestFixture {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
    [IO.Directory]::CreateDirectory($temporaryRoot) | Out-Null
    $docRoot = Join-Path $temporaryRoot 'docs/secure-development'
    $context = Join-Path $temporaryRoot $contextRelative

    Write-SDATestText (Join-Path $temporaryRoot '.specify/presets/security-governance/preset.yml') @'
schema_version: "1.0"
preset:
  id: "security-governance"
  version: "0.6.2"
'@
    Write-SDATestText (Join-Path $docRoot 'Richtlinie.md') @'
# Richtlinie

| Versionsnummer | 1.0.0 |
'@

    $checklists = [Collections.Generic.List[object]]::new()
    $compendiumItems = [Collections.Generic.List[string]]::new()
    foreach ($number in 1..12) {
        $checklistId = 'CL-{0:D2}' -f $number
        $itemId = if ($number -eq 2) { 'CL-02-13' } else { 'CL-{0:D2}-01' -f $number }
        $relative = 'checklisten/CL_{0:D2}.md' -f $number
        $text = @(
            "## $checklistId"
            ''
            "**Dokument-ID / Document ID:** $checklistId"
            '**Version / Version:** 1.0.0'
            ''
            "#### $($itemId): Fixture item"
            ''
        ) -join [Environment]::NewLine
        Write-SDATestText (Join-Path $docRoot $relative) $text
        $checklists.Add([ordered]@{ id = $checklistId; path = $relative; version = '1.0.0' })
        $compendiumItems.Add("#### $($itemId): Fixture item")
    }

    $compendium = @(
        '# Checklistensammelband'
        ''
        '**Baseline-Version / Baseline version:** 1.0.0'
        '**Dokumentversion / Document version:** 1.0.0'
        ''
        ($compendiumItems -join ([Environment]::NewLine + [Environment]::NewLine))
        ''
    ) -join [Environment]::NewLine
    Write-SDATestText (Join-Path $docRoot 'Sammelband.md') $compendium
    Write-SDATestText (Join-Path $docRoot 'related.md') @'
# Related

**Version / Version:** 1.0.0
'@
    Write-SDATestText (Join-Path $docRoot 'learning.md') @'
# Learning

**Version / Version:** 1.0.0
'@
    Write-SDATestText (Join-Path $docRoot 'README.md') '# Managed reference'
    Write-SDATestText (Join-Path $docRoot 'binary.bin') 'fixture'

    $manifest = [ordered]@{
        schemaVersion = 1
        baselineVersion = '1.0.0'
        releaseDate = '2099-01-01'
        checklistItemCount = 12
        guideline = [ordered]@{ path = 'Richtlinie.md'; version = '1.0.0' }
        compendium = [ordered]@{ path = 'Sammelband.md'; version = '1.0.0'; generated = $true }
        statusModel = [ordered]@{
            applicability = @('Applicable', 'N/A', 'Open')
            implementation = @('Fulfilled', 'Partly Fulfilled', 'Not Fulfilled', 'Not Assessed')
        }
        checklists = @($checklists)
        relatedDocuments = @([ordered]@{ path = 'related.md'; version = '1.0.0' })
        learningDocuments = @([ordered]@{ path = 'learning.md'; version = '1.0.0' })
        managedBinaryFiles = @('binary.bin')
        managedReferenceFiles = @('README.md')
    }
    Write-SDATestJson (Join-Path $docRoot 'baseline-manifest.json') $manifest

    $baseline = Get-SDATestGate baseline
    $baseline.baselineBinding = [ordered]@{
        manifestPath = 'docs/secure-development/baseline-manifest.json'
        baselineVersion = '1.0.0'
        manifestNormalizedSha256 = '0' * 64
        documentBindings = @()
    }
    Write-SDATestJson (Join-Path $context 'baseline.json') $baseline
    Write-SDATestJson (Join-Path $context 'deltas/change.json') (Get-SDATestGate delta)

    $closure = Get-SDATestGate closure
    $closure.humanDecisions = [ordered]@{
        technicalValidation = [ordered]@{ status = 'Fulfilled'; authority = 'Technical reviewer'; evidence = 'tests/evidence.md' }
        pilotAuthorization = [ordered]@{ status = 'Open'; authority = 'Pilot owner'; evidence = 'Not authorized by this test' }
        projectAcceptance = [ordered]@{ status = 'Open'; authority = 'Project owner'; evidence = 'Not authorized by this test' }
        generalRelease = [ordered]@{ status = 'Open'; authority = 'Release owner'; evidence = 'Not authorized by this test' }
    }
    $closure.outcome = 'NeedsRemediation'
    $closure.assessments = @([ordered]@{
        id = 'CLOSE-001'
        applicability = 'Open'
        implementation = 'Not Assessed'
        evidence = 'Human decisions remain open'
        nextAction = 'Obtain explicit human decisions.'
        owner = 'Project owner'
        dueAt = '2099-12-31'
    })
    $closure.nextAction = 'Obtain explicit human decisions.'
    Write-SDATestJson (Join-Path $context 'closure.json') $closure

    $image = Get-SDATestGate image-impact
    $image.imageChecks = [ordered]@{
        build = 'Fulfilled'; compose = 'Fulfilled'; toolchain = 'Fulfilled'
        ociDigest = 'Fulfilled'; sbom = 'Fulfilled'; secrets = 'Fulfilled'
        mounts = 'Fulfilled'; network = 'Fulfilled'; ci = 'Fulfilled'
    }
    Write-SDATestJson (Join-Path $context 'image-impact.json') $image
    Write-SDATestText (Join-Path $context 'evidence-matrix.md') '# Fixture evidence matrix'
    foreach ($gate in @('baseline', 'delta', 'closure', 'image-impact')) {
        Write-SDATestText (Join-Path $temporaryRoot "docs/runbooks/secure-development/$gate-contract-test.md") "# $gate runbook"
    }
    Update-SDATestBindings
}

function Invoke-SDATestProcess {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$Arguments
    )
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $FilePath
    $info.WorkingDirectory = $temporaryRoot
    $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $null = $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::Start($info)
    $stdout = $process.StandardOutput.ReadToEnd().Trim()
    $stderr = $process.StandardError.ReadToEnd().Trim()
    $process.WaitForExit()
    return [pscustomobject]@{ ExitCode = $process.ExitCode; StdOut = $stdout; StdErr = $stderr }
}

function Invoke-SDATestPair {
    $bash = Invoke-SDATestProcess bash @($bashValidator, 'status', $contextRelative)
    $pwsh = Invoke-SDATestProcess pwsh @(
        '-NoProfile', '-File', $powerShellValidator, '-Action', 'Status',
        '-EvidenceDirectory', $contextRelative
    )
    return [pscustomobject]@{ Bash = $bash; PowerShell = $pwsh }
}

function Assert-SDATest {
    param(
        [Parameter(Mandatory)][bool]$Condition,
        [Parameter(Mandatory)][string]$Message
    )
    if (-not $Condition) { throw "FAIL: $Message" }
}

function Invoke-SDANegativeCase {
    param(
        [Parameter(Mandatory)][scriptblock]$Mutation,
        [Parameter(Mandatory)][string]$ExpectedText
    )
    New-SDATestFixture
    & $Mutation
    $pair = Invoke-SDATestPair
    Assert-SDATest ($pair.Bash.ExitCode -eq 2) "Bash did not block: $ExpectedText"
    Assert-SDATest ($pair.PowerShell.ExitCode -eq 2) "PowerShell did not block: $ExpectedText"
    Assert-SDATest ($pair.Bash.StdErr -match [regex]::Escape($ExpectedText)) "Bash message missing: $ExpectedText"
    Assert-SDATest (-not [string]::IsNullOrWhiteSpace($pair.PowerShell.StdErr)) "PowerShell cause missing: $ExpectedText"
}

try {
    foreach ($command in @('bash', 'pwsh', 'jq')) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
            throw "Required test command missing: $command"
        }
    }

    New-SDATestFixture
    $before = Get-ChildItem -LiteralPath (Join-Path $temporaryRoot $contextRelative) -File -Recurse |
        ForEach-Object { "$($_.FullName)=$(Get-FileHash $_.FullName -Algorithm SHA256)" }
    $positive = Invoke-SDATestPair
    Assert-SDATest ($positive.Bash.ExitCode -eq 0) "Positive Bash status failed: $($positive.Bash.StdErr)"
    Assert-SDATest ($positive.PowerShell.ExitCode -eq 0) "Positive PowerShell status failed: $($positive.PowerShell.StdErr)"
    Assert-SDATest ($positive.Bash.StdOut -eq $positive.PowerShell.StdOut) 'Status output differs between Bash and PowerShell.'
    $after = Get-ChildItem -LiteralPath (Join-Path $temporaryRoot $contextRelative) -File -Recurse |
        ForEach-Object { "$($_.FullName)=$(Get-FileHash $_.FullName -Algorithm SHA256)" }
    Assert-SDATest (($before -join '|') -eq ($after -join '|')) 'Status changed evidence files.'

    Invoke-SDANegativeCase {
        Add-Content -LiteralPath (Join-Path $temporaryRoot 'docs/secure-development/baseline-manifest.json') -Value ' '
    } 'Manifest-Hashdrift'

    Invoke-SDANegativeCase {
        Remove-Item -LiteralPath (Join-Path $temporaryRoot 'docs/secure-development/checklisten/CL_12.md')
    } 'Kontrolliertes Dokument fehlt'

    Invoke-SDANegativeCase {
        $manifestPath = Join-Path $temporaryRoot 'docs/secure-development/baseline-manifest.json'
        $manifest = Read-SDATestJson $manifestPath
        $manifest.checklists[11].id = 'CL-11'
        Write-SDATestJson $manifestPath $manifest
        Update-SDATestBindings
    } 'Checklisten-IDs müssen eindeutig'

    Invoke-SDANegativeCase {
        $checklistPath = Join-Path $temporaryRoot 'docs/secure-development/checklisten/CL_03.md'
        $text = (Get-Content -LiteralPath $checklistPath -Raw).Replace(
            '**Version / Version:** 1.0.0',
            '**Version / Version:** 2.0.0'
        )
        Write-SDATestText $checklistPath $text
        Update-SDATestBindings
    } 'Dokumentversion stimmt nicht'

    Invoke-SDANegativeCase {
        $compendiumPath = Join-Path $temporaryRoot 'docs/secure-development/Sammelband.md'
        $text = (Get-Content -LiteralPath $compendiumPath -Raw).Replace('#### CL-12-01: Fixture item', '')
        Write-SDATestText $compendiumPath $text
        Update-SDATestBindings
    } 'Sammelbanddrift'

    Invoke-SDANegativeCase {
        $deltaPath = Join-Path $temporaryRoot (Join-Path $contextRelative 'deltas/change.json')
        $delta = Read-SDATestJson $deltaPath
        $delta.assessments[0].applicability = 'Open'
        $delta.assessments[0].implementation = 'Not Assessed'
        $delta.outcome = 'Ready'
        $delta.assessments[0] | Add-Member nextAction 'Resolve the item.'
        $delta.assessments[0] | Add-Member owner 'Fixture owner'
        $delta.assessments[0] | Add-Member dueAt '2099-12-31'
        Write-SDATestJson $deltaPath $delta
    } 'Ready ist bei offenen oder unerfüllten Pflichtpunkten unzulässig'

    Invoke-SDANegativeCase {
        $deltaPath = Join-Path $temporaryRoot (Join-Path $contextRelative 'deltas/change.json')
        $delta = Read-SDATestJson $deltaPath
        $delta.assessments[0].applicability = 'N/A'
        $delta.assessments[0].implementation = 'Not Assessed'
        Write-SDATestJson $deltaPath $delta
    } 'N/A benötigt Begründung'

    Invoke-SDANegativeCase {
        $deltaPath = Join-Path $temporaryRoot (Join-Path $contextRelative 'deltas/change.json')
        $delta = Read-SDATestJson $deltaPath
        $delta.review.reviewDue = '2000-01-01'
        Write-SDATestJson $deltaPath $delta
    } 'Review ist abgelaufen'

    Invoke-SDANegativeCase {
        $deltaPath = Join-Path $temporaryRoot (Join-Path $contextRelative 'deltas/change.json')
        $delta = Read-SDATestJson $deltaPath
        $delta.outcome = 'ReadyWithAcceptedRisks'
        $delta | Add-Member acceptedRisks @([ordered]@{
            id = 'RISK-001'
            owner = 'Fixture owner'
            reviewedAt = '2099-01-01T00:00:00Z'
            reviewDue = '2099-12-31'
            residualRisk = 'Fixture risk'
            reevaluationTrigger = 'Any change'
        })
        Write-SDATestJson $deltaPath $delta
    } 'Akzeptierte Risiken benötigen Owner, Reviewer'

    Invoke-SDANegativeCase {
        $closurePath = Join-Path $temporaryRoot (Join-Path $contextRelative 'closure.json')
        $closure = Read-SDATestJson $closurePath
        $closure.humanDecisions.technicalValidation.status = 'Open'
        $closure.humanDecisions.pilotAuthorization.status = 'Fulfilled'
        Write-SDATestJson $closurePath $closure
    } 'Menschliche Freigabe darf technische Validierung nicht überspringen'

    Invoke-SDANegativeCase {
        $deltaPath = Join-Path $temporaryRoot (Join-Path $contextRelative 'deltas/change.json')
        $delta = Read-SDATestJson $deltaPath
        $delta | Add-Member certificationClaim 'C5 compliant'
        Write-SDATestJson $deltaPath $delta
    } 'Unzulässige Zertifizierungs'

    Invoke-SDANegativeCase {
        Remove-Item -LiteralPath (Join-Path $temporaryRoot '.specify/presets/security-governance/preset.yml')
    } 'Fachliche Voraussetzung fehlt'

    Invoke-SDANegativeCase {
        $imagePath = Join-Path $temporaryRoot (Join-Path $contextRelative 'image-impact.json')
        $image = Read-SDATestJson $imagePath
        $image.imageChecks.PSObject.Properties.Remove('sbom')
        Write-SDATestJson $imagePath $image
    } 'Image-Impact-Nachweise sind unvollständig'

    New-SDATestFixture
    $controlledFiles = Get-ChildItem -LiteralPath (Join-Path $temporaryRoot 'docs/secure-development') -File -Recurse |
        Where-Object { $_.Extension -in @('.md', '.json', '.yml') }
    foreach ($file in $controlledFiles) {
        $text = [Text.UTF8Encoding]::new($false, $true).GetString([IO.File]::ReadAllBytes($file.FullName))
        Write-SDATestText $file.FullName $text -Bom -CrLf
    }
    $lineEndingPair = Invoke-SDATestPair
    Assert-SDATest ($lineEndingPair.Bash.ExitCode -eq 0) "BOM/CRLF Bash status failed: $($lineEndingPair.Bash.StdErr)"
    Assert-SDATest ($lineEndingPair.PowerShell.ExitCode -eq 0) "BOM/CRLF PowerShell status failed: $($lineEndingPair.PowerShell.StdErr)"

    'PASS: secure-development-assurance validator contract and Bash/PowerShell parity'
} finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}
