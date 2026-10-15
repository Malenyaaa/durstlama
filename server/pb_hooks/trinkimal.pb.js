/// <reference path="../pb_data/types.d.ts" />
// Trinkimal: eigene Server-Adressen
//   POST /api/trinkimal/key  (angemeldet)  erzeugt einen neuen Kurzbefehl-Schlüssel, alter wird ungültig
//   POST /api/trinkimal/log  (mit Schlüssel) trägt ein Getränk ein, ohne dass eine Seite aufgeht
// Jeder Handler läuft für sich; gemeinsamer Code muss deshalb per require() geladen werden.

routerAdd("POST", "/api/trinkimal/key", (e) => {
  const lib = require(`${__hooks}/trinkimal_lib.js`)
  const uid = e.auth.id
  const key = $security.randomString(40)
  const st = lib.settingsFor(e.app, uid, true)
  st.set("logkey", $security.sha256(key))
  e.app.save(st)
  return e.json(200, { key: key })
}, $apis.requireAuth("users"))

routerAdd("POST", "/api/trinkimal/log", (e) => {
  const lib = require(`${__hooks}/trinkimal_lib.js`)
  const info = e.requestInfo()
  const body = info.body || {}
  const key = String(body.key || e.request.header.get("X-Trinkimal-Key") || "").trim()
  if (key.length < 20) throw new UnauthorizedError("Schlüssel fehlt. Erzeuge ihn in Trinkimal unter Mehr → Kurzbefehle.")

  let st
  try {
    st = e.app.findFirstRecordByData("trinkimal_settings", "logkey", $security.sha256(key))
  } catch (_) {
    throw new UnauthorizedError("Dieser Schlüssel gilt nicht mehr. Erzeuge in Trinkimal einen neuen.")
  }
  const uid = st.getString("owner")
  const data = lib.jsonOf(st.get("data"))
  const drinks = Array.isArray(data.drinks) ? data.drinks : []
  const id = String(body.drink || body.d || "").toLowerCase().trim()
  const drink = drinks.find((x) => x && x.id === id)
  if (!drink) throw new BadRequestError("Ein Getränk mit dem Kürzel „" + id + "“ gibt es nicht.")

  let ml = Number(body.ml)
  if (!isFinite(ml) || ml <= 0) ml = Number(drink.ml) || 250
  ml = Math.min(2000, Math.max(10, Math.round(ml)))
  const f = isFinite(Number(drink.f)) ? Number(drink.f) : 100
  const now = Date.now()

  const r = new Record(e.app.findCollectionByNameOrId("trinkimal_entries"))
  r.set("owner", uid)
  r.set("eid", "s" + now.toString(36) + $security.randomString(5).toLowerCase())
  r.set("t", now)
  r.set("d", drink.id)
  r.set("n", String(drink.name || "Getränk").slice(0, 30))
  r.set("c", /^#[0-9a-fA-F]{6}$/.test(drink.color) ? drink.color : "#4FB3E8")
  r.set("ml", ml)
  r.set("e", Math.round(ml * f / 100))
  r.set("caf", Math.round(ml * (Number(drink.caf) || 0) / 100))
  r.set("sug", Math.round(ml * (Number(drink.sug) || 0) / 10) / 10)
  e.app.save(r)

  // Tagessumme in der Zeitzone, die die App zuletzt gemeldet hat
  const tzo = isFinite(Number(data.tzo)) ? Number(data.tzo) : 0
  const local = now - tzo * 60000
  const start = Math.floor(local / 864e5) * 864e5 + tzo * 60000
  const today = e.app.findRecordsByFilter("trinkimal_entries",
    "owner = {:o} && t >= {:t} && deleted = false", "", 0, 0, { o: uid, t: start })
  let sum = 0
  today.forEach((x) => { sum += x.getFloat("e") })
  const goal = Number(data.goal) || 2000
  const fmt = (n) => String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ".")
  const text = String(drink.name || "Getränk") + ", " + fmt(ml) + " ml eingetragen. Heute " + fmt(sum) + " von " + fmt(goal) + " ml."
  return e.json(200, { ok: true, text: text, today: Math.round(sum), goal: goal })
})
