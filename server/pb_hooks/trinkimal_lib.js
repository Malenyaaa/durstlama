// Gemeinsame Helfer für trinkimal.pb.js (per require geladen, kein eigener Hook)

// JSON-Feld eines Datensatzes als normales Objekt
function jsonOf(raw) {
  if (raw == null) return {}
  try {
    const s = typeof raw === "string" ? raw : (raw.string ? raw.string() : JSON.stringify(raw))
    const v = typeof s === "string" ? JSON.parse(s || "{}") : s
    return v && typeof v === "object" ? v : {}
  } catch (_) {
    return {}
  }
}

// Einstellungs-Datensatz eines Kontos; legt ihn auf Wunsch an
function settingsFor(app, uid, create) {
  try {
    return app.findFirstRecordByData("trinkimal_settings", "owner", uid)
  } catch (_) {
    if (!create) throw _
    const r = new Record(app.findCollectionByNameOrId("trinkimal_settings"))
    r.set("owner", uid)
    r.set("data", {})
    return r
  }
}

module.exports = { jsonOf: jsonOf, settingsFor: settingsFor }
