# v0.1.7: Stabiles Routing / Stable routing

Status: zur Sichtung vorbereitet, nicht veröffentlicht.
*Status: prepared for review, not published.*

## Änderung / Change

Aufbauend auf dem getrennt gemergten Dokumentations-PR #9 ergänzt dieser Patch
den fehlenden Schema-1.0-Vertrag: Status `fast-mechanical`, Review
`frontier-reasoning`, Standardrolle `frontier-reasoning`, `fail-closed`.
Manifestregistrierung macht den Vertrag als Vorlage auflösbar. Keine Modell-ID,
neue Auswahlheuristik oder Wiederaufnahme der verworfenen Routing-Entwicklung.

*Building on separately merged documentation PR #9, this patch adds the missing
schema-1.0 contract: status fast-mechanical, review frontier-reasoning, default
frontier-reasoning and fail-closed. Manifest registration makes it resolvable
as a template. No model IDs, new heuristics or cancelled routing development.*

Direkte Validatoren und die vier Gate-Regeln bleiben unverändert. Fachliches
Review, technische Validierung und menschliche Freigaben bleiben getrennt.
Geroutete Agentenarbeit braucht ausdrücklich konfigurierte lokale Profile;
Installation allein startet und migriert nichts.

*Direct validators and the four gate rules are unchanged. Assessment, technical
validation and human approval remain separate. Routed work needs explicitly
configured local profiles; installation starts or migrates nothing.*

## Dokumentationsauswirkung / Documentation Impact

- Entscheidung / Decision: `UpdateRequired`.
- Owner: Thorsten Hindermann.
- Kanonische Quellen / Canonical sources: Manifest, Routing-Vertrag, beide Commands.
- Leserpfad / Reader path: README → Zusammenspiel/Routing → Commands → Fehlerhilfe.
- Zielgruppe / Audience: Auszubildende aller vier IHK-IT-Berufe und aller vier
  Fachinformatik-Fachrichtungen; Entwickelnde ohne Governance-Spezialwissen.
- DE zuerst, gleichwertiges EN; CEFR B2 und anwendbare WCAG 2.2 AA als Ziel,
  keine automatische Sprach- oder Barrierefreiheitsabnahme.
- Quellen-/Hilfedokumentation mit erhaltenen Ankern; kein generierter Text.
- Distribution: Preset-Quelle und Release-Kandidat, kein Home-Runtime-Sync.
- Re-Evaluation nach Review, geändertem Head oder gesondertem Release-Auftrag.

*The README and commands explain the canonical manifest/routing contract for
IT apprentices and non-specialist developers: German first, equivalent English,
B2 and applicable WCAG 2.2 AA targets, not automated acceptance. Existing anchors
remain. Source/preset-candidate distribution only; no Home Runtime sync.
Re-evaluate after review, head changes or separate publication authority.*

## Prüfvertrag / Validation contract

`tests/test-stable-routing.ps1` prüft beide Commands, Registrierung, Rollen und
die isolierte Komposition mit Model Routing v0.1.5 (Commit
`accae165176dc948b95a22fb68650c7db62c4079`) und Autonomous Run v0.4.5
(`8026572a37f967d2603f8a942d5bfd1ccbf2dca2`). Beide Quellen sind unveränderlich
gebunden. Nur synthetische Runner-Profile; keine Modellaufrufe. Fehlende
Verträge, falsche Rollen und schwächere Überlagerungen werden geprüft.
Ein eigenes Versions-Double beantwortet nur `--version`; auch eine lokal
angemeldete Harness-CLI wird für die Fixture-Discovery nicht verwendet.
Die bestehenden Assurance- und Agentenflächen-Regressionen bleiben Pflicht.
Tatsächliche Ergebnisse und native Plattformgrenzen werden im PR dokumentiert.

*The routing test checks coverage, registration, roles and isolated composition
against the immutable stable commits above. Only synthetic profiles are used;
no model calls. An owned version-only double replaces even the native harness
version query; fixture discovery never uses a signed-in CLI. Missing contracts,
wrong roles and weaker overlaps are tested.
Existing Assurance and installed-surface regressions remain required. The PR
records actual results and native platform limits, not presumed passes.*

## Liefergrenze / Delivery boundary

Nur Commit, Push und separater PR zur Sichtung. Kein Merge, Tag, Release,
Profil-/Quellenbindungs-Rollout, Home Runtime Sync oder Community-Einreichung.
Bestehende ZIPs bleiben unverändert. Ein späteres Release braucht einen eigenen
Auftrag und die Prüfung des tatsächlichen Tag-ZIPs samt SHA-256.

*Commit, push and separate review PR only. No merge, tag, release, consumer
profile/source-lock update, Home Runtime sync or community submission. Existing
ZIPs remain unchanged. A later release requires separate authority and actual
tag-archive/SHA-256 verification.*
