# Trinkimal

Ein kostenloser Trink-Tracker mit Tier. Ein Tipp auf ein Getränk trägt es ein, mehr nicht.
Dein Tier sitzt animiert im Teich, und je mehr du trinkst, desto höher steht das Wasser. Es trinkt
bei jedem Eintrag mit. Bekommt es tagsüber länger nichts, wird es durstig: ab zwei Stunden lässt
es den Kopf hängen, ab vier schwitzt und wackelt es. Nachts zwischen 22 und 7 Uhr zählt die Pause
nicht. Beim Tagesziel hüpft es, und Herzen steigen auf.

33 Tiere: Panda, Katze und Hase sind von Anfang an da, die anderen schaltest du durchs Trinken frei
(Tipp aufs Tier oder **Mehr → Dein Tier** zeigt, was fehlt). Leichte Tiere kommen schnell, etwa das
Küken nach dem ersten Getränk oder der Otter nach 3 Tagen am Stück. Gezählt werden abgeschlossene
Tage, ein neues Tier zieht also am nächsten Morgen ein. **Seltene** brauchen Ausdauer
(Tiger: 30 Tage am Stück), **legendäre** sind richtig schwer: Drache (100 Tage am Stück), Pfau
(ein ganzer Monat), Einhorn, Dino, Phönix, Fledermaus, Timmy der Wal (1.000 Liter) und als
allerletztes der Schmetterling, wenn alle anderen frei sind.
Ausgewertet wird rückwirkend aus allen Einträgen; nichts davon verlangt Alkohol oder Energydrinks.
Beim Tagesziel ist der Teich randvoll, darüber läuft er über. Die Getränke-Knöpfe sind ebenfalls
animiert: Kaffee dampft, Bubble Tea blubbert.

**Öffnen:** https://malenyaaa.github.io/trinkimal/

## Was es kann

- **Ein Tipp pro Glas.** Die Lieblingsgetränke liegen als Kacheln auf der Startseite. Für eine
  andere Menge vorher einen Mengen-Knopf wählen (150 bis 500 ml), danach springt er zurück.
  Jeder Eintrag lässt sich einige Sekunden lang rückgängig machen.
- **Über 30 Getränke** von Wasser über Smoothie und Mate bis alkoholfreies Bier, jedes mit Standardmenge,
  Anrechnung aufs Tagesziel, Koffein und Zucker je 100 ml. Alles änderbar, eigene Getränke dazu.
  Nicht mehr gebrauchte Getränke werden archiviert, alte Einträge bleiben.
- **Tagesübersicht** mit Koffein- und Zuckersumme, **Wochenansicht** mit Balken, Serie (unter Mehr → Tagesziel pausierbar, etwa im Urlaub),
  Monatskalender und
  den meistgetrunkenen Getränken.
- **iOS-Kurzbefehle:** Jedes Getränk hat einen eigenen Link. Damit wird Trinken zu einem
  Siri-Satz, einem Widget oder zweimal hinten aufs iPhone klopfen.
- **Sicherung** als JSON-Datei speichern und wieder laden.
- **Als App installierbar (PWA):** auf den Home-Bildschirm legen, startet ohne Browserleiste und
  funktioniert auch offline.
