#!/usr/bin/env bash
set -uo pipefail

# 서울 과제 계정과 새 가입 방식에서 배정될 수 있는 Sydney 리전을 읽기 전용으로 조회합니다.
# 이 스크립트는 생성, 수정, 삭제 API를 호출하지 않습니다.

PROFILE="${1:-vpc-lab}"
AWS_BIN="$(command -v aws || true)"

# PATH에 AWS CLI가 없으면 표준 사용자 설치 경로와 기존 임시 설치 경로를 확인합니다.
if [[ -z "$AWS_BIN" && -x "$HOME/.local/bin/aws" ]]; then
  AWS_BIN="$HOME/.local/bin/aws"
fi
if [[ -z "$AWS_BIN" && -x /private/tmp/aws-data/aws-cli/aws ]]; then
  AWS_BIN="/private/tmp/aws-data/aws-cli/aws"
fi
if [[ -z "$AWS_BIN" ]]; then
  echo "AWS CLI를 찾을 수 없습니다. scripts/install-aws-cli.sh를 실행하세요." >&2
  exit 127
fi

echo "AWS 계정 신원 (프로필: $PROFILE)"
"$AWS_BIN" --profile "$PROFILE" --region ap-northeast-2 --no-cli-pager sts get-caller-identity || exit $?

조회() {
  local region="$1" label="$2" service="$3" operation="$4" query="$5"
  echo
  echo "[$region] $label"
  if ! "$AWS_BIN" --profile "$PROFILE" --region "$region" --no-cli-pager \
    "$service" "$operation" --query "$query" --output json; then
    echo "조회 실패: 필요한 읽기 권한 또는 리전 접근 상태를 확인하세요." >&2
  fi
}

for REGION in ap-northeast-2 ap-southeast-2; do
  echo
  echo "========== $REGION =========="
  조회 "$REGION" "VPC" ec2 describe-vpcs 'Vpcs[].{Id:VpcId,CIDR:CidrBlock,Default:IsDefault,State:State,Tags:Tags}'
  조회 "$REGION" "서브넷" ec2 describe-subnets 'Subnets[].{Id:SubnetId,Vpc:VpcId,CIDR:CidrBlock,AZ:AvailabilityZone,PublicIP:MapPublicIpOnLaunch,Tags:Tags}'
  조회 "$REGION" "인터넷 게이트웨이" ec2 describe-internet-gateways 'InternetGateways[].{Id:InternetGatewayId,Attachments:Attachments[].{Vpc:VpcId,State:State},Tags:Tags}'
  조회 "$REGION" "라우트 테이블" ec2 describe-route-tables 'RouteTables[].{Id:RouteTableId,Vpc:VpcId,Associations:Associations[].{Subnet:SubnetId,Main:Main},Routes:Routes[].{Destination:DestinationCidrBlock,Gateway:GatewayId,State:State},Tags:Tags}'
  조회 "$REGION" "보안 그룹 및 인바운드" ec2 describe-security-groups 'SecurityGroups[].{Id:GroupId,Name:GroupName,Vpc:VpcId,Ingress:IpPermissions[].{Protocol:IpProtocol,From:FromPort,To:ToPort,IPv4:IpRanges[].CidrIp},Tags:Tags}'
  조회 "$REGION" "EC2 인스턴스" ec2 describe-instances 'Reservations[].Instances[].{Id:InstanceId,Name:Tags[?Key==`Name`].Value|[0],Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress,Subnet:SubnetId,Vpc:VpcId,SGs:SecurityGroups[].GroupId}'
  조회 "$REGION" "EBS 볼륨" ec2 describe-volumes 'Volumes[].{Id:VolumeId,State:State,SizeGiB:Size,AttachedTo:Attachments[].InstanceId,Tags:Tags}'
  조회 "$REGION" "Elastic IP" ec2 describe-addresses 'Addresses[].{PublicIP:PublicIp,AllocationId:AllocationId,AssociationId:AssociationId,Instance:InstanceId}'
  조회 "$REGION" "NAT Gateway" ec2 describe-nat-gateways 'NatGateways[].{Id:NatGatewayId,State:State,Vpc:VpcId,Subnet:SubnetId}'
  조회 "$REGION" "로드 밸런서" elbv2 describe-load-balancers 'LoadBalancers[].{Name:LoadBalancerName,State:State.Code,Type:Type,Vpc:VpcId}'
  조회 "$REGION" "RDS 데이터베이스" rds describe-db-instances 'DBInstances[].{Id:DBInstanceIdentifier,Status:DBInstanceStatus,Class:DBInstanceClass,MultiAZ:MultiAZ}'
done
