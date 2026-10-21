param([string]$Dir = $PSScriptRoot)
# 우편 설정(mail.json)에 서명 → mail.sig. 개인키는 이 PC 의 %USERPROFILE%\NyangKeys\mail_signing_key.xml (저장소에는 없음).
# 사용: powershell -File sign_mail.ps1   (mail.json 을 고친 뒤 실행, 그다음 mail.json · mail.sig 를 함께 커밋)
$keyFile = Join-Path $env:USERPROFILE "NyangKeys\mail_signing_key.xml"
if (-not (Test-Path $keyFile)) { throw "서명 키가 없어요: $keyFile" }
$mailPath = Join-Path $Dir "mail.json"
$data = [IO.File]::ReadAllBytes($mailPath)
# 형식 점검: 골드만 · 한도 · 중복 id
$j = [Text.Encoding]::UTF8.GetString($data) | ConvertFrom-Json
$ids = @{}
foreach ($m in $j.mails) {
    if (-not $m.id -or $m.id -notmatch '^[A-Za-z0-9_\-]{1,40}$') { throw "id 가 이상해요: $($m.id)" }
    if ($ids.ContainsKey($m.id)) { throw "id 중복: $($m.id)" }
    $ids[$m.id] = 1
    if ($m.gold -lt 1 -or $m.gold -gt 1000000) { throw "골드는 1 ~ 1,000,000: $($m.id)" }
}
if (@($j.mails).Count -gt 50) { throw "우편은 한 번에 50개까지" }
$rsa = New-Object Security.Cryptography.RSACryptoServiceProvider
$rsa.FromXmlString([IO.File]::ReadAllText($keyFile))
$sig = $rsa.SignData($data, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pkcs1)
[IO.File]::WriteAllText((Join-Path $Dir "mail.sig"), [Convert]::ToBase64String($sig), (New-Object Text.UTF8Encoding($false)))
Write-Host "서명 완료: mail.sig (우편 $(@($j.mails).Count)개)"