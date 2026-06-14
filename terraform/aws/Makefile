init:
	terraform init

validate: init
	terraform validate

plan: init
	terraform plan

apply: init
	terraform apply -auto-approve

destroy: init
	terraform destroy

.PHONY: init validate plan apply destroy
