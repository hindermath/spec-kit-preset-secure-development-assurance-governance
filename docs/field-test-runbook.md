# Feldtest-Runbook / Field-Test Runbook

## Ziel / Goal

Dieses Runbook erprobt ein unveränderliches Release-ZIP von Secure Development
Assurance Governance in einem kontrollierten Spec-Kit-Projekt. Der Feldtest
bereitet eine mögliche spätere Community-Einreichung vor, löst sie aber nicht
aus.

*This runbook evaluates an immutable release archive in a controlled Spec Kit
project. It prepares evidence for a possible later Community submission but
does not create one.*

## Schutzgrenzen / Safety Boundaries

- Keine produktionsnahe Freigabe allein aufgrund dieses Tests.
- Keine echten Secrets, Kundendaten oder unnötigen personenbezogenen Daten.
- Keine automatische Änderung von Richtlinie, Checklisten oder Baseline.
- Keine Ableitung menschlicher Freigaben aus technischen Ergebnissen.
- Keine Aussage zu C5-Konformität, Testatreife oder Zertifizierung.
- Keine Community-Einreichung ohne getrennten ausdrücklichen Auftrag.

## Voraussetzungen / Preconditions

1. Spec Kit `>=0.8.3` ist installiert.
2. `security-governance >=0.6.1` ist im Testprojekt aktiv.
3. Das veröffentlichte Tag-ZIP und sein dokumentierter SHA-256 sind bekannt.
4. Das Testprojekt besitzt ein gültiges Secure-Development-Manifest.
5. Bash, PowerShell 7 und `jq` sind für den Paritätstest verfügbar.
6. Test-Owner und technischer Reviewer sind benannt.

## Phase 1: Paket und Installation

1. Release-ZIP herunterladen.
2. SHA-256 mit der Release-Evidence vergleichen.
3. Preset mit Priorität `15` installieren.
4. `specify preset info`, `specify preset resolve` und `specify check`
   ausführen.
5. Prüfen, dass genau die beiden Befehle Status und Review erscheinen.

## Phase 2: Positiver Kontext

1. Vollständigen Kontext mit vier Gates erstellen.
2. Manifest, Version und Dokumenthashes korrekt binden.
3. Einen anwendbaren oder begründet nicht anwendbaren
   `CL-02-13`-bezogenen Cloud-Assurance-Nachweis referenzieren.
4. Alle anwendbaren Pflichtpunkte auf `Fulfilled` setzen.
5. Status unter Bash und PowerShell ausführen.
6. Bytegleiche fachliche Statuszeilen und Exitcode `0` bestätigen.
7. Vorher-/Nachher-Hashes aller Evidence-Dateien vergleichen, um read-only
   nachzuweisen.

## Phase 3: Bewusst blockierter Kontext

Mindestens folgende Fehler einzeln prüfen:

- Manifest-Hashdrift;
- fehlende Checkliste;
- doppelte Checklisten-ID;
- falsche Dokumentversion;
- Dokument-Hashdrift;
- Sammelbanddrift;
- `Ready` bei offenem Pflichtpunkt;
- `N/A` ohne Begründung;
- abgelaufener Review;
- unvollständiges akzeptiertes Risiko;
- fehlende Security-Governance-Voraussetzung;
- unzulässige C5-/ISO-Zertifizierungsbehauptung;
- fehlendes Runbook;
- unvollständige Image-Impact-Felder.

Jeder Fall muss mit Exitcode `2` blockieren und eine textuelle Ursache nennen.

## Phase 4: Vier Gate-Reviews

Führe für `baseline`, `delta`, `closure` und `image-impact` je einen
kontrollierten Review aus. Prüfe:

- genau das benannte Gate wird bewertet;
- die richtige Betriebsart wird angewendet;
- das Runbook-Gate greift;
- keine Baseline-Quelle wird verändert;
- keine menschliche Entscheidung wird automatisch erfüllt.

## Phase 5: Plattformparität

1. Gleiche LF-Fixture unter Bash und PowerShell prüfen.
2. Inhaltlich gleiche CRLF-Fixture prüfen.
3. Inhaltlich gleiche UTF-8-BOM-Fixture prüfen.
4. Gleiche Ergebnisart und gleichen Exitcode bestätigen.
5. Eine echte Inhaltsänderung muss auf beiden Plattformen als Drift blockieren.

## Phase 6: Preset-Komposition

1. Vollständiges 13-Preset-Profil installieren.
2. Auflösen und `specify check` ausführen.
3. Assurance-Preset deaktivieren und erneut prüfen.
4. Assurance-Preset reaktivieren und erneut prüfen.
5. Assurance-Preset entfernen und bestehende Profile 8 bis 12 prüfen.
6. Aus dem Tag-ZIP erneut installieren.

## Phase 7: Ergebnis

Der Feldbericht enthält:

- Release-URL, Tag und ZIP-SHA-256;
- Testprojekt und anonymisierten Scope;
- Betriebssysteme und Shell-Versionen;
- Spec-Kit- und Security-Governance-Version;
- alle Testfälle mit Ergebnis und Exitcode;
- Abweichungen zwischen Bash und PowerShell;
- offene Findings;
- Restrisiken;
- Empfehlung `ReleaseAccepted`, `PatchRequired` oder `Blocked`.

`PatchRequired` erzeugt eine neue Version, zum Beispiel `v0.1.1`. Das
veröffentlichte Tag `v0.1.0` bleibt unverändert.

## Abbruchkriterien / Stop Conditions

Der Feldtest wird abgebrochen, wenn Secrets sichtbar werden, eine Baseline
unerwartet verändert wird, menschliche Freigaben implizit gesetzt werden, ein
Validator widersprüchliche Ergebnisse liefert oder die Testumgebung nicht
mehr kontrolliert ist.