- **Optional mit eigenem Server:** Läuft Trinkimal auf deinem eigenen Server (PocketBase, siehe
  [Eigener Server](#eigener-server)), meldest du dich unter **Mehr** an. Dann sehen alle Geräte
  dieselben Einträge, und Kurzbefehle tragen still ein, ohne dass sich etwas öffnet.

## Zwei Betriebsarten

| | ohne Server (z. B. GitHub Pages) | mit eigenem Server |
| --- | --- | --- |
| Daten | nur im Browser des Geräts | im Browser und in deinem Konto auf dem Server |
| mehrere Geräte | jedes für sich | alle gleich, Abgleich automatisch |
| Kurzbefehle | Link öffnet Safari kurz | still im Hintergrund, Rückmeldung als Mitteilung |
| Offline | ja | ja, Abgleich beim nächsten Netz |

## Datenschutz

Ohne Server bleibt alles im Browser auf deinem Gerät (`localStorage`). Es gibt kein Konto,
keine Cookies, keine Schriften oder Skripte von fremden Seiten. Die Seite wird von GitHub Pages
ausgeliefert; was GitHub dabei protokolliert, regelt GitHub. Mit eigenem Server liegen die
Einträge zusätzlich nur dort, wo du ihn betreibst.

Weil Safari Website-Daten nach längerer Pause löschen kann, gibt es unter **Mehr →
Sicherung** einen Export. Ab und zu eine Sicherung in iCloud Drive schadet nicht. Als App vom
Home-Bildschirm gestartet, löscht iOS die Daten nicht.

## Kurzbefehle

**Mit eigenem Server:** unter **Mehr → Kurzbefehle** einen Schlüssel erzeugen und die Aktion
„Inhalte von URL abrufen“ mit `POST` an `https://deine-domain/api/trinkimal/log` schicken,
Header `X-Trinkimal-Key`, JSON-Feld `drink` (Kürzel), optional `ml` und `stamp` (aktuelles Datum
als `yyyyMMddHHmmss`; dieselbe Anfrage zweimal ergibt dann nur einen Eintrag). Die Antwort enthält
im Feld `text` eine Rückmeldung wie „Wasser, 250 ml eingetragen. Heute 1.250 von 2.000 ml.“

**Ohne Server** öffnen Kurzbefehle Links immer in **Safari**. Nutze Trinkimal dann auch sonst in
Safari und nicht als App vom Home-Bildschirm, die hätte einen eigenen Speicher.

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

## Eigener Server

Ohne Server bleibt alles im Browser auf einem Gerät. Mit einem eigenen Server bekommst du ein
Konto: Handy, Tablet und Rechner zeigen dieselben Einträge, und Kurzbefehle tragen still ein,
ohne dass Safari aufgeht.

Der Server ist [PocketBase](https://pocketbase.io) (Version 0.40.4), ein einzelnes Programm mit
eingebauter Datenbank. Es liefert auch die App selbst aus. Du brauchst also nur diesen einen
Dienst. Alles für den Server liegt in diesem Repo:

| Datei | wofür |
| --- | --- |
| `Dockerfile`, `docker-compose.yml` | Weg A und C: mit Docker |
| `server/install.sh`, `server/trinkimal.service` | Weg B: Linux ohne Docker |
| `server/install-windows.ps1` | Weg D: Windows |
| `server/pb_hooks/`, `server/pb_migrations/` | Tabellen und Server-Funktionen von Trinkimal |
| `server/Caddyfile` | HTTPS mit Caddy (optional) |

### Dateien holen

Auf dem Server, mit Git:

```sh
git clone https://github.com/Malenyaaa/trinkimal.git
cd trinkimal
```

Ohne Git: auf GitHub **Code → Download ZIP**, entpacken und den Ordner auf den Server kopieren.

### Welchen Server hast du?

Finde zuerst heraus, was für ein Gerät es ist. Danach weißt du, welcher Weg passt.

1. **NAS** (Synology, QNAP, Unraid, TrueNAS …): Hat es eine Weboberfläche mit einer App wie
   **Container Manager**, **Container Station** oder **Docker**? Dann nimm **Weg C**. Fehlt so eine
   App, kann das NAS Trinkimal meist nicht betreiben.
2. **Windows-Rechner:** nimm **Weg D**.
3. **Linux** (Raspberry Pi, gemieteter Server, alter PC): Melde dich per SSH an und tippe:

   ```sh
   uname -a
   docker --version
   ```

   - `uname -a` zeigt den Prozessor. `x86_64`, `aarch64` und `armv7l` gehen.
     Anderes (zum Beispiel `armv6l` beim ganz alten Raspberry Pi) geht nicht.
   - Antwortet `docker --version` mit einer Versionsnummer: nimm **Weg A**.
   - Kommt `command not found`: nimm **Weg B**. Oder installiere Docker und nimm dann Weg A.

### Weg A: Linux mit Docker

Im Trinkimal-Ordner:

```sh
docker compose up -d --build
```

Beim ersten Mal lädt Docker PocketBase herunter und prüft die Prüfsumme. Danach läuft
Trinkimal auf Port 8090 und startet nach einem Neustart von selbst wieder.

Weiter mit **Erstes Konto anlegen**. Der Befehl für das Admin-Konto lautet bei Docker:

```sh
docker compose exec trinkimal /pb/pocketbase superuser upsert du@example.de EinLangesPasswort --dir=/pb/pb_data
```

Die Daten liegen im Docker-Volume `trinkimal_daten`. Sie bleiben bei Updates erhalten.

### Weg B: Linux ohne Docker

Im Trinkimal-Ordner:

```sh
sudo sh server/install.sh
```

Das Skript

- lädt PocketBase passend zum Prozessor und prüft die Prüfsumme,
- legt alles nach `/opt/trinkimal` (App, Server-Teil, Daten in `pb_data`),
- legt den Benutzer `trinkimal` an, damit der Server nicht als root läuft,
- richtet den Dienst `trinkimal` ein, der mit dem Rechner startet und nach einem Absturz neu startet.

Fehlt `unzip`, installiere es vorher, zum Beispiel mit `sudo apt install unzip`.

Nützliche Schalter: `--port 8091` (anderer Port), `--domain trinkimal.example.de` (siehe HTTPS),
`--dir /srv/trinkimal` (anderer Ordner), `--no-service` (kein Dienst).

Den Dienst steuerst du mit `sudo systemctl status trinkimal`, `restart` oder `stop`.
Fehlermeldungen zeigt `journalctl -u trinkimal -n 50`.

Admin-Konto bei diesem Weg:

```sh
sudo -u trinkimal /opt/trinkimal/pocketbase superuser upsert du@example.de EinLangesPasswort --dir=/opt/trinkimal/pb_data
```

### Weg C: NAS mit Container-App

Kopiere den Trinkimal-Ordner auf das NAS, zum Beispiel in den Ordner `docker`.

- **Synology (Container Manager):** **Projekt → Erstellen**. Als Pfad den Trinkimal-Ordner wählen.
  Die vorhandene `docker-compose.yml` übernehmen und das Projekt erstellen lassen.
- **QNAP (Container Station):** **Anwendungen → Erstellen**. Den Inhalt von `docker-compose.yml`
  einfügen. Ist der Bau aus dem Ordner dort nicht möglich, nimm den SSH-Weg unten.
- **Andere NAS oder per SSH:** am NAS per SSH anmelden, in den Ordner wechseln und wie bei Weg A
  `docker compose up -d --build` ausführen.

Das NAS braucht beim Bauen Internet. Den Befehl für das Admin-Konto führst du per SSH aus
(siehe Weg A) oder im Container-Terminal der NAS-Oberfläche:
`/pb/pocketbase superuser upsert du@example.de EinLangesPasswort --dir=/pb/pb_data`.

Belegt eine andere App schon Port 8090, ändere in `docker-compose.yml` die Zeile
`"8090:8090"` in zum Beispiel `"8091:8090"`. Dann ist Trinkimal unter Port 8091 erreichbar.

### Weg D: Windows

PowerShell im Trinkimal-Ordner öffnen. Für den Autostart als Administrator.

```powershell
powershell -ExecutionPolicy Bypass -File server\install-windows.ps1 -Autostart -Firewall
```

Das Skript lädt PocketBase, prüft die Prüfsumme und legt alles nach `C:\Trinkimal`.
`-Autostart` startet Trinkimal mit Windows, auch ohne Anmeldung. `-Firewall` gibt den Port frei,
damit dein Handy den Rechner erreicht. Ohne diese beiden Schalter startest du Trinkimal per
Doppelklick auf `C:\Trinkimal\start-trinkimal.cmd`. Das Fenster muss dann offen bleiben.

Weitere Schalter: `-Ziel D:\Trinkimal`, `-Port 8091`, `-Domain trinkimal.example.de`.

Admin-Konto bei diesem Weg:

```powershell
& "C:\Trinkimal\pocketbase.exe" superuser upsert du@example.de EinLangesPasswort --dir="C:\Trinkimal\pb_data"
```

Der Rechner muss laufen, solange du Trinkimal nutzen willst. Für dauerhaften Betrieb ist ein
kleiner Linux-Server oder ein NAS meist besser.

### Erreichbar machen und HTTPS

Nach der Einrichtung ist Trinkimal im Heimnetz unter `http://ADRESSE-DES-SERVERS:8090/` erreichbar,
also zum Beispiel `http://192.168.178.20:8090/`.

**Ohne HTTPS funktioniert nicht alles.** Am iPhone lassen sich die App nur mit HTTPS auf den
Home-Bildschirm installieren und offline starten. Der Browser erlaubt den Service Worker nur bei
`https://` oder unter `localhost`. Außerdem gehen Passwort und Schlüssel ohne HTTPS unverschlüsselt
durchs Netz. Für den Test im Heimnetz reicht `http://`, auf Dauer brauchst du HTTPS.

Für HTTPS brauchst du eine **eigene Domain** (oder Subdomain, zum Beispiel von einem
DynDNS-Anbieter), die auf deinen Server zeigt. Im Heimnetz leitest du am Router die Ports
**80 und 443** an den Server weiter. Die App muss direkt unter der Domain liegen, nicht in einem
Unterordner wie `/trinkimal/`.

Dann hast du drei Möglichkeiten:

1. **PocketBase macht HTTPS selbst** (einfachster Weg, wenn auf dem Server sonst nichts läuft).
   PocketBase holt das Zertifikat bei Let's Encrypt und erneuert es selbst.
   - Weg B: `sudo sh server/install.sh --domain trinkimal.example.de`
   - Weg D: `server\install-windows.ps1 -Domain trinkimal.example.de -Autostart -Firewall`
2. **Caddy davor** (bei Docker am einfachsten): Domain in `server/Caddyfile` eintragen. In
   `docker-compose.yml` den Caddy-Teil einkommentieren und bei Trinkimal `"8090:8090"` durch
   `"127.0.0.1:8090:8090"` ersetzen. Dann `docker compose up -d --build`.
   Caddy kümmert sich um das Zertifikat.
3. **Vorhandener Reverse-Proxy** (nginx, Caddy, der Proxy im NAS): eine neue Weiterleitung von
   `https://trinkimal.example.de` auf `http://127.0.0.1:8090` anlegen. Für nginx:

   ```nginx
   server {
       listen 443 ssl;
       server_name trinkimal.example.de;
       # ssl_certificate … wie bei deinen anderen Seiten
       client_max_body_size 10M;
       location / {
           proxy_set_header Connection '';
           proxy_http_version 1.1;
           proxy_read_timeout 360s;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_pass http://127.0.0.1:8090;
       }
   }
   ```

   Bei Synology heißt das **Systemsteuerung → Anmeldeportal → Erweitert → Reverse Proxy**.

Steht ein Proxy davor (Möglichkeit 2 oder 3), trag im Dashboard unter **Settings** bei
**User IP proxy headers** den Wert `X-Forwarded-For` ein. Sonst sieht PocketBase bei jeder Anfrage
nur die Adresse des Proxys.

### Erstes Konto anlegen

1. **Admin-Konto** (Superuser) mit dem Befehl aus deinem Weg anlegen. Nimm eine echte E-Mail-Adresse
   statt `du@example.de` und ein langes Passwort. Der Befehl ändert das Passwort, wenn es das Konto
   schon gibt.
2. Im Browser das Dashboard öffnen: `https://trinkimal.example.de/_/`
   (ohne HTTPS: `http://ADRESSE-DES-SERVERS:8090/_/`) und mit dem Admin-Konto anmelden.
3. Links **users** wählen, dann **New record**. E-Mail und Passwort eintragen, speichern.
   Das ist dein Konto für die App. Für jede weitere Person legst du hier ein eigenes Konto an.

Eine offene Registrierung gibt es absichtlich nicht. Fremde können sich auf deinem Server also
kein Konto anlegen. Das Admin-Konto ist nur für das Dashboard, nicht für die App.

### Was die App dann kann

Öffne Trinkimal über die Adresse deines Servers, nicht über GitHub Pages. Die App merkt dann von
selbst, dass ein Server da ist.

- **Anmeldung** unter **Mehr → Konto auf deinem Server** mit dem Konto aus `users`.
- **Abgleich:** Einträge und Einstellungen landen im Konto. Jedes angemeldete Gerät zeigt dasselbe.
  Ohne Netz trägst du weiter ein, abgeglichen wird, sobald der Server wieder erreichbar ist.
- **Stille Kurzbefehle:** Unter **Mehr → Kurzbefehle** einen Schlüssel erzeugen. Ein Kurzbefehl
  schickt dann `POST https://trinkimal.example.de/api/trinkimal/log` mit dem Header
  `X-Trinkimal-Key: DEIN-SCHLÜSSEL` und dem JSON-Text `{"drink": "wasser", "ml": 300}`.
  Die Antwort enthält im Feld `text` zum Beispiel „Wasser, 300 ml eingetragen. Heute 1.250 von
  2.000 ml.“ Es öffnet sich keine Seite. Die genauen Schritte stehen in der App.
  Ein neuer Schlüssel macht den alten ungültig.

### Update

Erst die Dateien aktualisieren (`git pull` oder neue ZIP entpacken), dann:

- Weg A und C: `docker compose up -d --build`
- Weg B: `sudo sh server/install.sh` (Port oder Domain vom ersten Mal bleiben)
- Weg D: `server\install-windows.ps1` erneut ausführen (Port oder Domain vom letzten Mal bleiben)

Konten und Einträge in `pb_data` bleiben dabei erhalten.

### Sicherung

Alles Wichtige steckt im Ordner `pb_data`. Zwei Wege:

- **Im Dashboard:** **Settings → Backups → Initialize new backup**. Das ergibt eine ZIP-Datei,
  die du herunterlädst. Dort lässt sich auch eine tägliche Sicherung einstellen.
  Zurückspielen geht an derselben Stelle.
- **Ordner kopieren:** Server anhalten, `pb_data` kopieren, Server wieder starten.
  Bei Weg B liegt er in `/opt/trinkimal/pb_data`, bei Weg D in `C:\Trinkimal\pb_data`.
  Bei Docker steckt er im Volume `trinkimal_daten`; hier ist das Dashboard der einfachere Weg.

Bewahre eine Sicherung außerhalb des Servers auf. Zusätzlich kann jede Person in der App unter
**Mehr → Sicherung** ihre eigenen Daten als Datei speichern.

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
- `sw.js` – Service Worker für den Offline-Start; bei Änderungen an App-Dateien `FASSUNG` hochzählen
- `konzept/` – Pläne für später (Freunde, Bestenliste, Gruppen-Events)
- `server/` – PocketBase-Tabellen (`pb_migrations/`), Server-Adressen (`pb_hooks/`) und Installation
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
- Server: [PocketBase](https://github.com/pocketbase/pocketbase), MIT; wird bei der Installation von GitHub geladen und ist nicht im Repo
