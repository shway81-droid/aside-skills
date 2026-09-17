# Aside 스킬 모음

Aside에서 사용하는 개인 스킬 저장소입니다.

## 포함된 스킬

### kedufine-document-archive

K-에듀파인 문서등록대장에서 생산문서를 기안자별로 일괄 다운로드해 업무별/월별 폴더로 정리합니다.

- 업무분장표 기준으로 폴더 구조 생성
- 기안자별 월별 생산문서 PDF 다운로드
- 최종적으로 폴더명을 업무부서명으로 변경

## 다른 PC에 설치하기

### 방법 1: Aside에게 요청

Aside에게 아래처럼 요청하면 알아서 설치합니다.

```
https://github.com/shway81-droid/aside-skills 에서 스킬 내려받아서 설치해줘
```

### 방법 2: 직접 설치

스킬 폴더를 Aside 계정 스킬 경로에 복사합니다.

Windows:

```powershell
cd $env:USERPROFILE\.aside\u\0\skills\user
git clone https://github.com/shway81-droid/aside-skills.git temp-skills
Copy-Item .\temp-skills\kedufine-document-archive -Destination . -Recurse
Remove-Item .\temp-skills -Recurse -Force
```

macOS:

```bash
cd ~/.aside/u/0/skills/user
git clone https://github.com/shway81-droid/aside-skills.git temp-skills
cp -r temp-skills/kedufine-document-archive .
rm -rf temp-skills
```

설치 후 Aside 새 세션에서 바로 사용할 수 있습니다.

## 스킬 수정 후 반영하기

로컬에서 스킬을 고쳤다면 이 저장소에 다시 올립니다.

```powershell
git clone https://github.com/shway81-droid/aside-skills.git
# 수정한 스킬 폴더를 덮어쓴 뒤
git add -A
git commit -m "스킬 수정"
git push
```
