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

## 2. Google 소셜 가입 뒤 Sydney 프로젝트 리전 및 다른 콘솔 화면

### 증상

Google 소셜 계정으로 AWS 가입을 진행한 뒤, 일반 AWS 콘솔을 예상했지만 Builder ID/프로젝트 중심의 AWS 화면으로 이동하는 흐름을 직접 확인했습니다. 새 프로젝트의 지역 리소스가 서울이 아니라 Sydney(`ap-southeast-2`)로 자동 지정된 것도 확인했습니다.

### 원인 가설

기존의 표준 AWS 가입과 `Sign up for AWS (new)`의 계정·로그인 경험이 다른데, 이를 같은 가입 방식으로 생각해 화면 이동과 프로젝트 리전의 의미를 혼동했을 가능성이 있습니다.

### 검증

AWS 공식 문서에 따르면 `Sign up for AWS (new)`는 Google 등 기존 로그인을 지원하고, 프로젝트에 AWS 계정을 연결하는 사전 설정 환경을 만듭니다. 새 프로젝트의 리전은 연락처 국가에 따라 미국 동부(오하이오), 유럽(스톡홀름), 아시아 태평양(시드니) 중 하나로 배정됩니다. 공식 국가 목록에서 대한민국은 Sydney(`ap-southeast-2`) 배정 국가에 포함되어 있습니다. 이 가입 방식에서는 새 지역 리소스의 리전을 직접 선택할 수 없으며, 해당 프로젝트의 리전은 AWS Settings에서 확인할 수 있습니다.

이 동작은 `aws configure`에서 정하는 CLI 프로필 기본 리전과 별개입니다. CLI 기본 리전을 서울로 바꿔도 프로젝트의 실제 리전 배정이 바뀌거나 기존 리소스가 이동하지 않습니다.

### 조치 및 결과

AWS Settings의 **Project → Overview → Additional Info → Region**에서 프로젝트 리전을 확인합니다. 이 프로젝트가 Sydney로 고정되어 있으면 과제의 서울 리전 요구사항을 충족하지 않으므로, 서울 리전을 사용할 수 있는 AWS 가입/계정 구성을 먼저 확인한 뒤 배포합니다. AWS는 `Sign up for AWS (advanced)`에서 특정 리전을 선택할 수 있다고 안내합니다. 기존 새 경험 계정에서 고급 기능을 활성화하는 방법도 있지만, 계정 업그레이드가 필요하고 활성화는 되돌릴 수 없으므로 비용 및 계정 관리 영향을 검토하기 전에 실행하지 않습니다.

로그인 화면 문제는 사용한 시작 URL과 로그인 유형을 함께 기록합니다. Google/Builder ID 인증을 거쳤다는 사실만으로 표준 콘솔과 프로젝트 콘솔 중 어디로 이동했는지 원인을 단정하지 않습니다.

### 재발 방지

가입 전에 `Sign up for AWS (new)`와 `Sign up for AWS (advanced)`의 차이를 확인합니다. 리전이 고정된 과제라면 가입 직후 AWS Settings의 프로젝트 리전을 기록하고, 배포 전에 계정/프로젝트 리전과 CLI 프로필 리전을 각각 확인합니다. 계정 고급 기능 활성화처럼 되돌릴 수 없는 변경은 리전 제한, spend limit, 조직 관리 영향을 확인한 뒤 결정합니다.

### 참고 자료

- [Sign up for AWS (new)](https://docs.aws.amazon.com/accounts/latest/reference/sign-in-new.html)
- [AWS Regions for your projects](https://docs.aws.amazon.com/accounts/latest/reference/project-regions.html)
- [Compare sign-up options](https://docs.aws.amazon.com/accounts/latest/reference/sign-up-for-aws.html)
- [Activate advanced AWS features](https://docs.aws.amazon.com/accounts/latest/reference/activate-advanced-features.html)

