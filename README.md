# NyangDefense-version

냥냥디펜스 앱이 시작할 때 읽어 가는 **최신 버전 정보** 파일(`version.json`)만 있는 저장소입니다. 게임 소스는 들어 있지 않습니다.

- `latestVersionCode` : 스토어에 올라간 최신 버전 코드. 앱의 버전 코드가 이보다 낮으면 "새 버전이 있어요" 창이 뜨고 업데이트해야만 플레이할 수 있습니다.
- `latestVersionName` : 최신 버전 이름 (창에 표시)
- `storeUrl` / `marketUrl` : 업데이트 때 열 스토어 주소

## 갱신 방법
새 버전이 구글 플레이에서 **사용자에게 배포된 뒤에** `latestVersionCode` · `latestVersionName` · `updatedAt` 을 고쳐 커밋합니다.
(배포 전에 올리면 아직 받을 수 없는 버전을 요구하게 됩니다.)

| 버전 이름 | 버전 코드 |
|---|---|
| 1.0.0 | 1 |
| 1.0.1 | 2 |
| 1.0.2 | 3 |
## 우편 (골드 지급)
앱의 우편함이 읽어 가는 파일입니다. **골드만** 지급할 수 있고, 모든 사용자에게 똑같이 지급됩니다.

- `mail.json` : 우편 목록(사람이 고치는 원본) / `mail.signed.json` : 앱이 읽는 파일 (우편 내용 + 개발자 PC 개인키로 만든 서명, 앱 안의 공개키로 확인 — 직접 고치지 말고 sign_mail.ps1 로 만들 것)
- 우편 한 줄 = `{ "id": "고유이름", "title": "한국어 제목", "titleEn": "English title", "gold": 5000, "startsAt": "2026-10-21", "expiresAt": "2026-11-30" }`
  - `id` : 영문 · 숫자 · `_` · `-` 1~40자, **한 번 쓴 id 는 다시 쓰지 않음** (받은 사람은 같은 id 를 다시 못 받음)
  - `gold` : 1 ~ 1,000,000 (다른 재화는 지급 불가), 한 번에 우편 50개까지
  - `startsAt` · `expiresAt` : UTC 날짜(yyyy-MM-dd), 이 기간에만 보임

### 올리는 방법
1. `mail.json` 을 고친다.
2. `powershell -ExecutionPolicy Bypass -File sign_mail.ps1` 로 서명 (`mail.signed.json` 이 새로 만들어짐 · 형식 점검 포함)
3. `mail.json` 과 `mail.signed.json` **둘 다** 커밋 · 푸시 (반영까지 최대 5분 걸릴 수 있음)

서명 없이(또는 개인키 없이) 올린 `mail.json` 은 앱이 무시하므로, 저장소 계정이 노출되어도 지급을 만들 수 없습니다. 개인키는 저장소에 올리지 마세요.