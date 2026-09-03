# secure-development-assurance(1)

## NAME

secure-development-assurance — projektgeführte Secure-Development-Evidence
validieren

## SYNOPSIS

~~~text
validate-secure-development-assurance.sh status [evidence-dir]
validate-secure-development-assurance.sh review <gate> <context-id> <mode>

validate-secure-development-assurance.ps1 -Action Status [-EvidenceDirectory <path>]
validate-secure-development-assurance.ps1 -Action Review -Gate <gate> -ContextId <id> -Mode <mode>
~~~

## DESCRIPTION

Die Werkzeuge prüfen die vier Gates `baseline`, `delta`, `closure` und
`image-impact`. Die Baseline-Prüfung validiert Manifestbindung, Version,
normalisierte SHA-256-Werte, zwölf Checklisten, den generierten Sammelband,
mitgeltende Dokumente, `CL-02-13` und die fachliche
Security-Governance-Voraussetzung.

Status ist strikt read-only. Review validiert genau ein Gate. Beide Varianten
erteilen keine menschliche Freigabe und keine Zertifizierung.

## GATES

- `baseline` — Baseline, Manifest und kontrollierte Dokumente;
- `delta` — eine konkrete Änderung;
- `closure` — technischer Abschluss, Risiken und vier Entscheidungen;
- `image-impact` — Build, Compose, Toolchain, OCI-Digest, SBOM, Secrets,
  Mounts, Netzwerk und CI.

## MODES

- `training` — Runbook erforderlich;
- `mixed` — Runbook erforderlich;
- `development` — Runbook oder begründetes `N/A`.

## EXIT STATUS

- `0` — der angeforderte technische Vertrag wurde validiert;
- `2` — Evidence, Vertrag oder Schutzgrenze blockiert.

Ein Exitcode `0` bedeutet keine Pilotfreigabe, Projektabnahme, allgemeine
Freigabe oder C5-Konformität.

## FILES

- `docs/security/secure-development/<datum>-<context-id>/baseline.json`
- `docs/security/secure-development/<datum>-<context-id>/deltas/*.json`
- `docs/security/secure-development/<datum>-<context-id>/closure.json`
- `docs/security/secure-development/<datum>-<context-id>/image-impact.json`
- `docs/security/secure-development/<datum>-<context-id>/evidence-matrix.md`
- `docs/runbooks/secure-development/<gate>-<context-id>.md`

## C5 BOUNDARY

`CL-02-13 Cloud-Compliance-Assurance` ist Bestandteil der projektgeführten
Baseline. Das Werkzeug prüft dessen Vorhandensein und Quellintegrität, nicht
den vollständigen BSI-C5-Kriterienkatalog oder eine Testatreife.

## ENGLISH

The tools validate the project-owned secure-development baseline and four
evidence gates. Status is read-only. Review is bounded to one gate. Exit code
zero confirms only the technical evidence contract; it grants no human
authorization, certification, or C5 readiness.
