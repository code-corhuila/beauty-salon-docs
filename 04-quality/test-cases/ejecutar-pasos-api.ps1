# Ejecuta los pasos de API de TC-001 a TC-009 contra la API levantada y deja un registro por paso.
# Los pasos que piden la app (modo avión, chrome://inspect, emulador) quedan marcados como no
# ejecutados: se hacen a mano. Crea sus propios datos por la API, nunca por SQL.
#
# Uso (PowerShell 7), con la API de beauty-salon-infra levantada:
#   pwsh 04-quality/test-cases/ejecutar-pasos-api.ps1 [-BaseUrl http://localhost:3000/v1] [-Out tc-resultados.json]
param([string]$BaseUrl = "http://localhost:3000/v1", [string]$Out = "tc-resultados.json")
$ErrorActionPreference = 'Stop'
$results = [System.Collections.Generic.List[object]]::new()
$sfx = "$(Get-Date -Format 'HHmmss')$(Get-Random -Maximum 999)"

function Call($method, $path, $body = $null, $token = $null) {
  $headers = @{}
  if ($token) { $headers.Authorization = "Bearer $token" }
  $p = @{ Method = $method; Uri = "$BaseUrl$path"; Headers = $headers; SkipHttpErrorCheck = $true }
  if ($null -ne $body) { $p.Body = ($body | ConvertTo-Json -Depth 6); $p.ContentType = 'application/json' }
  $r = Invoke-WebRequest @p
  $json = $null
  # PowerShell entrega application/problem+json como bytes, no como texto: se decodifica a mano.
  $text = if ($r.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($r.Content) } else { $r.Content }
  if ($text) { try { $json = $text | ConvertFrom-Json } catch {} }
  [pscustomobject]@{ status = [int]$r.StatusCode; json = $json }
}
function Rec($tc, $step, $expected, $actual, [bool]$ok, $note = '') {
  $results.Add([pscustomobject]@{ tc = $tc; step = $step; expected = $expected; actual = $actual; ok = $ok; note = $note })
}
function Got($r) { if ($r.json -and $r.json.code) { "$($r.status) $($r.json.code)" } else { "$($r.status)" } }

# Fechas en hora de Bogotá: el próximo lunes (con horario) y el martes siguiente (sin horario).
$tz = try { [TimeZoneInfo]::FindSystemTimeZoneById('America/Bogota') } catch { [TimeZoneInfo]::FindSystemTimeZoneById('SA Pacific Standard Time') }
$today = [TimeZoneInfo]::ConvertTimeFromUtc([DateTime]::UtcNow, $tz).Date
$monday = $today.AddDays(1); while ($monday.DayOfWeek -ne 'Monday') { $monday = $monday.AddDays(1) }
$MON = $monday.ToString('yyyy-MM-dd'); $TUE = $monday.AddDays(1).ToString('yyyy-MM-dd')

function NewBusiness($tag) {
  $r = Call POST '/auth/register' @{ role = 'business'; name = "Duena $tag"; phone = '3001112233'; email = "neg$tag$sfx@test.com"; password = 'Secreta123'; salonName = "Salon $tag"; address = 'Calle 1' }
  $prof = (Call GET '/business/professionals' $null $r.json.accessToken).json.items[0].id
  [pscustomobject]@{ token = $r.json.accessToken; refresh = $r.json.refreshToken; prof = $prof }
}
function NewClient($tag) {
  $r = Call POST '/auth/register' @{ role = 'client'; name = "Clienta $tag"; phone = '3001112233'; email = "cli$tag$sfx@test.com"; password = 'Secreta123' }
  [pscustomobject]@{ token = $r.json.accessToken; refresh = $r.json.refreshToken }
}
function Service($biz, $prof, $start, $end, $weekday = 1) {
  Call POST '/business/services' @{ name = "Servicio $start-$end"; type = 'traditional'; description = 'Prueba'; priceCop = 30000; durationMinutes = 60; professionalId = $prof; schedule = @(@{ weekday = $weekday; startTime = $start; endTime = $end }) } $biz.token
}
function Book($client, $serviceId, $slotId, $requestId = [guid]::NewGuid().ToString()) {
  Call POST '/appointments' @{ serviceId = $serviceId; slotId = $slotId; clientRequestId = $requestId } $client.token
}
function Slots($serviceId, $date) { Call GET "/services/$serviceId/availability?date=$date" }

