# AWS VPC + EC2 Web Server Lab

서울 리전(`ap-northeast-2`)에 VPC, 퍼블릭 서브넷, 인터넷 게이트웨이, 제한된 보안 그룹과 EC2 웹 서버를 구성하는 실습입니다.

## 진행 상태

- AWS CLI 설치 및 PATH 등록은 [`scripts/install-aws-cli.sh`](scripts/install-aws-cli.sh)로 수행합니다. 기본 경로는 `~/.local/bin/aws`이며 sudo와 Homebrew가 필요하지 않습니다.
- AWS 자격 증명이 아직 설정되지 않아 계정 확인, 리소스 생성, 외부 접속 검증은 보류 중입니다.
- 아래의 접속 검증 결과는 실제 배포 후 URL과 응답으로 갱신합니다. 현재는 검증하지 않았습니다.

## 외부 접속 검증

- 방식: B — `GET http://<퍼블릭 IP>/health`
- URL: 배포 후 기입
- 기대 응답: HTTP 200, 본문 `OK`
- 증빙: `screenshots/external-health.png` (배포 후 브라우저 또는 터미널 결과를 캡처)

## 구성 및 보안

아키텍처는 [docs/architecture.pdf](docs/architecture.pdf)를 참고하세요. SSH(22)는 현재 접속지의 공인 IPv4 `/32`만 허용하고 HTTP(80)는 전체 공개합니다. 인바운드 전체 포트 허용 규칙은 사용하지 않습니다. IAM 권한은 `AdministratorAccess`를 사용하지 않고 EC2/VPC 실습 범위로 한정합니다.

## 산출물

- [아키텍처 다이어그램](docs/architecture.pdf)
- [트러블슈팅 보고서](docs/troubleshooting.md)
- [리소스 정리 체크리스트](docs/cleanup-checklist.md)
- 외부 접속 캡처: `screenshots/external-health.png` (미작성)

## CLI 자격 증명 설정

AWS CLI 자격 증명은 저장소에 기록하지 마세요. AWS IAM 사용자의 액세스 키가 준비되면 터미널에서 `aws configure --profile vpc-lab`를 실행해 입력하고, MFA가 필요한 환경에서는 해당 계정의 승인된 세션 자격 증명을 사용하세요. MFA 일회용 코드를 액세스 키/시크릿 키와 혼동하지 마세요. [`scripts/verify-aws-profile.sh`](scripts/verify-aws-profile.sh)는 자격 증명 값을 노출하지 않고 설정된 신원을 확인합니다. 출력된 계정이 본인 계정인지 확인한 다음에만 배포를 진행합니다.

## 명령 스크립트

- `scripts/install-aws-cli.sh`: macOS용 AWS CLI v2 설치와 zsh PATH 등록
- `scripts/uninstall-aws-cli.sh`: 사용자 영역 AWS CLI 제거 (확인 입력 필요, `~/.aws` 보존)
- `scripts/verify-aws-profile.sh [프로필명]`: AWS 프로필 신원 확인 (기본값 `vpc-lab`)

실행 예시: `bash scripts/install-aws-cli.sh` 후 새 터미널을 열거나 현재 터미널에서 `source ~/.zshrc`를 실행하고 `aws --version`을 확인합니다.

