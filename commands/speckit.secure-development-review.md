---
description: Ein benanntes Secure-Development-Gate mit begrenzter Evidence-Autorität prüfen
---

# Secure Development Review

Syntax:

~~~text
$speckit-secure-development-review <baseline|delta|closure|image-impact> <context-id> <training|mixed|development>
~~~

Validiere genau das benannte Gate im Evidence-Verzeichnis
`docs/security/secure-development/<datum>-<context-id>/`.

Führe vom Projektwurzelverzeichnis auf Windows
`pwsh -NoProfile -File .specify/presets/secure-development-assurance-governance/scripts/validate-secure-development-assurance.ps1`
mit `-Action Review -Gate <gate> -ContextId <context-id> -Mode <mode>` aus.
Führe auf macOS/Linux
`bash .specify/presets/secure-development-assurance-governance/scripts/validate-secure-development-assurance.sh`
mit `review <gate> <context-id> <mode>` aus. Die vollständigen installierten
Pfade dürfen nicht auf das Top-Level-Skriptverzeichnis verkürzt werden.

- `training` und `mixed` benötigen ein Gate-spezifisches Runbook.
- `development` benötigt ein Runbook oder `runbookApplicability: "N/A"` mit
  belastbarer `runbookRationale`.
- `baseline` prüft zusätzlich Manifest, zwölf Checklisten,
  Dokumentversionen, normalisierte Hashbindungen, Sammelband,
  `CL-02-13` und `security-governance >=0.6.1`.
- `closure` prüft die vier unabhängigen menschlichen Entscheidungen.
- `image-impact` prüft alle neun Image-Felder.

Ändere nur ausdrücklich autorisierte Review-Evidence innerhalb des gewählten
Kontexts. Verändere niemals Richtlinie, Checklisten, Baseline-Quellen,
Produktcode, Images, Git-, Remote- oder Providerzustände.

Technische Validierung darf keine Pilotfreigabe, Projektabnahme, allgemeine
Freigabe, C5-Konformität, Testatreife oder Zertifizierung ersetzen.

## English

Run the explicit installed validator path from the project root. Pass the
named gate, context ID, and mode without shortening the preset path.
Review exactly one named gate and context. Preserve the four independent human
decision boundaries. Fail closed on missing evidence, invalid state,
manifest/version/hash drift, expired review, absent runbook or authority, and
prohibited certification claims. Modify only explicitly authorized review
evidence.
