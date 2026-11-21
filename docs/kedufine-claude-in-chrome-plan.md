# K-에듀파인 아카이빙 — Claude in Chrome 버전 계획

`kedufine-document-archive` 스킬을 **Aside 없이** 돌리기 위한 계획입니다.
2026-11-21 대화에서 정한 내용이며, 아직 만들지 않았습니다.

> 다음에 시작할 때: Windows PC에서 이 문서를 Claude에게 보여 주고
> "이 계획대로 Claude in Chrome 버전 만들자"고 하면 됩니다.

## 왜 미뤘나

K-에듀파인은 Windows에서만 정상 작동합니다(PC저장 창 WXSClient, 보안 프로그램).
계획을 세울 때 쓰던 기기가 맥북이어서 Windows PC에서 이어 하기로 했습니다.

## 정한 방향

| 항목 | 결정 |
|---|---|
| 브라우저 조작 | **Claude in Chrome** (Chrome 확장). Playwright는 쓰지 않습니다 |
| PC에서 하는 작업 | **Claude Code(또는 Claude 데스크톱 앱) + PowerShell** |
| Python | **필요 없습니다** |
| 로그인 | 사용자가 Chrome에서 인증서(EPKI)로 직접 로그인합니다. 자동화하지 않습니다 |
| 기존 Aside 버전 | 그대로 둡니다. 새 버전은 따로 추가합니다 |

### 역할 나누기

```
Windows PC의 Claude Code
  ├─ Claude in Chrome → 에듀파인 화면: 조회 조건 입력, 조회, 건수 확인, 전체선택, PC저장 클릭
  └─ PowerShell      → save_month.ps1(저장 창 처리), 폴더 만들기·이름 바꾸기, 건수 검증
```

Claude in Chrome은 브라우저 안만 조작할 수 있습니다. PC저장을 누르면 뜨는 **WXSClient 파일저장 창**은
Windows 별도 창이라서 기존 `scripts/save_month.ps1`이 그대로 필요합니다.

## 기존 SKILL.md에서 바꿀 곳

- `REPL의 fs` 같은 Aside 전용 표현 → PowerShell과 Claude in Chrome 안내로 바꿉니다
- `frame.locator(...)` 코드 예시 → Claude in Chrome으로 같은 일을 하는 안내로 바꿉니다
- 업무분장표 읽기: **hwpx·xlsx는 PowerShell로** 읽습니다(둘 다 실체가 zip).
  pdf는 PowerShell로 읽기 어려우니 hwpx나 xlsx로 다시 저장해 달라고 안내합니다
- 그 밖의 절차(필드 ID, 100건 설정, 비전자문서·열람권한 제외, 예상 건수 계산)는 그대로 씁니다

## 시작 전에 Windows PC에서 확인할 것

1. Chrome에서 에듀파인 로그인과 **PC저장(WXSClient)**이 정상 작동하는지
   (평소 Edge만 썼다면 꼭 확인)
2. 학교 PC에 Chrome 확장 프로그램을 설치할 수 있는지
3. Claude Code(또는 Claude 데스크톱 앱)를 설치할 수 있는지
4. 같은 PC에서 Aside로 이미 이 작업을 했으므로, 에듀파인과 AI 서비스를 동시에 쓰는
   네트워크 환경은 문제없을 것으로 봅니다

## 진행 순서

1. 위 확인 사항을 점검합니다
2. Claude in Chrome 버전 스킬 문서를 만듭니다
3. **담당자 한 명·한 달**로 시범 실행해 실제 화면이 문서와 같은지 확인합니다
   (에듀파인이 업데이트되면 요소 ID가 바뀌었을 수 있습니다)
4. 문제가 없으면 한 사람씩 나눠서 전체를 진행합니다

## 운영할 때 주의

- 반복 횟수가 많습니다(담당자 수 × 12개월). 한 번에 다 돌리지 말고 한 사람씩 나눕니다
- 저장 창이 화면 맨 앞으로 튀어나오므로, PC를 쓰지 않는 시간에 돌립니다
- 예시와 문서에는 실제 학교명·담당자 이름을 쓰지 않습니다(`○○` 표기, CLAUDE.md 참고)
