param([string]$Dir = $PSScriptRoot)
# 주간 접속 보상 표(weekly.json)에 서명 → weekly.signed.json. 키 · 봉투 형식은 우편(sign_mail.ps1)과 같음.
# 사용: powershell -ExecutionPolicy Bypass -File sign_weekly.ps1   (weekly.json 을 고친 뒤 실행, 그다음 weekly.json · weekly.signed.json 을 함께 커밋)
$keyFile = Join-Path $env:USERPROFILE "NyangKeys\mail_signing_key.xml"
if (-not (Test-Path $keyFile)) { throw "서명 키가 없어요: $keyFile" }
$path = Join-Path $Dir "weekly.json"
# 줄바꿈은 LF 로 통일해서 파일에 다시 쓴 뒤 서명 (윈도우 편집기의 CRLF 때문에 서명이 깨지지 않게)
$text = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8).Replace("`r`n", "`n")
[IO.File]::WriteAllBytes($path, (New-Object Text.UTF8Encoding($false)).GetBytes($text))
$data = [IO.File]::ReadAllBytes($path)
# 형식 점검 (앱의 WeeklyAttendance 와 같은 규칙): 5일 + 최종, 재화 4가지, 재화마다 한도
$max = @{ gold = 1000000; catnip = 100000; yellow = 1000; red = 1000 }
$names = @{ gold = "골드"; catnip = "캣닙"; yellow = "옐로 다이아"; red = "레드 다이아" }
$j = [Text.Encoding]::UTF8.GetString($data) | ConvertFrom-Json
if ($j.type -ne "weekly") { throw '맨 위에 "type": "weekly" 가 있어야 해요' }
if (@($j.days).Count -ne 5) { throw "days 는 정확히 5개 (1일차 ~ 5일차)" }
function Check($r, $label) {
    if (-not $r -or -not $max.ContainsKey([string]$r.kind)) { throw "$label 의 kind 는 gold · catnip · yellow · red 중 하나: $($r.kind)" }
    $m = $max[[string]$r.kind]
    if (-not ($r.amount -is [int] -or $r.amount -is [long]) -or $r.amount -lt 1 -or $r.amount -gt $m) { throw "$label 의 amount 는 1 ~ $m ($($r.kind)): $($r.amount)" }
    "$label $($names[[string]$r.kind]) $($r.amount)"
}
$desc = @()
for ($i = 0; $i -lt 5; $i++) { $desc += Check $j.days[$i] "$($i + 1)일차" }
$desc += Check $j.final "최종"
$rsa = New-Object Security.Cryptography.RSACryptoServiceProvider
$rsa.FromXmlString([IO.File]::ReadAllText($keyFile))
$sig = $rsa.SignData($data, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pkcs1)
# 앱이 읽는 파일: 표 내용(base64) + 서명을 한 파일에
$envelope = '{"data":"' + [Convert]::ToBase64String($data) + '","sig":"' + [Convert]::ToBase64String($sig) + '"}'
[IO.File]::WriteAllText((Join-Path $Dir "weekly.signed.json"), $envelope, (New-Object Text.UTF8Encoding($false)))
Write-Host "서명 완료: weekly.signed.json"
$desc | ForEach-Object { Write-Host "  $_" }
