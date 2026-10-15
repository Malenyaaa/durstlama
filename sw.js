// Trinkimal Service Worker: hält die App für den Offline-Start bereit.
// Server-Anfragen (/api/) gehen immer direkt ans Netz und werden nie zwischengespeichert.
// Bei jeder Änderung an den Dateien unten FASSUNG hochzählen, dann holen sich die Geräte alles neu.
var FASSUNG = "trinkimal-4";
var GRUND = [
  "./", "index.html", "manifest.webmanifest", "vendor/lottie_light.min.js",
  "fonts/fredoka-latin.woff2", "icons/icon.svg", "icons/icon-192.png", "icons/apple-touch-icon.png"
];
var SCOPE = new URL(self.registration.scope).pathname;   // z. B. "/" oder "/trinkimal/"

self.addEventListener("install", function (ev) {
  ev.waitUntil(caches.open(FASSUNG).then(function (c) { return c.addAll(GRUND); }).then(function () { return self.skipWaiting(); }));
});

// Nur eigene alte Fassungen löschen; auf *.github.io teilen sich mehrere Seiten einen Speicher
self.addEventListener("activate", function (ev) {
  ev.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (k) { return k.indexOf("trinkimal-") === 0 && k !== FASSUNG; })
      .map(function (k) { return caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});

self.addEventListener("fetch", function (ev) {
  var req = ev.request;
  if (req.method !== "GET") return;
  var url = new URL(req.url);
  if (url.origin !== location.origin || url.pathname.indexOf("/api/") >= 0 || url.pathname.indexOf("/_/") >= 0) return;

  // Seite selbst: erst das Netz (neueste Fassung), ohne Netz die gespeicherte.
  // Gespeichert wird nur die App-Seite, nie eine Fehlerseite oder eine andere Adresse.
  if (req.mode === "navigate") {
    var isApp = url.pathname === SCOPE || url.pathname === SCOPE + "index.html";
    ev.respondWith(fetch(req).then(function (res) {
      if (isApp && res.ok) { var copy = res.clone(); caches.open(FASSUNG).then(function (c) { c.put("index.html", copy); }); }
      return res;
    }).catch(function () { return caches.match("index.html"); }));
    return;
  }

  // Bilder, Animationen, Schrift: aus dem Speicher, sonst holen und merken
  ev.respondWith(caches.match(req).then(function (hit) {
    return hit || fetch(req).then(function (res) {
      if (res.ok) { var copy = res.clone(); caches.open(FASSUNG).then(function (c) { c.put(req, copy); }); }
      return res;
    });
  }));
});
