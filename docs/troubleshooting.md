# 트러블슈팅 기록

## 1. CLI 설치 환경 불일치 및 다운로드 이름 확인

### 증상

AWS CLI가 PATH에 없었습니다. 처음 확인한 호스트 아키텍처 문자열은 `x86_64`였고, 이를 Linux 환경으로 잘못 판단해 Linux용 AWS CLI 바이너리를 받아 실행했을 때 `exec format error`가 발생했습니다. macOS용 패키지 파일명을 임의로 추정해 요청한 URL은 HTTP 404를 반환했습니다.

### 원인 가설

호스트 OS와 CPU 아키텍처를 함께 확인하지 않아 OS에 맞지 않는 실행 파일을 선택했을 가능성이 있다고 판단했습니다. 또한 AWS 배포 파일명은 문서에서 확인하지 않고 추정했습니다.

### 검증

`uname -a`와 Python `platform.system()/machine()`으로 `Darwin x86_64`를 확인했습니다. Linux 바이너리는 ELF 형식인 반면 macOS용 실행 파일은 Mach-O여야 하므로 실행 오류와 일치했습니다. AWS CLI 공식 설치 문서의 macOS 사용자 설치 방법 및 서명 검증 메시지를 확인했습니다.

### 조치

AWS 공식 macOS 설치 스크립트를 사용하고 `XDG_DATA_HOME=/private/tmp/aws-data`, `XDG_BIN_HOME=/private/tmp/bin`으로 사용자 영역에 설치했습니다. `sudo` 및 Homebrew는 사용하지 않았습니다.

### 결과

`/private/tmp/aws-data/aws-cli/aws --version` 결과 `aws-cli/2.39.1 ... Darwin/24.6.0 ... x86_64`를 확인했습니다. AWS 자격 증명은 아직 없어서 AWS 계정 API 호출은 진행하지 않았습니다.

### 재발 방지

설치 파일을 선택하기 전에 `uname -s`와 `uname -m`을 함께 확인하고, 설치 링크와 절차는 AWS 공식 문서에서 확인합니다. 실행 후 `aws --version`으로 OS/아키텍처가 맞는지 검증합니다.

