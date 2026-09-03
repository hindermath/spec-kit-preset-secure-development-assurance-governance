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

Führe auf Windows den PowerShell-Validator mit `-Action Review` aus. Führe auf
macOS/Linux den Bash-Validator mit `review` aus.

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

Review exactly one named gate and context. Preserve the four independent human
decision boundaries. Fail closed on missing evidence, invalid state,
manifest/version/hash drift, expired review, absent runbook or authority, and
prohibited certification claims. Modify only explicitly authorized review
evidence.
