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