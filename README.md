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
3. [빠른 시작 (5단계)](#빠른-시작-5단계)
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
| 추가 도구 | Android Studio, Android SDK 36, Android SDK Command-line Tools |

---

## 빠른 시작 (5단계)

처음 이 프로젝트를 세팅하는 경우, 아래 순서대로만 따라 하면 됩니다.

### 1단계. 필수 프로그램 설치

아래 3가지를 먼저 설치합니다.

- [ ] [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) 설치
- [ ] [Android Studio](https://developer.android.com/studio) 설치
- [ ] [VS Code](https://code.visualstudio.com/) 설치

VS Code를 연 뒤, 왼쪽 `Extensions` 탭에서 아래 확장을 검색해 설치합니다.

- [ ] `Flutter` (Dart Code)
- [ ] `Dart` (Flutter 설치 시 자동으로 함께 설치되는 경우가 많음)

> 💡 이미 이 저장소를 내려받았다면 새 프로젝트를 만들 필요 없이, 저장소 폴더를 VS Code로 바로 열면 됩니다.
> (`Ctrl+Shift+P` → `Flutter: New Project`는 SDK 경로 인식 확인용으로만 필요할 때 사용)

### 2단계. Android Studio에서 SDK 구성 요소 설치

Android Studio를 처음 실행하면 `SDK Manager`가 뜹니다. 아래 항목을 모두 체크하고 설치합니다.

- [ ] Android SDK Platform
- [ ] Android SDK Build-Tools
- [ ] Android SDK Platform-Tools
- [ ] Android SDK Command-line Tools (latest)
- [ ] Android Emulator
- [ ] Android SDK NDK

> ⚠️ 빌드 중 특정 NDK 버전이 없다는 메시지가 뜨면, 그 버전을 SDK Manager에서 추가로 설치하면 됩니다. (Flutter 설정에 따라 필요한 NDK 버전이 정해집니다.)

### 3단계. 환경 변수 등록

Android SDK는 보통 아래 경로에 설치되어 있습니다.

```text
C:\Users\<사용자이름>\AppData\Local\Android\sdk
```

Windows 검색창에서 `환경 변수 편집` 실행 → `Path` 항목에 아래 3줄을 각각 추가합니다.

```text
C:\Users\<사용자이름>\AppData\Local\Android\sdk\platform-tools
C:\Users\<사용자이름>\AppData\Local\Android\sdk\emulator
C:\Users\<사용자이름>\AppData\Local\Android\sdk\cmdline-tools\latest\bin
```

> ⚠️ 등록 후 VS Code를 **완전히 종료했다가 다시 실행**해야 적용됩니다.

등록이 잘 됐는지 터미널(PowerShell)에서 확인합니다.

```powershell
flutter doctor
adb --version
avdmanager --version
```

`flutter doctor` 결과에서 `Android toolchain`과 `Android licenses` 항목이 초록색(정상)인지 확인합니다. 빨간색/노란색이면 아래 명령을 실행하고, 나오는 질문마다 `y`를 입력합니다.

```powershell
flutter doctor --android-licenses
```

> 📌 최근 버전에서는 `--licenses`가 필요 없다는 경고만 뜰 수 있습니다. `flutter doctor`의 Android toolchain이 정상이면 추가 조치는 필요 없습니다.

### 4단계. 테스트할 기기 준비

둘 중 하나를 선택합니다.

| 방법 | 언제 사용 | 이동 |
|---|---|---|
| Android 에뮬레이터 | 화면 비율만 빠르게 확인하고 싶을 때 | [바로가기](#방법-a-android-에뮬레이터) |
| 실제 삼성 휴대폰 | 실제 One UI 동작까지 확인하고 싶을 때 | [바로가기](#방법-b-실제-삼성-휴대폰-연결) |

자세한 방법은 [삼성 휴대폰 비율로 테스트하기](#삼성-휴대폰-비율로-테스트하기) 섹션을 참고합니다.

### 5단계. 프로젝트 실행

```powershell
flutter pub get
flutter devices
flutter run -d <기기ID>
```

VS Code를 쓴다면 하단 상태 바에서 기기를 선택한 뒤 `F5`를 눌러도 됩니다.

- 저장하거나 터미널에서 `r` → 핫 리로드
- 터미널에서 `R` → 앱 완전 재시작

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

- [Flutter VS Code 설정하기](https://minibcake.tistory.com/556)
- [Android Studio에서 삼성 갤럭시 디바이스 에뮬레이터 추가](https://keepgoinglog.tistory.com/202)
- [Flutter 공식 Windows 설치 문서](https://docs.flutter.dev/get-started/install/windows)
- [Android Studio 공식 다운로드 페이지](https://developer.android.com/studio)
- [Samsung Developer 공식 사이트](https://developer.samsung.com/)
