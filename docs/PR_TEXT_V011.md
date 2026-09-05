# v0.1.1: Feldtest-Korrektur / Field-test correction

## Problem und Loesung / Problem and solution

SDA-FT-001 korrigiert erzeugte Validatorpfade fuer vier Agenten.
SDA-FT-002 verwendet deterministische Snapshots aus sortierten relativen
Pfaden und rohen SHA-256-Dateihashes. BOM/CRLF-Normalisierung bleibt allein
dem semantischen Quellenvergleich vorbehalten.

*Fix generated validator paths and make read-only snapshots deterministic.
Keep raw-byte change detection distinct from semantic source normalization.*

## Herkunft und Grenzen / Provenance and boundaries

Kanonische Quelle: `hindermath/home-baseline`, Commit `476a4fe`, unter
`specs/spec-kit-presets/secure-development-assurance-governance/`.
Alle sieben geaenderten Paketdateien stimmen mit der dort unabhaengig
geprueften Quelle ueberein. Der CI-Workflow verwendet dieselben Befehle mit
Paket-Root-Pfaden. Dokumentationsauswirkung: `UpdateRequired`.

*The seven changed package files match the independently reviewed canonical
source. CI uses the same tests with package-root paths. Documentation is
updated with the patch; no evidence schema, API or approval semantics change.*

## Nachweise und Risiken / Evidence and risks

- Lokales macOS: Validatorvertrag, Snapshot-Mutationen, vier Gates in beiden
  Shells und acht generierte Agentenoberflaechen bestanden.
- PowerShell ScriptAnalyzer 1.25.0: keine Findings.
- Native Linux/macOS/Windows-CI muss vor Merge bestehen.
- Keine automatische Erfuellung menschlicher Entscheidungen.
- v0.1.0 bleibt unveraendert; v0.1.1 ist ein Feldtest-Kandidat, noch kein
  bestandener TinyCalc-Feldtest und keine Community-Einreichung.

*Local contracts and regression checks pass. Native CI is a pre-merge gate.
Human decisions stay open. The new immutable patch does not claim general
release acceptance or completion of the two planned TinyCalc field tests.*

Owner-Freigabe: MergeAndSync, Admin-Bypass nur fuer formale Merge-Regeln,
niemals fuer fehlgeschlagene materielle Gates.

*Owner authority permits formal-rule-only admin bypass, never a technical,
security, accessibility, substantive-review or evidence failure.*
