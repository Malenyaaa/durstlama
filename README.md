# Durstlama

Ein kostenloser Trink-Tracker mit Lama. Ein Tipp auf ein Getränk trägt es ein, mehr nicht.
Je mehr du trinkst, desto höher steht das Wasser im Teich und desto zufriedener schaut dein Tier.
Zur Auswahl stehen Lama, Hase, Katze, Pinguin, Frosch und Bär, alle selbst gezeichnet
(Tipp aufs Tier oder **Getränke → Dein Tier**).

**Öffnen:** https://malenyaaa.github.io/durstlama/

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

Weil Safari Website-Daten nach längerer Pause löschen kann, gibt es unter **Getränke →
Sicherung** einen Export. Ab und zu eine Sicherung in iCloud Drive schadet nicht.

## Kurzbefehle

Kurzbefehle öffnen Links immer in **Safari**. Nutze Durstlama deshalb auch sonst in Safari und
nicht als Web-App vom Home-Bildschirm, die hat einen eigenen Speicher. Als App-Symbol eignet
sich ein Kurzbefehl, der die Seite öffnet.

### Link-Aufbau

| Link | Wirkung |
| --- | --- |
| `…/durstlama/#wasser` | Wasser mit Standardmenge eintragen |
| `…/durstlama/#wasser-500` | 500 ml Wasser |
| `…/durstlama/#wasser-250-20261014143005` | mit Zeitstempel `JJJJMMTTHHMMSS`: Eintrag zu dieser Uhrzeit, wird nie doppelt gezählt |
| `…/durstlama/#q_wasser-250-20261014143005_kaffee-200-20261014150000` | mehrere Einträge auf einmal, getrennt durch `_` |

Die Kürzel stehen in der App unter **Kurzbefehle** und bei jedem Getränk. Ein Link ohne
Zeitstempel, der innerhalb von 90 Sekunden zweimal geöffnet wird, wird nur nach Rückfrage
noch einmal eingetragen. Nach dem Eintragen entfernt die Seite den Link-Teil aus der Adresse,
damit ein Neuladen nichts doppelt zählt.

### Variante A: Menü, Safari geht kurz auf

1. Kurzbefehl **Trinken** anlegen, Aktion **Aus Menü auswählen**, je Getränk eine Zeile.
2. Unter jede Zeile: **Aktuelles Datum** → **Datum formatieren** (Eigenes Format `yyyyMMddHHmmss`)
   → **URL** `https://malenyaaa.github.io/durstlama/#wasser-250-` + *Formatiertes Datum*
   → **URLs öffnen**.
3. Starten per Siri („Trinken“), Widget oder Einstellungen → Bedienungshilfen → Tippen →
   Auf Rückseite tippen.

### Variante B: still eintragen, ohne Safari

1. Kurzbefehl **Trinken still**: wie oben, aber statt *URL öffnen* eine Aktion **Text**
   `wasser-250-` + *Formatiertes Datum* und dann **An Textdatei anhängen**
   (`Shortcuts/durstlama.txt`).
2. Kurzbefehl **Durstlama öffnen**: **Datei abrufen** `Shortcuts/durstlama.txt` → **Text ersetzen**
   (Zeilenumbruch durch `_`) → **URL** `https://malenyaaa.github.io/durstlama/#q_` + *Geänderter Text*
   → **URLs öffnen** → leeren **Text** mit **Datei sichern** nach `Shortcuts/durstlama.txt`
   (Ersetzen an).

Doppelt übertragene Einträge erkennt Durstlama am Zeitstempel.

### Apple Health

In jede Menüzeile passt zusätzlich **Gesundheitsprobe protokollieren** (Wasser, Koffein).
Eine Webseite kann Health aber nicht auslesen; die Richtung geht nur von Kurzbefehle nach Health.

## Getränkewerte

Koffein und Zucker sind typische Werte je 100 ml und schwanken je nach Marke und Zubereitung.
Die Anrechnung aufs Tagesziel ist 100 % für alle alkoholfreien Getränke; bei Bier (80 %) und
Wein (50 %) ist sie eine grobe Annahme. Orientierung in der App: rund 1,5 Liter aus Getränken
am Tag (Deutsche Gesellschaft für Ernährung), bis etwa 400 mg Koffein (EFSA), höchstens 50 g
freier Zucker (WHO).

Durstlama ist kein Medizinprodukt.

## Aufbau

- `index.html` – die ganze App, CSS und JavaScript eingebettet, ohne Bauschritt
- `manifest.webmanifest`, `icons/` – Name und Symbol
- Zum Ausprobieren `index.html` im Browser öffnen

## Lizenz

MIT, siehe `LICENSE`.
