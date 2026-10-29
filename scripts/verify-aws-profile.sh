#!/usr/bin/env bash
set -euo pipefail

# 지정한 AWS CLI 프로필의 신원을 확인합니다. 자격 증명 값은 출력하지 않습니다.
PROFILE="${1:-vpc-lab}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-northeast-2}"

if ! command -v aws >/dev/null 2>&1; then
  echo "aws 명령을 찾을 수 없습니다. scripts/install-aws-cli.sh를 먼저 실행하세요." >&2
  exit 127
fi

echo "프로필 '$PROFILE'의 AWS 계정 신원을 확인합니다."
aws sts get-caller-identity --profile "$PROFILE" --region "$AWS_DEFAULT_REGION"
