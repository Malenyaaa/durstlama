/// <reference path="../pb_data/types.d.ts" />
// Trinkimal: Tabellen für Einträge und Einstellungen, jeder sieht nur seine eigenen Daten.
// Neue Konten legt nur der Besitzer des Servers an (Dashboard → users), keine offene Registrierung.
migrate((app) => {
  const users = app.findCollectionByNameOrId("users")
  users.createRule = null
  // Angemeldet bleiben: 180 Tage, jeder Start der App verlängert
  users.authToken.duration = 180 * 24 * 3600
  app.save(users)

  const own = "owner = @request.auth.id"
  const entries = new Collection({
    type: "base",
    name: "trinkimal_entries",
    listRule: own,
    viewRule: own,
    createRule: "@request.auth.id != '' && @request.body.owner = @request.auth.id",
    updateRule: own + " && (@request.body.owner:isset = false || @request.body.owner = @request.auth.id)",
    deleteRule: own,
    fields: [
      { type: "relation", name: "owner", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
      { type: "text", name: "eid", required: true, max: 60 },
      { type: "number", name: "t", required: true },
      { type: "text", name: "d", max: 24 },
      { type: "text", name: "n", max: 30 },
      { type: "text", name: "c", max: 7 },
      { type: "number", name: "ml" },
      { type: "number", name: "e" },
      { type: "number", name: "caf" },
      { type: "number", name: "sug" },
      { type: "bool", name: "deleted" },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true }
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_trinkimal_entries_owner_eid ON trinkimal_entries (owner, eid)",
      "CREATE INDEX idx_trinkimal_entries_updated ON trinkimal_entries (updated)"
    ]
  })
  app.save(entries)

  const settings = new Collection({
    type: "base",
    name: "trinkimal_settings",
    listRule: own,
    viewRule: own,
    createRule: "@request.auth.id != '' && @request.body.owner = @request.auth.id",
    updateRule: own + " && (@request.body.owner:isset = false || @request.body.owner = @request.auth.id)",
    deleteRule: own,
    fields: [
      { type: "relation", name: "owner", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
      { type: "json", name: "data", maxSize: 200000 },
      // SHA-256 des Kurzbefehl-Schlüssels; der Schlüssel selbst wird nie gespeichert
      { type: "text", name: "logkey", hidden: true, max: 64 },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true }
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_trinkimal_settings_owner ON trinkimal_settings (owner)",
      "CREATE INDEX idx_trinkimal_settings_logkey ON trinkimal_settings (logkey)"
    ]
  })
  app.save(settings)
}, (app) => {
  for (const name of ["trinkimal_settings", "trinkimal_entries"]) {
    try { app.delete(app.findCollectionByNameOrId(name)) } catch (_) {}
  }
  const users = app.findCollectionByNameOrId("users")
  users.createRule = ""
  users.authToken.duration = 604800
  app.save(users)
})
