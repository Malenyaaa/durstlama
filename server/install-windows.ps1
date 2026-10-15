<#
Trinkimal mit PocketBase auf Windows einrichten oder aktualisieren.

Aufruf in PowerShell, im entpackten Trinkimal-Ordner:
  powershell -ExecutionPolicy Bypass -File server\install-windows.ps1
  powershell -ExecutionPolicy Bypass -File server\install-windows.ps1 -Ziel D:\Trinkimal -Autostart -Firewall

Schalter:
  -Ziel ORDNER     wohin (Standard C:\Trinkimal)
  -Port ZAHL       Port ohne Domain (Standard 8090)
  -Domain NAME     eigene Domain, HTTPS-Zertifikat automatisch (Ports 80 und 443 noetig)
  -ZipDatei DATEI  PocketBase-Zip nicht herunterladen, sondern diese Datei nehmen
  -Autostart       startet Trinkimal mit Windows (geplante Aufgabe, braucht Administrator)
  -Firewall        gibt den Port in der Windows-Firewall frei (braucht Administrator)

Update: Ordner aktualisieren und das Skript erneut ausfuehren. pb_data (Konten, Eintraege) bleibt.
Port und Domain vom letzten Lauf bleiben gespeichert, solange du sie nicht neu angibst.
#>
[CmdletBinding()]
param(
  [string]$Ziel = "C:\Trinkimal",
  [int]$Port = 8090,
  [string]$Domain = "",
  [string]$ZipDatei = "",
  [switch]$Autostart,
  [switch]$Firewall
)

$ErrorActionPreference = "Stop"
$PbVersion = "0.40.4"
$Aufgabe = "Trinkimal"

function Info($t) { Write-Host "==> $t" }
function Fehler($t) { Write-Host "FEHLER: $t" -ForegroundColor Red; exit 1 }

function IstAdmin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  return (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$Repo = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Repo "index.html")) -or -not (Test-Path (Join-Path $Repo "server\pb_hooks"))) {
  Fehler "Die App-Dateien fehlen. Das Skript aus dem entpackten Trinkimal-Ordner starten."
}
if (($Autostart -or $Firewall) -and -not (IstAdmin)) {
  Fehler "Fuer -Autostart und -Firewall PowerShell als Administrator starten."
}

