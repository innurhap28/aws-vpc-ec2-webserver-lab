#!/usr/bin/env bash
set -euo pipefail

# 이 저장소의 설치 스크립트가 만든 사용자 영역 AWS CLI만 제거합니다.
# AWS 자격 증명(~/.aws)은 다른 프로그램에서도 쓸 수 있어 삭제하지 않습니다.

INSTALL_DIR="$HOME/.local/share/aws-cli"
BIN_DIR="$HOME/.local/bin"
ZSHRC="$HOME/.zshrc"

read -r -p "사용자 영역 AWS CLI를 제거할까요? [y/N] " ANSWER
case "$ANSWER" in
  y|Y|yes|YES) ;;
  *) echo "취소했습니다."; exit 0 ;;
esac

# 링크가 이 설치 경로를 가리킬 때만 제거합니다.
for COMMAND_NAME in aws aws_completer; do
  LINK_PATH="$BIN_DIR/$COMMAND_NAME"
  if [[ -L "$LINK_PATH" ]]; then
    LINK_TARGET="$(readlink "$LINK_PATH")"
    case "$LINK_TARGET" in
      "$INSTALL_DIR"/*) rm -f "$LINK_PATH" ;;
      *) echo "다른 설치를 가리키므로 보존합니다: $LINK_PATH -> $LINK_TARGET" ;;
    esac
  fi
done

# 실행 파일이 이 설치의 것으로 확인될 때에만 설치 폴더를 제거합니다.
if [[ -x "$INSTALL_DIR/aws" ]]; then
  rm -rf "$INSTALL_DIR"
  echo "AWS CLI 설치 폴더를 제거했습니다: $INSTALL_DIR"
else
  echo "설치 폴더가 없어 건너뜁니다: $INSTALL_DIR"
fi

# 설치 스크립트가 추가한 PATH 항목만 설정 파일에서 제거합니다.
if [[ -f "$ZSHRC" ]]; then
  python3 - "$ZSHRC" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines(keepends=True)
marker = "# AWS CLI 사용자 설치 경로"
filtered = []
skip_path = False
for line in lines:
    if line.rstrip("\r\n") == marker:
        skip_path = True
        continue
    if skip_path and line.rstrip("\r\n") == 'export PATH="$HOME/.local/bin:$PATH"':
        skip_path = False
        continue
    if skip_path:
        # 마커 바로 다음 줄이 우리가 추가한 PATH가 아니면 보존합니다.
        filtered.append("# AWS CLI 사용자 설치 경로\n")
        skip_path = False
    filtered.append(line)
if skip_path:
    filtered.append("# AWS CLI 사용자 설치 경로\n")
path.write_text("".join(filtered))
PY
fi

echo "완료했습니다. ~/.aws 자격 증명은 보존했습니다."
echo "현재 터미널에서 'source ~/.zshrc'를 실행하면 변경된 PATH가 반영됩니다."
