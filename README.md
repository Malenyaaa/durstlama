# Trinkimal

Ein kostenloser Trink-Tracker mit Tier. Ein Tipp auf ein Getränk trägt es ein, mehr nicht.
Dein Tier sitzt animiert im Teich, und je mehr du trinkst, desto höher steht das Wasser. Es trinkt
bei jedem Eintrag mit. Bekommt es tagsüber länger nichts, wird es durstig: ab zwei Stunden lässt
es den Kopf hängen, ab vier schwitzt und wackelt es. Nachts zwischen 22 und 7 Uhr zählt die Pause
nicht. Beim Tagesziel hüpft es, und Herzen steigen auf.

27 Tiere zur Auswahl, vom Panda über Otter und Faultier bis Dino und Qualle
(Tipp aufs Tier oder **Mehr → Dein Tier**). Die Getränke-Knöpfe sind ebenfalls animiert:
Kaffee dampft, Bubble Tea blubbert.

**Öffnen:** https://malenyaaa.github.io/trinkimal/

## Was es kann

- **Ein Tipp pro Glas.** Die Lieblingsgetränke liegen als Kacheln auf der Startseite. Für eine
  andere Menge vorher einen Mengen-Knopf wählen (150 bis 500 ml), danach springt er zurück.
  Jeder Eintrag lässt sich einige Sekunden lang rückgängig machen.
- **Rund 30 Getränke** von Wasser über Mate bis alkoholfreies Bier, jedes mit Standardmenge,
  Anrechnung aufs Tagesziel, Koffein und Zucker je 100 ml. Alles änderbar, eigene Getränke dazu.
  Nicht mehr gebrauchte Getränke werden archiviert, alte Einträge bleiben.
- **Tagesübersicht** mit Koffein- und Zuckersumme, **Wochenansicht** mit Balken, Serie und
  den meistgetrunkenen Getränken.
- **iOS-Kurzbefehle:** Jedes Getränk hat einen eigenen Link. Damit wird Trinken zu einem
  Siri-Satz, einem Widget oder zweimal hinten aufs iPhone klopfen.
- **Sicherung** als JSON-Datei speichern und wieder laden.

## Datenschutz

Alles bleibt im Browser auf deinem Gerät (`localStorage`). Es gibt keinen Server, kein Konto,
keine Cookies, keine Schriften oder Skripte von fremden Seiten. Die Seite wird von GitHub Pages
ausgeliefert; was GitHub dabei protokolliert, regelt GitHub.

Weil Safari Website-Daten nach längerer Pause löschen kann, gibt es unter **Mehr →
Sicherung** einen Export. Ab und zu eine Sicherung in iCloud Drive schadet nicht.

## Kurzbefehle

Kurzbefehle öffnen Links immer in **Safari**. Nutze Trinkimal deshalb auch sonst in Safari und
nicht als Web-App vom Home-Bildschirm, die hat einen eigenen Speicher. Als App-Symbol eignet
sich ein Kurzbefehl, der die Seite öffnet.

### Link-Aufbau

| Link | Wirkung |
| --- | --- |
| `…/trinkimal/#wasser` | Wasser mit Standardmenge eintragen |
| `…/trinkimal/#wasser-500` | 500 ml Wasser |
| `…/trinkimal/#wasser-250-20261014143005` | mit Zeitstempel `JJJJMMTTHHMMSS`: Eintrag zu dieser Uhrzeit, wird nie doppelt gezählt |
| `…/trinkimal/#q_wasser-250-20261014143005_kaffee-200-20261014150000` | mehrere Einträge auf einmal, getrennt durch `_` |

Die Kürzel stehen in der App unter **Mehr → Kurzbefehle** und bei jedem Getränk. Ein Link ohne
Zeitstempel, der innerhalb von 90 Sekunden zweimal geöffnet wird, wird nur nach Rückfrage
noch einmal eingetragen. Nach dem Eintragen entfernt die Seite den Link-Teil aus der Adresse,
damit ein Neuladen nichts doppelt zählt.

### Variante A: Menü, Safari geht kurz auf

1. Kurzbefehl **Trinken** anlegen, Aktion **Aus Menü auswählen**, je Getränk eine Zeile.
2. Unter jede Zeile: **Aktuelles Datum** → **Datum formatieren** (Eigenes Format `yyyyMMddHHmmss`)
   → **URL** `https://malenyaaa.github.io/trinkimal/#wasser-250-` + *Formatiertes Datum*
   → **URLs öffnen**.
3. Starten per Siri („Trinken“), Widget oder Einstellungen → Bedienungshilfen → Tippen →
   Auf Rückseite tippen.

### Variante B: still eintragen, ohne Safari

1. Kurzbefehl **Trinken still**: wie oben, aber statt *URL öffnen* eine Aktion **Text**
   `wasser-250-` + *Formatiertes Datum* und dann **An Textdatei anhängen**
   (`Shortcuts/trinkimal.txt`).
