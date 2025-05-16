.PHONY: init fmt validate clean

# 기본 변수 설정
ENV ?= dev

# 초기화
init:
	terraform init

# 코드 형식 정리
fmt:
	terraform fmt -recursive

# 구문 검증
validate: fmt
	terraform validate

# 계획 확인
plan: validate
	terraform plan -var-file="$(ENV).tfvars"

# 인프라 적용
apply: validate
	terraform apply -var-file="$(ENV).tfvars"

# 자동 승인으로 인프라 적용 (주의해서 사용)
apply-auto: validate
	terraform apply -var-file="$(ENV).tfvars" -auto-approve

# 인프라 삭제
destroy:
	terraform destroy -var-file="$(ENV).tfvars"

# 자동 승인으로 인프라 삭제 (주의해서 사용)
destroy-auto:
	terraform destroy -var-file="$(ENV).tfvars" -auto-approve

# 환경별 계획 확인
plan-dev: 
	$(MAKE) plan ENV=dev

plan-test: 
	$(MAKE) plan ENV=test

plan-prod: 
	$(MAKE) plan ENV=prod

# 환경별 인프라 적용
apply-dev: 
	$(MAKE) apply ENV=dev

apply-test: 
	$(MAKE) apply ENV=test

apply-prod: 
	$(MAKE) apply ENV=prod

# 환경별 인프라 삭제
destroy-dev: 
	$(MAKE) destroy ENV=dev

destroy-test: 
	$(MAKE) destroy ENV=test

destroy-prod: 
	$(MAKE) destroy ENV=prod

# 캐시 및 임시 파일 정리
clean:
	rm -rf .terraform
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "terraform.tfstate*" -delete

# 사용 방법 표시
help:
	@echo "사용 가능한 명령어:"
	@echo "  make init               - 테라폼 초기화"
	@echo "  make fmt                - 코드 형식 정리"
	@echo "  make validate           - 구문 검증"
	@echo "  make plan               - 기본 환경(dev) 계획 확인"
	@echo "  make plan-dev           - 개발 환경 계획 확인"
	@echo "  make plan-test          - 테스트 환경 계획 확인"
	@echo "  make plan-prod          - 프로덕션 환경 계획 확인"
	@echo "  make apply              - 기본 환경(dev) 인프라 적용"
	@echo "  make apply-dev          - 개발 환경 인프라 적용"
	@echo "  make apply-test         - 테스트 환경 인프라 적용"
	@echo "  make apply-prod         - 프로덕션 환경 인프라 적용"
	@echo "  make apply-auto         - 기본 환경 자동 승인으로 적용 (주의)"
	@echo "  make destroy            - 기본 환경(dev) 인프라 삭제"
	@echo "  make destroy-dev        - 개발 환경 인프라 삭제"
	@echo "  make destroy-test       - 테스트 환경 인프라 삭제"
	@echo "  make destroy-prod       - 프로덕션 환경 인프라 삭제"
	@echo "  make destroy-auto       - 기본 환경 자동 승인으로 삭제 (주의)"
	@echo "  make clean              - 캐시 및 임시 파일 정리"
	@echo "  make help               - 도움말 표시"

# 기본 명령어
default: help 