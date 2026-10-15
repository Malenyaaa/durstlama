#!/bin/sh
# Trinkimal mit PocketBase auf Linux einrichten oder aktualisieren (ohne Docker).
#
#   sudo sh server/install.sh                              Port 8090, als Dienst
#   sudo sh server/install.sh --domain trinkimal.example.de   eigene Domain, HTTPS über Let's Encrypt
#
# Weitere Schalter:
#   --dir ORDNER     Zielordner (Standard /opt/trinkimal)
#   --port ZAHL      Port ohne Domain (Standard 8090)
#   --zip DATEI      PocketBase-Zip nicht herunterladen, sondern diese Datei nehmen
#   --no-service     keinen systemd-Dienst einrichten
#
# Update: Repo aktualisieren und das Skript erneut ausführen. pb_data (Konten, Einträge) bleibt.

set -eu

PB_VERSION=0.40.4
DIR=/opt/trinkimal
DOMAIN=""
PORT=""
ZIP=""
SERVICE=1

fehler() { echo "FEHLER: $*" >&2; exit 1; }
info() { echo "==> $*"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DIR="${2:?--dir braucht einen Ordner}"; shift 2 ;;
    --domain) DOMAIN="${2:?--domain braucht eine Domain}"; shift 2 ;;
    --port) PORT="${2:?--port braucht eine Zahl}"; shift 2 ;;
    --zip) ZIP="${2:?--zip braucht eine Datei}"; shift 2 ;;
    --no-service) SERVICE=0; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) fehler "Unbekannter Schalter: $1 (Hilfe: --help)" ;;
  esac
done

