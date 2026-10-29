# 트러블슈팅 기록

## 1. AWS CLI 실행 파일은 설치됐지만 셸에서 찾지 못함

### 증상

`aws` 명령이 없었습니다. 초기에는 호스트 아키텍처 `x86_64`만 보고 Linux용 바이너리를 내려받아 `exec format error`가 발생했고, 추정한 macOS 패키지 URL은 HTTP 404를 반환했습니다. 이후 AWS CLI 2.39.1 바이너리는 `~/.local/share/aws-cli/aws`에 설치됐지만, 셸의 `PATH`에 `~/.local/bin`이 없어 `aws` 명령으로 실행할 수 없었습니다.

### 원인 가설

OS와 CPU 아키텍처를 함께 확인하지 않아 처음에 맞지 않는 설치 파일을 골랐고, 최종적으로는 CLI 실행 파일이 있는 경로가 셸 `PATH`에서 누락된 것으로 가설을 세웠습니다.

### 검증

`uname -s`와 `uname -m`으로 `Darwin x86_64`를 확인하고, 설치된 실행 파일에서 직접 `aws --version`이 동작하는 것을 검증했습니다. `command -v aws`는 PATH 설정 전까지 결과가 없었습니다. 공식 설치 패키지 서명은 AWS 팀 ID `94KV3E626L`로 확인했습니다.

### 조치

`scripts/install-aws-cli.sh`를 만들어 사용자 설치 위치의 실행 링크를 `~/.local/bin`에 연결하고, zsh 설정 파일에 해당 경로를 추가하도록 정리했습니다. 설치와 PATH 등록 모두 `sudo` 및 Homebrew 없이 수행했습니다.

### 결과

`source ~/.zshrc` 후 `command -v aws`가 `/Users/innuendo3712/.local/bin/aws`를 가리키고, `aws --version`이 `aws-cli/2.39.1 ... Darwin/24.6.0 ... x86_64`를 반환하는 것을 확인했습니다. AWS 자격 증명은 아직 설정되지 않아 AWS 계정 API 호출은 진행하지 않았습니다.

### 재발 방지

설치 파일을 선택하기 전에 `uname -s`와 `uname -m`을 함께 확인하고, 설치 링크와 절차는 AWS 공식 문서에서 확인합니다. 실행 후 `aws --version`으로 OS/아키텍처가 맞는지 검증합니다.

