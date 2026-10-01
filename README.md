# 한국어 단어 학습 앱 (Flutter)

동양미래대학교 오픈소프트웨어 팀프로젝트 과제

## 팀원

| 학번 | 이름 | 역할 |
|---|---|---|
| 20262708 | 김동우 | 백엔드 |
| 20261277 | 송지율 | 기획 |
| 20263165 | 김나연 | 프론트엔드 |
| 20261267 | 최재민 | 프론트엔드 |
| 20262702 | 손민재 | 백엔드 |

## 목차

1. [프로젝트 소개](#프로젝트-소개)
2. [개발 환경](#개발-환경)
3. [처음 세팅하기](#처음-세팅하기)
4. [삼성 휴대폰 비율로 테스트하기](#삼성-휴대폰-비율로-테스트하기)
5. [실행 및 테스트 명령어](#실행-및-테스트-명령어)
6. [문제 해결](#문제-해결)
7. [변경 작업 규칙](#변경-작업-규칙)
8. [참고 자료](#참고-자료)

---

## 프로젝트 소개

Flutter로 제작하는 한국어 단어 학습 애플리케이션입니다.

## 개발 환경

| 항목 | 버전/종류 |
|---|---|
| OS | Windows 10/11 |
| Flutter | 3.47.5 (stable) |
| Dart | 3.13.4 |
| IDE | VS Code |
| 추가 도구 | Git, Android Studio, Android SDK 36, Android SDK Command-line Tools |

---

## 처음 세팅하기

> 🙋 **처음이라면 이 섹션만 위에서부터 순서대로 따라 하세요.**
> 각 단계 끝의 **✅ 확인**이 통과되면 다음 단계로 넘어가면 됩니다.
> 📷 표시가 있는 단계는 [Flutter VS Code 설정하기 (코딩항해기 블로그)](https://minibcake.tistory.com/556)에 실제 화면 캡처가 있으니 함께 보면서 진행하세요.

**전체 흐름 한눈에 보기**

```text
① 프로그램 설치 → ② VS Code 확장 설치 → ③ Flutter SDK 받기 → ④ 상태 점검(flutter doctor)
→ ⑤ Android SDK 설치 → ⑥ 라이선스 허용 → ⑦ 환경 변수 등록 → ⑧ 최종 점검
→ ⑨ 프로젝트 내려받기 → ⑩ 기기 준비 → ⑪ 실행!
```

### ① 필수 프로그램 설치

아래 3개를 설치합니다. 설치 옵션은 모두 기본값 그대로 `Next`를 누르면 됩니다.

- [ ] [Git](https://git-scm.com/download/win): Flutter SDK와 이 저장소를 내려받을 때 필요합니다.
- [ ] [VS Code](https://code.visualstudio.com/): 코드를 작성할 프로그램입니다.
- [ ] [Android Studio](https://developer.android.com/studio?hl=ko): Android SDK와 에뮬레이터를 설치할 때 필요합니다. 코드는 VS Code에서 작성합니다.

✅ **확인**: PowerShell을 새로 열고 `git --version`을 입력했을 때 버전이 나오면 성공입니다.

### ② VS Code에 Flutter 확장 설치

1. VS Code를 실행합니다.
2. 왼쪽 세로 메뉴에서 **네모 4개 모양 아이콘(Extensions)** 을 클릭합니다. (단축키 `Ctrl+Shift+X`)
3. 검색창에 `Flutter`를 입력하고 **Flutter** 확장의 `Install`을 누릅니다.
4. **Dart** 확장도 같이 설치됩니다. 안 됐다면 `Dart`를 검색해서 따로 설치합니다.

📷 [화면 보기: 블로그 1단계 (확장 프로그램 메뉴, 설치 완료 화면)](https://minibcake.tistory.com/556)

✅ **확인**: Extensions 목록에 `Flutter`와 `Dart`가 모두 설치됨으로 보이면 성공입니다.

### ③ Flutter SDK 받기 (VS Code에서 자동 설치)

Flutter SDK를 따로 다운로드하지 않고 VS Code에서 바로 설치할 수 있습니다.

1. VS Code에서 `Ctrl+Shift+P`를 눌러 명령 팔레트를 엽니다.
2. `flutter`를 입력하고 **Flutter: New Project**를 선택합니다.
3. 오른쪽 아래에 SDK를 찾을 수 없다는 알림이 뜨면 **Download SDK**를 누릅니다.
4. SDK를 저장할 폴더를 고릅니다. **한글과 띄어쓰기가 없는 경로**로 고르세요. (예: `C:\dev`)
5. 다운로드가 끝나고 **Add SDK to PATH** 알림이 뜨면 꼭 눌러줍니다.
6. 프로젝트 만들기 화면이 이어서 나오면 `Esc`로 닫아도 됩니다. 이 저장소는 ⑨단계에서 내려받습니다.

📷 [화면 보기: 블로그 2단계 (SDK 다운로드, 폴더 지정, PATH 추가)](https://minibcake.tistory.com/556)

> ⚠️ PATH가 적용되려면 **VS Code를 완전히 종료했다가 다시 실행**해야 합니다.

✅ **확인**: VS Code에서 `` Ctrl+` ``로 터미널을 열고 `flutter --version`을 입력했을 때 버전이 나오면 성공입니다.

### ④ 상태 점검 (flutter doctor)

VS Code 터미널에서 아래 명령을 실행합니다.

```powershell
flutter doctor -v
```

지금은 `Android toolchain` 항목에 ❌ 또는 ⚠️가 나오는 것이 **정상**입니다. 다음 단계에서 해결합니다.

### ⑤ Android SDK 설치 (Android Studio)

1. Android Studio를 실행합니다. 처음 실행하면 나오는 설정 마법사는 기본값(`Standard`)으로 끝까지 진행합니다.
2. 시작 화면 가운데의 **More Actions**를 누르고 **SDK Manager**를 선택합니다.
3. 위쪽 탭 중 **SDK Tools**를 누르고 아래 항목에 모두 체크합니다.
   - [ ] Android SDK Build-Tools
   - [ ] Android SDK Command-line Tools (latest)
   - [ ] Android Emulator
   - [ ] Android SDK Platform-Tools
   - [ ] NDK (Side by side)
4. **SDK Platforms** 탭에서도 최신 Android 버전 하나가 체크되어 있는지 확인합니다.
5. `Apply` → `OK`를 누르고 다운로드가 끝날 때까지 기다립니다.

📷 [화면 보기: 블로그 5단계 (More Actions 위치, SDK Manager, SDK Tools 체크 목록)](https://minibcake.tistory.com/556)

> ⚠️ 나중에 빌드할 때 특정 NDK 버전이 없다는 메시지가 뜨면, 그 버전을 SDK Manager에서 추가로 설치하면 됩니다. ([문제 해결](#문제-해결) 참고)

### ⑥ Android 라이선스 허용

VS Code 터미널에서 실행합니다.

```powershell
flutter doctor --android-licenses
```

질문이 나올 때마다 `y`를 입력하고 `Enter`를 누릅니다.

✅ **확인**: 마지막에 `All SDK package licenses accepted`가 나오면 성공입니다.

> 📌 이미 모두 허용되어 있으면 별다른 질문 없이 바로 끝날 수 있습니다. 정상입니다.

### ⑦ 환경 변수 등록 (adb 명령을 쓰기 위해)

Android SDK는 보통 아래 경로에 설치됩니다. (`<사용자이름>`은 본인 Windows 계정 이름)

```text
C:\Users\<사용자이름>\AppData\Local\Android\sdk
```

1. Windows 검색창에 `환경 변수`를 입력하고 **시스템 환경 변수 편집**을 엽니다.
2. `환경 변수` 버튼을 누르고, 위쪽 **사용자 변수** 목록에서 `Path`를 선택해 `편집`을 누릅니다.
3. `새로 만들기`를 눌러 아래 3줄을 **한 줄씩** 추가합니다.

   ```text
   C:\Users\<사용자이름>\AppData\Local\Android\sdk\platform-tools
   C:\Users\<사용자이름>\AppData\Local\Android\sdk\emulator
   C:\Users\<사용자이름>\AppData\Local\Android\sdk\cmdline-tools\latest\bin
   ```

4. `Path` 편집 창을 `확인`으로 닫고, 다시 **사용자 변수** 목록 아래의 `새로 만들기`를 눌러 아래처럼 `JAVA_HOME`을 추가합니다. (`avdmanager`가 Java를 찾을 때 필요하며, Java는 Android Studio에 포함되어 있어 따로 설치할 필요가 없습니다.)

   ```text
   변수 이름: JAVA_HOME
   변수 값:   C:\Program Files\Android\Android Studio\jbr
   ```

5. 열린 창을 모두 `확인`으로 닫고 **VS Code를 완전히 종료했다가 다시 실행**합니다.

✅ **확인**: 터미널에서 아래 두 명령이 모두 버전을 출력하면 성공입니다.

```powershell
adb --version
avdmanager --version
```

### ⑧ 최종 점검

```powershell
flutter doctor -v
```

✅ **확인**: `Flutter`, `Android toolchain`, `Android Studio`, `VS Code` 항목이 모두 초록색 체크(✓)면 세팅 완료입니다.

📷 [화면 보기: 블로그 7단계 (최종 완료 화면)](https://minibcake.tistory.com/556)

> 📌 `Visual Studio` 항목만 ❌인 것은 괜찮습니다. Android로 실행할 때는 필요 없고, **Windows 데스크톱 앱으로 실행할 때만** 필요합니다. ([문제 해결](#문제-해결) 참고)

### ⑨ 프로젝트 내려받기

프로젝트를 저장할 폴더(예: `C:\dev`)에서 터미널을 열고 실행합니다.

```powershell
git clone https://github.com/Salkogi07/OpenSoftware-Project.git
```

VS Code에서 `File` → `Open Folder`로 내려받은 `OpenSoftware-Project` 폴더를 엽니다.

### ⑩ 테스트할 기기 준비

둘 중 하나를 선택합니다.

| 방법 | 언제 사용 | 이동 |
|---|---|---|
| Android 에뮬레이터 | 화면 비율만 빠르게 확인하고 싶을 때 | [바로가기](#방법-a-android-에뮬레이터) |
| 실제 삼성 휴대폰 | 실제 One UI 동작까지 확인하고 싶을 때 | [바로가기](#방법-b-실제-삼성-휴대폰-연결) |

### ⑪ 프로젝트 실행

VS Code 터미널에서 실행합니다.

```powershell
flutter pub get
flutter devices
flutter run -d <기기ID>
```

- `flutter devices` 결과에 나온 기기 ID(예: `emulator-5554`)를 `<기기ID>` 자리에 넣습니다.
- VS Code 오른쪽 아래 상태 바에서 기기를 선택한 뒤 `F5`를 눌러도 됩니다.
- 실행 중 저장하거나 터미널에서 `r`을 누르면 **핫 리로드**(수정 내용 바로 반영), `R`을 누르면 앱 전체 재시작입니다.

✅ **확인**: 기기 화면에 앱이 뜨면 모든 세팅이 끝났습니다. 🎉

---

## 삼성 휴대폰 비율로 테스트하기

### 방법 A. Android 에뮬레이터

1. Android Studio → `Device Manager` → `Create Device`
2. `New Hardware Profile`에서 아래처럼 입력합니다.

   ```text
   Name: Galaxy test device
   Screen size: 6.2 inch
   Resolution: 1080 x 2340
   ```

3. Android 시스템 이미지를 선택하고 에뮬레이터를 생성합니다.
4. 에뮬레이터 실행 후, 프로젝트 폴더에서 확인합니다.

   ```powershell
   flutter devices
   ```

5. 목록에 `emulator-5554` 같은 기기가 보이면 실행합니다.

   ```powershell
   flutter run -d emulator-5554
   ```

> ⚠️ AVD는 삼성 One UI를 실행하는 장치가 아니므로 **화면 크기/비율 확인용**입니다. 실제 삼성 UI와 동작까지 확인하려면 방법 B를 사용합니다.

<details>
<summary>삼성 공식 Galaxy Emulator Skin 적용하기 (선택 사항)</summary>

에뮬레이터 외형까지 삼성 기기처럼 보이게 하고 싶다면 아래 절차를 따릅니다.

1. [Samsung Developer](https://developer.samsung.com/)에 로그인
2. `Support` → `Galaxy Emulator Skin`에서 원하는 기종 Skin 다운로드
3. 압축 해제 후 아래 폴더에 넣기

   ```text
   C:\Users\<사용자이름>\AppData\Local\Android\Sdk\skins
   ```

4. Android Studio → `Device Manager` → `Create Device` → `New Hardware Profile`
5. 화면 크기/해상도 입력 후 `Default Skin`에서 방금 넣은 Skin 폴더 선택
6. 시스템 이미지와 API 선택 후 에뮬레이터 생성

> 📌 Skin은 외형만 바꿔줄 뿐, One UI 동작까지 재현하지는 않습니다. 최종 확인은 실제 기기에서 진행해야 합니다.

</details>

### 방법 B. 실제 삼성 휴대폰 연결

1. 휴대폰 `설정` → `휴대전화 정보` → `소프트웨어 정보`
2. `빌드 번호`를 7번 연속 탭 → 개발자 옵션 활성화
3. `개발자 옵션` → `USB 디버깅` 켜기
4. USB 케이블로 PC 연결 → 휴대폰에서 디버깅 허용 팝업 승인
5. 연결 확인

   ```powershell
   adb devices
   flutter devices
   ```

---

## 실행 및 테스트 명령어

| 목적 | 명령어 |
|---|---|
| 패키지 설치 | `flutter pub get` |
| 연결된 기기 확인 | `flutter devices` |
| 특정 기기로 실행 | `flutter run -d <기기ID>` |
| 정적 분석 | `flutter analyze` |
| 위젯 테스트 | `flutter test` |

> 📌 `test/widget_test.dart`는 앱을 Android에서 실행하는 파일이 아니라 위젯 동작을 자동 검증하는 테스트 파일입니다. 앱의 실제 시작점은 `lib/main.dart`입니다.

---

## 문제 해결

<details>
<summary><strong>'flutter' 용어가 cmdlet... 으로 인식되지 않습니다</strong></summary>

Flutter SDK 경로가 PATH에 등록되지 않았거나, 등록 후 VS Code를 다시 켜지 않은 경우입니다.

1. VS Code를 완전히 종료했다가 다시 실행합니다.
2. 그래도 안 되면 ③단계의 **Add SDK to PATH**를 다시 진행하거나, ⑦단계와 같은 방법으로 `<SDK 폴더>\flutter\bin` 경로를 `Path`에 직접 추가합니다.

</details>

<details>
<summary><strong>ERROR: JAVA_HOME is not set (avdmanager 실행 시)</strong></summary>

`avdmanager`가 Java 위치를 찾지 못한 경우입니다. ⑦단계의 4번처럼 사용자 변수에 `JAVA_HOME`을 `C:\Program Files\Android\Android Studio\jbr`로 추가한 뒤 VS Code를 다시 실행합니다.
해당 폴더가 없다면 Android Studio를 다른 경로에 설치한 것이므로, 그 설치 폴더 안의 `jbr` 폴더 경로를 넣습니다.

</details>

<details>
<summary><strong>flutter doctor에서 Visual Studio만 ❌로 나옴</strong></summary>

Android로만 실행한다면 무시해도 됩니다. Windows 데스크톱 앱(`flutter run -d windows`)으로 실행하려면 [Visual Studio](https://visualstudio.microsoft.com/ko/downloads/) (VS Code와 다른 프로그램)를 설치하고, 설치 화면에서 **C++를 사용한 데스크톱 개발** 워크로드를 체크해야 합니다.

</details>

<details>
<summary><strong>Android 기기가 flutter devices에 안 보임</strong></summary>

에뮬레이터가 실행 중인지 먼저 확인한 뒤, ADB를 재시작합니다.

```powershell
adb kill-server
adb start-server
adb devices
flutter devices
```

기기 상태가 `offline`이면 에뮬레이터가 완전히 부팅될 때까지 기다린 후 다시 확인합니다.

</details>

<details>
<summary><strong>Package ndk not found 오류</strong></summary>

오류 메시지에 표시된 NDK 버전을 Android Studio SDK Manager에서 설치합니다.
`sdkmanager`를 직접 쓴다면 PowerShell에서 아래처럼 실행합니다. (버전은 오류 메시지 값으로 교체)

```powershell
sdkmanager --install "ndk/28.2.13676358"
```

</details>

<details>
<summary><strong>Java restricted method 경고가 나옴</strong></summary>

`java.lang.System::load` 관련 경고만 뜨고 빌드가 계속 진행된다면 치명적 오류가 아닙니다.
`BUILD FAILED`가 함께 뜨는지만 확인하면 됩니다.

</details>

<details>
<summary><strong>Windows 실행 시 화면이 가로로 나옴</strong></summary>

Windows 실행 창 크기는 `windows/runner/main.cpp`에서 설정합니다. 현재 프로젝트는 휴대폰 세로 비율 확인을 위해 `393 x 852`로 고정되어 있습니다. Android 에뮬레이터로 실행할 때는 실제 Android 기기의 화면 크기가 그대로 사용되므로 이 설정과 무관합니다.

</details>

---

## 변경 작업 규칙

- 사용자에게 보이는 문구는 한국어로 작성
- 단어 데이터와 학습 로직은 화면 코드와 분리
- 변경 후 `flutter analyze`와 관련 테스트 실행
- 비밀키, 개인정보, 로컬 환경 파일은 커밋하지 않기

---

## 참고 자료

- [Flutter VS Code 설정하기](https://minibcake.tistory.com/556) (코딩항해기, 세팅 단계별 화면 캡처)
- [Android Studio에서 삼성 갤럭시 디바이스 에뮬레이터 추가](https://keepgoinglog.tistory.com/202)
- [Flutter 공식 Windows 설치 문서](https://docs.flutter.dev/get-started/install/windows)
- [Android Studio 공식 다운로드 페이지](https://developer.android.com/studio)
- [Samsung Developer 공식 사이트](https://developer.samsung.com/)
