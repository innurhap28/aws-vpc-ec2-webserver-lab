# AWS VPC + EC2 Web Server Lab

서울 리전(`ap-northeast-2`)에 VPC, 퍼블릭 서브넷, 인터넷 게이트웨이, 제한된 보안 그룹과 EC2 웹 서버를 구성하는 실습입니다.

## 진행 상태

- AWS CLI 설치 및 PATH 등록은 [`scripts/install-aws-cli.sh`](scripts/install-aws-cli.sh)로 수행합니다. 기본 경로는 `~/.local/bin/aws`이며 sudo와 Homebrew가 필요하지 않습니다.
- `vpc-lab` 프로필의 STS 신원 확인은 성공했습니다. 현재 IAM 주체는 EC2/VPC 조회 권한이 없고, 서울 리전은 조직 SCP에서 명시적으로 차단되어 있어 리소스 목록을 아직 읽지 못했습니다.
- 이 저장소에서 AWS 리소스를 생성하거나 외부 접속을 검증하지 않았습니다.
- 아래의 접속 검증 결과는 실제 배포 후 URL과 응답으로 갱신합니다. 현재는 검증하지 않았습니다.

## 외부 접속 검증

- 증빙: [`screenshots/Nginx_healthcheck.png`](screenshots/Nginx_healthcheck.png)

## 구성 및 보안

아키텍처 Mermaid 다이어그램과 캡처 근거는 [docs/architecture.md](docs/architecture.md)를 참고하세요. 캡처 기준 SSH(22)는 `121.135.181.56/32`만 허용하고 HTTP(80)는 전체 공개합니다. 인바운드 전체 포트 허용 규칙은 사용하지 않습니다.

## 산출물

- [아키텍처 다이어그램 (Mermaid)](docs/architecture.md)
- [트러블슈팅 보고서](docs/troubleshooting.md)
- [리소스 정리 체크리스트](docs/cleanup-checklist.md)
- [외부 접속 캡처](screenshots/Nginx_healthcheck.png)

## 명령 스크립트

- `scripts/install-aws-cli.sh`: macOS용 AWS CLI v2 설치와 zsh PATH 등록
- `scripts/uninstall-aws-cli.sh`: 사용자 영역 AWS CLI 제거 (확인 입력 필요, `~/.aws` 보존)
- `scripts/verify-aws-profile.sh [프로필명]`: AWS 프로필 신원 확인 (기본값 `vpc-lab`)
- `scripts/inspect-lab.sh [프로필명]`: 서울·시드니 리소스 목록과 과금 위험 리소스 읽기 전용 조회

실행 예시: `bash scripts/install-aws-cli.sh` 후 새 터미널을 열거나 현재 터미널에서 `source ~/.zshrc`를 실행하고 `aws --version`을 확인합니다.

