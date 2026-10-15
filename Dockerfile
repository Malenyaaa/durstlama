# Trinkimal mit PocketBase in einem Container.
# Bauen:   docker compose up -d --build   (siehe docker-compose.yml)
# Daten:   liegen im Volume /pb/pb_data, alles andere wird beim Bauen neu erzeugt.

FROM alpine:3.24.2

ARG PB_VERSION=0.40.4
# Setzt Docker beim Bauen selbst (amd64, arm64 oder arm)
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache ca-certificates \
 && case "${TARGETARCH:-amd64}${TARGETVARIANT}" in \
      amd64*) PB_ARCH=amd64 ;; \
      arm64*) PB_ARCH=arm64 ;; \
      armv7)  PB_ARCH=armv7 ;; \
      *) echo "Diese Prozessor-Art wird nicht unterstützt: ${TARGETARCH}${TARGETVARIANT}" >&2; exit 1 ;; \
    esac \
 && ZIP="pocketbase_${PB_VERSION}_linux_${PB_ARCH}.zip" \
 && URL="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}" \
 && cd /tmp \
 && wget -q "${URL}/${ZIP}" \
 && wget -q "${URL}/checksums.txt" \
 && grep " ${ZIP}\$" checksums.txt | sha256sum -c - \
 && mkdir -p /pb \
 && unzip -q "${ZIP}" pocketbase -d /pb \
 && rm -f "${ZIP}" checksums.txt \
 && chmod 755 /pb/pocketbase \
 && adduser -D -H -u 10001 -s /sbin/nologin trinkimal \
 && mkdir -p /pb/pb_data \
 && chown trinkimal:trinkimal /pb/pb_data

# Nur die App selbst wird öffentlich ausgeliefert, nicht README, server/ oder .git
COPY index.html sw.js manifest.webmanifest /pb/pb_public/
COPY icons     /pb/pb_public/icons
COPY tiere     /pb/pb_public/tiere
COPY getraenke /pb/pb_public/getraenke
COPY fonts     /pb/pb_public/fonts
COPY vendor    /pb/pb_public/vendor
COPY server/pb_hooks      /pb/pb_hooks
COPY server/pb_migrations /pb/pb_migrations

USER trinkimal
WORKDIR /pb
VOLUME /pb/pb_data
EXPOSE 8090

HEALTHCHECK --interval=60s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8090/api/health || exit 1

ENTRYPOINT ["/pb/pocketbase"]
CMD ["serve", "--http=0.0.0.0:8090", "--dir=/pb/pb_data", "--publicDir=/pb/pb_public", "--hooksDir=/pb/pb_hooks", "--migrationsDir=/pb/pb_migrations"]