case "$DIR" in /*) ;; *) fehler "--dir muss ein absoluter Pfad sein, z. B. /opt/trinkimal" ;; esac
DIR="${DIR%/}"
if [ -n "$PORT" ]; then
  case "$PORT" in ''|*[!0-9]*) fehler "--port muss eine Zahl sein" ;; esac
fi

# Repo-Ordner = eine Ebene über diesem Skript
REPO=$(cd "$(dirname "$0")/.." && pwd)
[ -f "$REPO/index.html" ] && [ -d "$REPO/server/pb_hooks" ] \
  || fehler "Die App-Dateien fehlen. Das Skript aus dem entpackten Trinkimal-Ordner starten: sh server/install.sh"

[ "$(id -u)" -eq 0 ] || fehler "Bitte mit sudo starten: sudo sh server/install.sh"

command -v unzip >/dev/null 2>&1 || fehler "unzip fehlt. Installieren, z. B.: apt install unzip  (oder dnf install unzip)"
command -v sha256sum >/dev/null 2>&1 || fehler "sha256sum fehlt (Paket coreutils)."

lade() { # lade URL DATEI
  if command -v curl >/dev/null 2>&1; then curl -fsSL -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then wget -q -O "$2" "$1"
  else fehler "Weder curl noch wget gefunden. Eins davon installieren."
  fi
}

case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  armv7*|armv8l) ARCH=armv7 ;;
  *) fehler "Prozessor $(uname -m) wird nicht unterstützt (nur x86_64, aarch64, armv7)." ;;
esac
NAME="pocketbase_${PB_VERSION}_linux_${ARCH}.zip"
URL="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

# 1. PocketBase holen und Prüfsumme prüfen
if [ -n "$ZIP" ]; then
  [ -f "$ZIP" ] || fehler "Zip nicht gefunden: $ZIP"
  cp "$ZIP" "$TMP/$NAME"
else
  info "Lade PocketBase $PB_VERSION ($ARCH) ..."
  lade "$URL/$NAME" "$TMP/$NAME"
fi
lade "$URL/checksums.txt" "$TMP/checksums.txt" || fehler "checksums.txt ließ sich nicht laden, Prüfung nicht möglich."
grep " $NAME\$" "$TMP/checksums.txt" > "$TMP/soll.txt" || fehler "$NAME steht nicht in checksums.txt."
(cd "$TMP" && sha256sum -c soll.txt >/dev/null) || fehler "Prüfsumme stimmt nicht. Datei beschädigt oder falsche Version."
info "Prüfsumme in Ordnung."
unzip -q -o "$TMP/$NAME" pocketbase -d "$TMP/pb"

# 2. Benutzer und Ordner
if ! id trinkimal >/dev/null 2>&1; then
  info "Lege Systembenutzer trinkimal an ..."
  if command -v useradd >/dev/null 2>&1; then
    useradd --system --home-dir "$DIR" --no-create-home --shell /usr/sbin/nologin trinkimal
  else
    adduser -S -D -H -h "$DIR" -s /sbin/nologin trinkimal  # BusyBox/Alpine
  fi
fi
mkdir -p "$DIR/pb_data" "$DIR/pb_hooks" "$DIR/pb_migrations"

# 3. Dateien kopieren. pb_public wird komplett ersetzt, pb_data nie angefasst.
info "Kopiere App nach $DIR ..."
install -m 755 "$TMP/pb/pocketbase" "$DIR/pocketbase.neu"
mv -f "$DIR/pocketbase.neu" "$DIR/pocketbase"

rm -rf "$DIR/pb_public.neu"
mkdir -p "$DIR/pb_public.neu"
cp "$REPO/index.html" "$REPO/sw.js" "$REPO/manifest.webmanifest" "$DIR/pb_public.neu/"
for d in icons tiere getraenke fonts vendor; do
  cp -R "$REPO/$d" "$DIR/pb_public.neu/$d"
done
rm -rf "$DIR/pb_public.alt"
[ -d "$DIR/pb_public" ] && mv "$DIR/pb_public" "$DIR/pb_public.alt"
mv "$DIR/pb_public.neu" "$DIR/pb_public"
rm -rf "$DIR/pb_public.alt"

cp "$REPO"/server/pb_hooks/* "$DIR/pb_hooks/"
cp "$REPO"/server/pb_migrations/* "$DIR/pb_migrations/"

# 4. Einstellungen: Datei nur beim ersten Mal anlegen, danach nur auf Wunsch ändern
ENV="$DIR/trinkimal.env"
if [ ! -f "$ENV" ]; then
  cat > "$ENV" <<EOF
# Wie PocketBase erreichbar ist. Nach einer Änderung: sudo systemctl restart trinkimal
# Ohne Domain (nur im Heimnetz oder hinter Caddy/nginx):
#   TRINKIMAL_ARGS=--http=0.0.0.0:8090
# Mit eigener Domain, HTTPS-Zertifikat automatisch (Ports 80 und 443 müssen frei sein):
#   TRINKIMAL_ARGS=trinkimal.example.de
TRINKIMAL_ARGS=--http=0.0.0.0:${PORT:-8090}
EOF
fi
setze() { # setze WERT: TRINKIMAL_ARGS ersetzen
  grep -v '^TRINKIMAL_ARGS=' "$ENV" > "$ENV.neu" || true
  echo "TRINKIMAL_ARGS=$1" >> "$ENV.neu"
  mv -f "$ENV.neu" "$ENV"
}
if [ -n "$DOMAIN" ]; then setze "$DOMAIN"
elif [ -n "$PORT" ]; then setze "--http=0.0.0.0:$PORT"
fi
chmod 644 "$ENV"

chown -R root:root "$DIR/pocketbase" "$DIR/pb_public" "$DIR/pb_hooks" "$DIR/pb_migrations" "$ENV"
chown -R trinkimal:trinkimal "$DIR/pb_data"
chmod 750 "$DIR/pb_data"

PB="$DIR/pocketbase"
FLAGS="--dir=$DIR/pb_data --publicDir=$DIR/pb_public --hooksDir=$DIR/pb_hooks --migrationsDir=$DIR/pb_migrations"

# 5. Dienst
if [ "$SERVICE" -eq 1 ]; then
  command -v systemctl >/dev/null 2>&1 || fehler "Kein systemd gefunden. Mit --no-service erneut starten und PocketBase selbst starten."
  case "$DIR" in
    /home/*|/root/*) OHNE='/^ProtectHome=/d' ;;  # sonst kommt der Dienst nicht an seinen Ordner
    *) OHNE='' ;;
  esac
  sed -e "s#/opt/trinkimal#$DIR#g" ${OHNE:+-e "$OHNE"} "$REPO/server/trinkimal.service" > /etc/systemd/system/trinkimal.service
  systemctl daemon-reload
  systemctl enable trinkimal.service >/dev/null 2>&1
  systemctl restart trinkimal.service
  sleep 2
  if systemctl is-active --quiet trinkimal.service; then
    info "Dienst trinkimal läuft."
  else
    echo "Der Dienst ist nicht gestartet. Fehler ansehen: journalctl -u trinkimal -n 50" >&2
    exit 1
  fi
else
  info "Ohne Dienst. Von Hand starten mit:"
  echo "  sudo -u trinkimal $PB serve $(grep '^TRINKIMAL_ARGS=' "$ENV" | cut -d= -f2-) $FLAGS"
fi

ARGS=$(grep '^TRINKIMAL_ARGS=' "$ENV" | cut -d= -f2-)
case "$ARGS" in
  --http=*) ADR="http://ADRESSE-DES-SERVERS:${ARGS##*:}" ;;
  *) ADR="https://$ARGS" ;;
esac

cat <<EOF

Fertig. Trinkimal liegt in $DIR, die Daten in $DIR/pb_data.

Erstes Admin-Konto anlegen (nur einmal nötig):
  sudo -u trinkimal $PB superuser upsert du@example.de EinLangesPasswort --dir=$DIR/pb_data

Dann im Browser:
  App:        $ADR/
  Dashboard:  $ADR/_/   (dort unter "users" dein Konto für die App anlegen)
EOF