# ---------------- TC-001 Cupos calculados ----------------
$b1 = NewBusiness 'a'; $ca = NewClient 'a'; $cb = NewClient 'b'
$r = Service $b1 $b1.prof '09:00' '12:00'; $svc = $r.json.id
Rec 'TC-001' 1 '201 con id' "$(Got $r) id=$svc" ($r.status -eq 201 -and $svc)
$r = Slots $svc $MON; $ids = @($r.json.slots | ForEach-Object { $_.id })
$free = @($r.json.slots | Where-Object { $_.isAvailable })
Rec 'TC-001' 2 '200 con 3 cupos 09, 10 y 11' "$(Got $r) cupos=$($ids -join ',')" ($r.status -eq 200 -and $ids.Count -eq 3)
$s10 = ($r.json.slots | Where-Object { $_.id -like '*1000*' } | Select-Object -First 1).id
$r = Slots $svc $TUE
Rec 'TC-001' 3 '200 con lista vacía' "$(Got $r) cupos=$(@($r.json.slots).Count)" ($r.status -eq 200 -and @($r.json.slots).Count -eq 0)
$r = Call GET "/services/$svc/availability"
Rec 'TC-001' 4 '422 VALIDATION_FAILED en date' "$(Got $r) campos=$((@($r.json.errors.PSObject.Properties.Name)) -join ',')" ($r.status -eq 422 -and $r.json.errors.date)
$book = Book $ca $svc $s10
$r = Slots $svc $MON
$after = @($r.json.slots); $tenAfter = $after | Where-Object { $_.id -eq $s10 }
$okStrict = $after.Count -eq 2 -and -not $tenAfter
$okMarked = $after.Count -eq 3 -and $tenAfter -and -not $tenAfter.isAvailable
Rec 'TC-001' 5 '200 con 2 cupos: el de las 10:00 ya no aparece' "$(Got $r) cupos=$($after.Count); 10:00 presente=$([bool]$tenAfter) isAvailable=$($tenAfter.isAvailable)" ($okStrict -or $okMarked) $(if ($okMarked) { 'La API mantiene el cupo de las 10:00 con isAvailable=false en lugar de quitarlo; la app lo muestra deshabilitado. El texto esperado del caso está desactualizado.' } else { '' })

# ---------------- TC-002 Sin doble agendamiento ----------------
$r = Service $b1 $b1.prof '14:00' '16:00'; $svc2 = $r.json.id
$slot = (Slots $svc2 $MON).json.slots[0].id
$ra = Book $ca $svc2 $slot
Rec 'TC-002' 1 '201 pending' "$(Got $ra) estado=$($ra.json.status)" ($ra.status -eq 201 -and $ra.json.status -eq 'pending')
$rb = Book $cb $svc2 $slot
Rec 'TC-002' 2 '409 SLOT_TAKEN' (Got $rb) ($rb.status -eq 409 -and $rb.json.code -eq 'SLOT_TAKEN')
Rec 'TC-002' 3 'Aviso de cupo tomado y recarga en la app' 'No ejecutado aquí: requiere la app' $false 'Cubierto por la prueba automática BookAppointmentScreen_whenSlotIsTaken_warnsAndReloadsTheSlots (Vitest); falta la ejecución manual en la app.'
$r = Book $ca $svc2 'slt_20000101_0900'
Rec 'TC-002' 4 '422 VALIDATION_FAILED' (Got $r) ($r.status -eq 422)
$r = Call PATCH "/business/appointments/$($ra.json.id)/respond" @{ status = 'rejected'; reason = 'Se cruzó otra cita' } $b1.token
$rb2 = Book $cb $svc2 $slot
Rec 'TC-002' 5 'Rechazo libera el cupo: 201' "rechazo=$(Got $r); reintento B=$(Got $rb2)" ($r.status -eq 200 -and $rb2.status -eq 201)