$Ziel = [IO.Path]::GetFullPath($Ziel).TrimEnd("\")
New-Item -ItemType Directory -Force -Path $Ziel | Out-Null

# Einstellungen vom letzten Lauf uebernehmen, wenn nichts Neues angegeben ist
$Cfg = Join-Path $Ziel "trinkimal.cfg"
if (Test-Path $Cfg) {
  $alt = @{}
  Get-Content $Cfg | ForEach-Object { if ($_ -match '^(\w+)=(.*)$') { $alt[$matches[1]] = $matches[2] } }
  if (-not $PSBoundParameters.ContainsKey("Port") -and $alt.Port) { $Port = [int]$alt.Port }
  if (-not $PSBoundParameters.ContainsKey("Domain") -and $alt.Domain) { $Domain = $alt.Domain }
}
if ($Port -lt 1 -or $Port -gt 65535) { Fehler "Port muss zwischen 1 und 65535 liegen." }

# 1. PocketBase holen und Pruefsumme pruefen
switch ($env:PROCESSOR_ARCHITECTURE) {
  "AMD64" { $Arch = "amd64" }
  "ARM64" { $Arch = "arm64" }
  default { Fehler "Prozessor $($env:PROCESSOR_ARCHITECTURE) wird nicht unterstuetzt (nur 64 Bit)." }
}
$Name = "pocketbase_${PbVersion}_windows_${Arch}.zip"
$Url = "https://github.com/pocketbase/pocketbase/releases/download/v$PbVersion"
$Tmp = Join-Path ([IO.Path]::GetTempPath()) ("trinkimal-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  $ProgressPreference = "SilentlyContinue"
  $ZipZiel = Join-Path $Tmp $Name
  if ($ZipDatei) {
    if (-not (Test-Path $ZipDatei)) { Fehler "Zip nicht gefunden: $ZipDatei" }
    Copy-Item $ZipDatei $ZipZiel
  } else {
    Info "Lade PocketBase $PbVersion ($Arch) ..."
    Invoke-WebRequest -UseBasicParsing -Uri "$Url/$Name" -OutFile $ZipZiel
  }
  try {
    $Summen = (Invoke-WebRequest -UseBasicParsing -Uri "$Url/checksums.txt").Content
  } catch {
    Fehler "checksums.txt liess sich nicht laden, Pruefung nicht moeglich."
  }
  if ($Summen -is [byte[]]) { $Summen = [Text.Encoding]::ASCII.GetString($Summen) }
  $Zeile = ($Summen -split "`n") | Where-Object { $_ -match ("\s" + [regex]::Escape($Name) + "\s*$") } | Select-Object -First 1
  if (-not $Zeile) { Fehler "$Name steht nicht in checksums.txt." }
  $Soll = ($Zeile.Trim() -split "\s+")[0].ToLower()
  $Ist = (Get-FileHash -Algorithm SHA256 -Path $ZipZiel).Hash.ToLower()
  if ($Soll -ne $Ist) { Fehler "Pruefsumme stimmt nicht. Datei beschaedigt oder falsche Version." }
  Info "Pruefsumme in Ordnung."
  Expand-Archive -Path $ZipZiel -DestinationPath (Join-Path $Tmp "pb") -Force

  # 2. Laufendes Trinkimal anhalten (nur das aus diesem Ordner), sonst ist die exe gesperrt
  $Exe = Join-Path $Ziel "pocketbase.exe"
  $task = Get-ScheduledTask -TaskName $Aufgabe -ErrorAction SilentlyContinue
  if ($task -and $task.State -eq "Running") { Info "Halte geplante Aufgabe an ..."; Stop-ScheduledTask -TaskName $Aufgabe }
  Get-Process -Name pocketbase -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and ($_.Path -ieq $Exe) } |
    ForEach-Object { Info "Beende laufendes Trinkimal (PID $($_.Id)) ..."; Stop-Process -Id $_.Id -Force; $_.WaitForExit(10000) | Out-Null }

  # 3. Dateien kopieren. pb_public wird komplett ersetzt, pb_data nie angefasst.
  Info "Kopiere App nach $Ziel ..."
  Copy-Item (Join-Path $Tmp "pb\pocketbase.exe") $Exe -Force
  $Pub = Join-Path $Ziel "pb_public"
  if (Test-Path $Pub) { Remove-Item $Pub -Recurse -Force }
  New-Item -ItemType Directory -Path $Pub | Out-Null
  foreach ($f in @("index.html", "sw.js", "manifest.webmanifest")) { Copy-Item (Join-Path $Repo $f) $Pub }
  foreach ($d in @("icons", "tiere", "getraenke", "fonts", "vendor")) { Copy-Item (Join-Path $Repo $d) $Pub -Recurse }
  foreach ($d in @("pb_hooks", "pb_migrations", "pb_data")) { New-Item -ItemType Directory -Force -Path (Join-Path $Ziel $d) | Out-Null }
  Copy-Item (Join-Path $Repo "server\pb_hooks\*") (Join-Path $Ziel "pb_hooks") -Force
  Copy-Item (Join-Path $Repo "server\pb_migrations\*") (Join-Path $Ziel "pb_migrations") -Force
} finally {
  Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Startdatei und Einstellungen
if ($Domain) { $Adresse = $Domain; $Url2 = "https://$Domain" } else { $Adresse = "--http=0.0.0.0:$Port"; $Url2 = "http://localhost:$Port" }
$Argumente = "serve $Adresse --dir=`"$Ziel\pb_data`" --publicDir=`"$Ziel\pb_public`" --hooksDir=`"$Ziel\pb_hooks`" --migrationsDir=`"$Ziel\pb_migrations`""
Set-Content -Encoding ASCII -Path $Cfg -Value @("Port=$Port", "Domain=$Domain")
$Start = Join-Path $Ziel "start-trinkimal.cmd"
Set-Content -Encoding ASCII -Path $Start -Value @(
  "@echo off",
  "rem Startet Trinkimal. Fenster offen lassen, solange der Server laufen soll.",
  "cd /d `"%~dp0`"",
  "`"%~dp0pocketbase.exe`" serve $Adresse --dir=pb_data --publicDir=pb_public --hooksDir=pb_hooks --migrationsDir=pb_migrations"
)

if ($Firewall) {
  $Ports = if ($Domain) { @(80, 443) } else { @($Port) }
  Get-NetFirewallRule -DisplayName "Trinkimal" -ErrorAction SilentlyContinue | Remove-NetFirewallRule
  New-NetFirewallRule -DisplayName "Trinkimal" -Direction Inbound -Protocol TCP -LocalPort $Ports -Action Allow | Out-Null
  Info "Firewall: Port $($Ports -join ', ') freigegeben."
}

if ($Autostart) {
  $a = New-ScheduledTaskAction -Execute $Exe -Argument $Argumente -WorkingDirectory $Ziel
  $t = New-ScheduledTaskTrigger -AtStartup
  $p = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
  $s = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
  Register-ScheduledTask -TaskName $Aufgabe -Action $a -Trigger $t -Principal $p -Settings $s -Force | Out-Null
  Start-ScheduledTask -TaskName $Aufgabe
  Info "Geplante Aufgabe '$Aufgabe' eingerichtet und gestartet (laeuft ab jetzt bei jedem Windows-Start)."
} elseif (Get-ScheduledTask -TaskName $Aufgabe -ErrorAction SilentlyContinue) {
  # Aufgabe von frueher: mit den neuen Dateien wieder starten
  Start-ScheduledTask -TaskName $Aufgabe
  Info "Geplante Aufgabe '$Aufgabe' wieder gestartet."
} else {
  Info "Starten: Doppelklick auf $Start"
}

Write-Host ""
Write-Host "Fertig. Trinkimal liegt in $Ziel, die Daten in $Ziel\pb_data."
Write-Host ""
Write-Host "Erstes Admin-Konto anlegen (nur einmal noetig):"
Write-Host "  & `"$Exe`" superuser upsert du@example.de EinLangesPasswort --dir=`"$Ziel\pb_data`""
Write-Host ""
Write-Host "Dann im Browser:"
Write-Host "  App:        $Url2/"
Write-Host "  Dashboard:  $Url2/_/   (dort unter 'users' dein Konto fuer die App anlegen)"
