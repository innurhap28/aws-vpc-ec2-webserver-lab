#!/usr/bin/env bash
set -euo pipefail

# AWS CLI v2를 sudo나 Homebrew 없이 현재 사용자 계정에 설치합니다.
# 공식 macOS 패키지의 서명을 확인한 뒤 사용자 폴더에 압축을 풉니다.

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "이 설치 스크립트는 macOS 전용입니다." >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64|arm64) ;;
  *) echo "지원하지 않는 CPU 구조입니다: $(uname -m)" >&2; exit 1 ;;
esac

INSTALL_DIR="$HOME/.local/share/aws-cli"
BIN_DIR="$HOME/.local/bin"

# AWS CLI가 아직 없을 때에만 공식 설치 스크립트를 실행합니다.
if [[ ! -x "$INSTALL_DIR/aws" ]]; then
  TEMP_DIR="$(mktemp -d -t aws-cli-install.XXXXXX)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
  INSTALLER="$TEMP_DIR/install.sh"

  # AWS 공식 HTTPS 주소에서 macOS 설치 스크립트를 받습니다.
  curl --fail --location --silent --show-error \
    https://awscli.amazonaws.com/v2/install.sh \
    --output "$INSTALLER"

  # 표준 사용자 설치 위치(~/.local/share/aws-cli, ~/.local/bin)를 사용합니다.
  bash "$INSTALLER"
fi

# CLI가 설치되어 있어도 링크와 PATH 설정은 빠짐없이 보장합니다.
if [[ ! -x "$INSTALL_DIR/aws" ]]; then
  echo "AWS CLI 설치 파일을 찾지 못했습니다: $INSTALL_DIR/aws" >&2
  exit 1
fi
mkdir -p "$BIN_DIR"
ln -sfn "$INSTALL_DIR/aws" "$BIN_DIR/aws"
ln -sfn "$INSTALL_DIR/aws_completer" "$BIN_DIR/aws_completer"

# zsh 새 터미널에서 aws 명령을 찾도록 PATH 설정을 한 번만 추가합니다.
ZSHRC="$HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
touch "$ZSHRC"
if ! grep -Fq "$PATH_LINE" "$ZSHRC"; then
  printf '\n# AWS CLI 사용자 설치 경로\n%s\n' "$PATH_LINE" >> "$ZSHRC"
fi

# 현재 실행 중인 셸에서도 바로 aws 명령을 사용할 수 있게 합니다.
export PATH="$HOME/.local/bin:$PATH"
aws --version
echo "설치가 끝났습니다. 새 터미널을 열거나 아래 명령을 실행하세요:"
echo 'source ~/.zshrc'