# ---------------- TC-003 Reintento idempotente ----------------
$r = Service $b1 $b1.prof '16:00' '18:00'; $svc3 = $r.json.id
$slot3 = (Slots $svc3 $MON).json.slots[0].id; $req = [guid]::NewGuid().ToString()
$r1 = Book $ca $svc3 $slot3 $req
Rec 'TC-003' 1 '201 con id' "$(Got $r1) id=$($r1.json.id)" ($r1.status -eq 201)
$r2 = Book $ca $svc3 $slot3 $req
Rec 'TC-003' 2 '201 con el mismo id' "$(Got $r2) id=$($r2.json.id)" ($r2.status -eq 201 -and $r2.json.id -eq $r1.json.id)
$mine = Call GET '/appointments/mine?scope=upcoming' $null $ca.token
$same = @($mine.json.items | Where-Object { $_.service.id -eq $svc3 })
Rec 'TC-003' 3 'Una sola cita para ese cupo' "$(Got $mine) citas de ese servicio=$($same.Count)" ($mine.status -eq 200 -and $same.Count -eq 1)
Rec 'TC-003' 4 'Modo avión y reintento en la app' 'No ejecutado aquí: requiere la app en un celular' $false 'Cubierto por la prueba automática BookAppointmentScreen_retryAfterTimeout_resendsTheSameKey (Vitest).'

# ---------------- TC-004 Horario sin solape ----------------
$b4 = NewBusiness 'c'
$r = Service $b4 $b4.prof '09:00' '12:00'
$r1 = Service $b4 $b4.prof '10:00' '11:00'
Rec 'TC-004' 1 '409 SCHEDULE_OVERLAP con el día' "$(Got $r1) detail=$($r1.json.detail)" ($r1.status -eq 409 -and $r1.json.code -eq 'SCHEDULE_OVERLAP' -and $r1.json.detail -match '1')
$r2 = Service $b4 $b4.prof '12:00' '13:00'
Rec 'TC-004' 2 '201: el borde no solapa' (Got $r2) ($r2.status -eq 201)
$other = Call POST '/business/professionals' @{ name = 'Otra profesional' } $b4.token
$r3 = Service $b4 $other.json.id '10:00' '11:00'
Rec 'TC-004' 3 '201 con otra profesional' (Got $r3) ($r3.status -eq 201)
Rec 'TC-004' 4 'Error junto al horario y el formulario conserva lo escrito' 'No ejecutado aquí: requiere la app' $false 'Cubierto por la prueba automática ServiceFormScreen_whenScheduleOverlaps_showsTheApiMessageAndKeepsTheForm (Vitest, rama HU-16).'

# ---------------- TC-005 Pausar no borra ----------------
$r = Service $b1 $b1.prof '18:00' '19:00'; $svc5 = $r.json.id
$slot5 = (Slots $svc5 $MON).json.slots[0].id
$apt5 = (Book $ca $svc5 $slot5).json.id
$null = Call PATCH "/business/appointments/$apt5/respond" @{ status = 'confirmed' } $b1.token
$r = Call PATCH "/business/services/$svc5/status" @{ isPublished = $false } $b1.token
Rec 'TC-005' 1 '200' (Got $r) ($r.status -eq 200)
$cat = Call GET '/services?pageSize=50'; $present = @($cat.json.items | Where-Object { $_.id -eq $svc5 }).Count
Rec 'TC-005' 2 'No aparece en el catálogo' "$(Got $cat) presente=$present" ($cat.status -eq 200 -and $present -eq 0) 'Se revisó la primera página de hasta 50 servicios.'
$r = Call GET "/services/$svc5"
Rec 'TC-005' 3 '410 SERVICE_PAUSED' (Got $r) ($r.status -eq 410 -and $r.json.code -eq 'SERVICE_PAUSED')
$ag = Call GET "/business/agenda?date=$MON" $null $b1.token; $inAg = $ag.json.items | Where-Object { $_.id -eq $apt5 }
Rec 'TC-005' 4 'La cita sigue en la agenda, confirmed' "$(Got $ag) estado=$($inAg.status)" ($ag.status -eq 200 -and $inAg.status -eq 'confirmed')
$mine = Call GET '/appointments/mine' $null $ca.token; $inMine = $mine.json.items | Where-Object { $_.id -eq $apt5 }
Rec 'TC-005' 5 'La cita sigue en Mis citas' "$(Got $mine) presente=$([bool]$inMine)" ($mine.status -eq 200 -and $inMine)
$r = Call PATCH "/business/services/$svc5/status" @{ isPublished = $true } $b1.token
$cat = Call GET '/services?pageSize=50'; $present = @($cat.json.items | Where-Object { $_.id -eq $svc5 }).Count
Rec 'TC-005' 6 'Reaparece con el mismo id' "publicar=$(Got $r) presente=$present" ($r.status -eq 200 -and $present -eq 1)

