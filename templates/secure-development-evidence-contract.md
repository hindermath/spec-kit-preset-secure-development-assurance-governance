# Secure-Development-Evidence-Vertrag / Evidence Contract

## Zweck / Purpose

Dieser Vertrag bindet ein projektgeführtes Secure-Development-Manifest und
seine kontrollierten Dokumente an vier getrennte Gate-Nachweise. Er prüft
Integrität und Konsistenz, erteilt aber keine menschliche Freigabe und keine
Zertifizierung.

*This contract binds a project-owned secure-development manifest and its
controlled documents to four separate gate records. It validates integrity and
consistency but grants no human authorization or certification.*

## Verzeichnis / Directory

~~~text
docs/security/secure-development/<YYYY-MM-DD>-<context-id>/
├── baseline.json
├── deltas/<change-id>.json
├── closure.json
├── image-impact.json
└── evidence-matrix.md
~~~

`context-id` verwendet `^[a-z0-9][a-z0-9-]*$`. Ein Kontext benötigt genau eine
Baseline, mindestens ein Delta, genau einen Closure-Nachweis, genau einen
Image-Impact-Nachweis und eine lesbare Evidence-Matrix.

## Gemeinsame Gate-Felder / Shared Gate Fields

Jede JSON-Gate-Datei enthält mindestens:

- `schemaVersion: "1.0"`;
- `documentType: "SecureDevelopmentGateEvidence"`;
- `contextId`;
- `gate`;
- `mode`;
- `createdAt`;
- `review`;
- mindestens ein Element unter `assessments`;
- `outcome`;
- die exakte `externalComparisonBoundary`.

`review` enthält `owner`, `reviewer`, `reviewedAt`, `reviewDue`,
`residualRisk` und `reevaluationTrigger`. `reviewDue` darf nicht abgelaufen
sein.

## Statuswerte / Status Values

- Anwendbarkeit: `Applicable`, `N/A`, `Open`.
- Umsetzung: `Fulfilled`, `Partly Fulfilled`, `Not Fulfilled`,
  `Not Assessed`.
- Ergebnis: `Ready`, `ReadyWithAcceptedRisks`, `NeedsRemediation`,
  `Blocked`.

`N/A` benötigt `reason` und `reevaluationTrigger`. Offene oder nicht
vollständig erfüllte Punkte benötigen `nextAction`, `owner` und `dueAt`.
`Ready` ist bei offenen oder unerfüllten Pflichtpunkten unzulässig.

## Baseline-Bindung / Baseline Binding

`baseline.json` enthält zusätzlich:

~~~json
{
  "baselineBinding": {
    "manifestPath": "docs/secure-development/baseline-manifest.json",
    "baselineVersion": "<manifest baselineVersion>",
    "manifestNormalizedSha256": "<sha256>",
    "documentBindings": [
      {
        "path": "<path relative to manifest directory>",
        "version": "<manifest document version>",
        "normalizedSha256": "<sha256>"
      }
    ]
  }
}
~~~

`documentBindings` enthält exakt Richtlinie, Sammelband, zwölf Checklisten,
mitgeltende Dokumente und Lernpfade aus dem Manifest. Text wird als striktes
UTF-8 gelesen, ein führendes BOM entfernt und CRLF beziehungsweise CR zu LF
normalisiert, bevor SHA-256 berechnet wird.

## Closure / Closure

`closure.json` enthält:

~~~json
{
  "humanDecisions": {
    "technicalValidation": {"status": "Open", "authority": "<role>", "evidence": "<reference>"},
    "pilotAuthorization": {"status": "Open", "authority": "<role>", "evidence": "<reference>"},
    "projectAcceptance": {"status": "Open", "authority": "<role>", "evidence": "<reference>"},
    "generalRelease": {"status": "Open", "authority": "<role>", "evidence": "<reference>"}
  }
}
~~~

Die letzten drei Entscheidungen dürfen niemals aus technischer Validierung
abgeleitet werden.

## Image Impact / Image Impact

`image-impact.json` enthält `imageChecks` mit `build`, `compose`,
`toolchain`, `ociDigest`, `sbom`, `secrets`, `mounts`, `network` und `ci`.

## Akzeptierte Risiken / Accepted Risks

Jedes akzeptierte Risiko nennt ID, Scope, Owner, Reviewer, Reviewdatum,
Wiedervorlage, Begründung, Restrisiko und Re-Evaluation-Trigger.

## C5-Grenze / C5 Boundary

Die gebundene Baseline enthält `CL-02-13 Cloud-Compliance-Assurance`. Dieser
Vertrag prüft dessen Vorhandensein und die Integrität der Quelldokumente. Er
bildet nicht den vollständigen BSI-C5-Kriterienkatalog ab und begründet keine
C5-Konformität, Testatreife oder Zertifizierung.

## Externer Vergleich / External Comparison

Der einzige zulässige Grenzwert lautet:

~~~text
HOSK/GWDG: ExternalComparison only; never local evidence
~~~

Externer Vergleich ist niemals lokale Authority oder lokale Evidence.