2. Kurzbefehl **Trinkimal öffnen**: **Datei abrufen** `Shortcuts/trinkimal.txt` → **Text ersetzen**
   (Zeilenumbruch durch `_`) → **URL** `https://malenyaaa.github.io/trinkimal/#q_` + *Geänderter Text*
   → **URLs öffnen** → leeren **Text** mit **Datei sichern** nach `Shortcuts/trinkimal.txt`
   (Ersetzen an).

Doppelt übertragene Einträge erkennt Trinkimal am Zeitstempel.

### Apple Health

In jede Menüzeile passt zusätzlich **Gesundheitsprobe protokollieren** (Wasser, Koffein).
Eine Webseite kann Health aber nicht auslesen; die Richtung geht nur von Kurzbefehle nach Health.

## Getränkewerte

Koffein und Zucker sind typische Werte je 100 ml und schwanken je nach Marke und Zubereitung.

**Wie gut ein Getränk wässert** („zählt %“, die Anrechnung aufs Tagesziel) richtet sich nach
Studien. Jeder Wert lässt sich in der App ändern.

| zählt | Getränke | Grundlage |
| --- | --- | --- |
| 130 % | Milch | wässert besser als Wasser: Vollmilch 1,32, fettarme Milch 1,44 mal so gut, auf den Wasseranteil bezogen [1] |
| 100 % | alle anderen alkoholfreien Getränke, auch Kaffee, Tee, Saft, Cola, Energydrink | Kaffee, Tee, Eistee, Cola, Cola light, Sprudel, Sportgetränk und Orangensaft wie Wasser [1]; Kaffee auch über drei Tage bei 3 bis 6 Tassen täglich [2] |
| 100 % | Bier, alkoholfreies Bier | Bier mit etwa 4 bis 5 % wie Wasser [1][3] |
| 50 % | Wein | Wein und Schnaps erhöhen in den ersten Stunden die Harnmenge, über 24 Stunden gleicht es sich aus [3]; 50 % ist eine Schätzung dafür |

Was die Studien nicht abdecken: sehr große Koffeinmengen auf einmal und Schnaps. Zucker macht
für die Wassermenge kaum einen Unterschied, ist aber aus anderen Gründen ungesund; die App zeigt
deshalb die Zuckersumme des Tages, und das Tier merkt an, wenn das letzte Getränk sehr süß war
(ab 8 g je 100 ml).

1. Maughan u. a.: *A randomized trial to assess the potential of different beverages to affect
   hydration status: development of a beverage hydration index*. Am J Clin Nutr 103 (2016) 717–723,
   [doi:10.3945/ajcn.115.114769](https://doi.org/10.3945/ajcn.115.114769)
2. Killer, Blannin, Jeukendrup: *No Evidence of Dehydration with Moderate Daily Coffee Intake*.
   PLoS One 9 (2014) e84154, [doi:10.1371/journal.pone.0084154](https://doi.org/10.1371/journal.pone.0084154)
3. Polhuis u. a.: *The Diuretic Action of Weak and Strong Alcoholic Beverages in Elderly Men*.
   Nutrients 9 (2017) 660, [PMC5537780](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5537780/)

Orientierung in der App: rund 1,5 Liter aus Getränken
am Tag (Deutsche Gesellschaft für Ernährung), bis etwa 400 mg Koffein (EFSA), höchstens 50 g
freier Zucker (WHO).

Trinkimal ist kein Medizinprodukt.

## Aufbau

- `index.html` – die ganze App, CSS und JavaScript eingebettet, ohne Bauschritt
- `manifest.webmanifest`, `icons/` – Name und Symbol
- `tiere/` – Tier-Animationen (Lottie-JSON) mit Standbildern, `getraenke/` – Getränkebilder
- `vendor/lottie_light.min.js` – Abspieler für die Animationen, `fonts/` – Schrift
- Zum Ausprobieren über einen kleinen Webserver öffnen; direkt als Datei geöffnet zeigt die Seite
  Standbilder, weil der Browser die Animationen dann nicht laden darf

## Lizenz

Code: MIT, siehe `LICENSE`.

Fremde Teile, alle mit der Seite ausgeliefert (nichts wird von anderen Servern geladen):

- Tiere und animierte Getränke: [Noto Emoji, animiert](https://googlefonts.github.io/noto-emoji-animation/)
  von Google, CC BY 4.0, siehe `tiere/QUELLE.txt`
- Wasser, Glas mit Eis, Milch, Becher: [Microsoft Fluent Emoji](https://github.com/microsoft/fluentui-emoji),
  MIT, siehe `getraenke/QUELLE-fluent.txt`
- [lottie-web](https://github.com/airbnb/lottie-web) von Airbnb, MIT, siehe `vendor/LICENSE-lottie-web.md`
- Schrift [Fredoka](https://github.com/hafontia/Fredoka-One), SIL Open Font License, siehe `fonts/OFL.txt`