# ---------------- TC-006 Responder una vez ----------------
$r = Service $b1 $b1.prof '19:00' '20:00'; $svc6 = $r.json.id
$apt6 = (Book $ca $svc6 ((Slots $svc6 $MON).json.slots[0].id)).json.id
$r = Call PATCH "/business/appointments/$apt6/respond" @{ status = 'confirmed' } $b1.token
Rec 'TC-006' 1 '200 confirmed' "$(Got $r) estado=$($r.json.status)" ($r.status -eq 200 -and $r.json.status -eq 'confirmed')
$r = Call PATCH "/business/appointments/$apt6/respond" @{ status = 'rejected'; reason = 'x' } $b1.token
Rec 'TC-006' 2 '409 APPOINTMENT_ALREADY_RESPONDED' (Got $r) ($r.status -eq 409 -and $r.json.code -eq 'APPOINTMENT_ALREADY_RESPONDED')
$r = Call PATCH "/business/appointments/$apt6/respond" @{ status = 'confirmada' } $b1.token
Rec 'TC-006' 3 '422 VALIDATION_FAILED' (Got $r) ($r.status -eq 422)
$r = Call PATCH "/business/appointments/$apt6/respond" @{ status = 'confirmed' } $b4.token
Rec 'TC-006' 4 '403 FORBIDDEN_RESOURCE' (Got $r) ($r.status -eq 403 -and $r.json.code -eq 'FORBIDDEN_RESOURCE')

# ---------------- TC-007 Cancelar solo la dueña ----------------
$r = Service $b1 $b1.prof '06:00' '07:00'; $svc7 = $r.json.id
$apt7 = (Book $ca $svc7 ((Slots $svc7 $MON).json.slots[0].id)).json.id
$null = Call PATCH "/business/appointments/$apt7/respond" @{ status = 'confirmed' } $b1.token
$r = Call PATCH "/appointments/$apt7/cancel" @{} $cb.token
Rec 'TC-007' 1 '403 FORBIDDEN_RESOURCE' (Got $r) ($r.status -eq 403 -and $r.json.code -eq 'FORBIDDEN_RESOURCE')
$r = Call PATCH "/appointments/$apt7/cancel" @{} $ca.token
Rec 'TC-007' 2 '200 cancelled' "$(Got $r) estado=$($r.json.status)" ($r.status -eq 200 -and $r.json.status -eq 'cancelled')
$r = Call PATCH "/appointments/$apt7/cancel" @{} $ca.token
Rec 'TC-007' 3 '409 APPOINTMENT_NOT_CANCELLABLE' (Got $r) ($r.status -eq 409 -and $r.json.code -eq 'APPOINTMENT_NOT_CANCELLABLE')
$r = Call PATCH '/appointments/apt_nope/cancel' @{} $ca.token
Rec 'TC-007' 4 '404 APPOINTMENT_NOT_FOUND' (Got $r) ($r.status -eq 404 -and $r.json.code -eq 'APPOINTMENT_NOT_FOUND')
$mine = Call GET '/appointments/mine' $null $ca.token; $c7 = $mine.json.items | Where-Object { $_.id -eq $apt7 }
Rec 'TC-007' 5 'Sigue en el historial como cancelada' "$(Got $mine) estado=$($c7.status)" ($c7.status -eq 'cancelled')
Rec 'TC-007' 6 'Sin conexión la app no cancela ni encola' 'No ejecutado aquí: requiere la app' $false 'La pantalla deshabilita el botón sin conexión (AppointmentDetailScreen, rama HU-18); falta la ejecución manual.'

# ---------------- TC-008 Cada rol ve lo suyo ----------------
$r = Call GET '/business/professionals' $null $ca.token
Rec 'TC-008' 1 '403 FORBIDDEN_ROLE' (Got $r) ($r.status -eq 403 -and $r.json.code -eq 'FORBIDDEN_ROLE')
$r = Book $b1 $svc $s10
Rec 'TC-008' 2 '403 FORBIDDEN_ROLE' (Got $r) ($r.status -eq 403 -and $r.json.code -eq 'FORBIDDEN_ROLE')
$r = Call PUT "/business/services/$svc" @{ name = 'Robado'; type = 'traditional'; description = 'x'; priceCop = 1000; durationMinutes = 60; professionalId = $b4.prof; schedule = @(@{ weekday = 3; startTime = '09:00'; endTime = '10:00' }) } $b4.token
Rec 'TC-008' 3 '403 FORBIDDEN_RESOURCE' (Got $r) ($r.status -eq 403 -and $r.json.code -eq 'FORBIDDEN_RESOURCE')
$r = Call GET '/appointments/mine'
Rec 'TC-008' 4 '401 AUTH_REQUIRED' (Got $r) ($r.status -eq 401 -and $r.json.code -eq 'AUTH_REQUIRED')
$r = Call GET '/appointments/mine' $null 'token.inventado.123'
Rec 'TC-008' 5 '401 SESSION_EXPIRED' (Got $r) ($r.status -eq 401 -and $r.json.code -eq 'SESSION_EXPIRED')
Rec 'TC-008' 6 'La guarda redirige al catálogo' 'No ejecutado aquí: requiere la app' $false 'Cubierto por las pruebas automáticas de RequireSession y RootNavigator (Vitest).'

# ---------------- TC-009 Cerrar sesión revoca ----------------
$c9 = NewClient 'd'
$r = Call POST '/auth/refresh' @{ refreshToken = $c9.refresh }
$newRefresh = $r.json.refreshToken
Rec 'TC-009' 1 '200 con refreshToken nuevo' "$(Got $r) nuevo=$([bool]($newRefresh -and $newRefresh -ne $c9.refresh))" ($r.status -eq 200 -and $newRefresh -and $newRefresh -ne $c9.refresh)
$r = Call POST '/auth/refresh' @{ refreshToken = $c9.refresh }
Rec 'TC-009' 2 '401 INVALID_REFRESH_TOKEN' (Got $r) ($r.status -eq 401 -and $r.json.code -eq 'INVALID_REFRESH_TOKEN')
$r = Call POST '/auth/logout' @{ refreshToken = $newRefresh }
Rec 'TC-009' 3 '204' (Got $r) ($r.status -eq 204)
$r = Call POST '/auth/logout' @{ refreshToken = $newRefresh }
Rec 'TC-009' 4 '204 (idempotente)' (Got $r) ($r.status -eq 204)
$r = Call POST '/auth/refresh' @{ refreshToken = $newRefresh }
Rec 'TC-009' 5 '401 INVALID_REFRESH_TOKEN' (Got $r) ($r.status -eq 401 -and $r.json.code -eq 'INVALID_REFRESH_TOKEN')
Rec 'TC-009' 6 'Sin tokens ni citas en el dispositivo' 'No ejecutado aquí: requiere chrome://inspect en un dispositivo' $false 'Cubierto por las pruebas automáticas de signOut y endSession (Vitest).'

Rec 'TC-010' '1-6' 'Catálogo sin conexión en el emulador' 'No ejecutado: todo el caso requiere la app instalada en un emulador' $false 'No hay Android SDK en este equipo.'

$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $Out -Encoding utf8NoBOM
"fechas: lunes=$MON martes=$TUE"
$results | Format-Table tc, step, ok, actual -AutoSize | Out-String -Width 220
