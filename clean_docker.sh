#!/bin/bash
SECONDS=0  # reset timer

FRONTEND_CONFIG_FILE=./infra_frontend/terraform.tfvars
BUCKET_FRONTEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$FRONTEND_CONFIG_FILE")

BACKEND_CONFIG_FILE_FIRST=./infra_backend_docker/01-CICD_lambda_docker_image/var_owned.auto.tfvars
BUCKET_BACKEND_FIRST=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE_FIRST")

BACKEND_CONFIG_FILE=./infra_backend_docker/03-CICD_lambda_deployment/var_owned.auto.tfvars
BUCKET_BACKEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")

# Ricordarsi di disattivari eventuali VPN per lanciare i comandi aws s3
aws s3 rm s3://$BUCKET_BACKEND --recursive
aws s3 rm s3://$BUCKET_BACKEND_FIRST --recursive
aws s3 rm s3://$BUCKET_FRONTEND --recursive

INTERTEMPO=0
DIFF_S3=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS


terraform -chdir=./infra_frontend destroy -auto-approve
DIFF_FE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

terraform -chdir=./infra_backend_docker/04-api_gw destroy -auto-approve
terraform -chdir=./infra_backend_docker/03-CICD_lambda_deployment destroy -auto-approve
terraform -chdir=./infra_backend_docker/02-lambda_and_dynamo destroy -auto-approve
terraform -chdir=./infra_backend_docker/01-CICD_lambda_docker_image destroy -auto-approve

DIFF_BE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

echo "Tempo per clean bucket s3: $DIFF_S3 secondi"
echo "Tempo per clean frontend: $DIFF_FE secondi"
echo "Tempo per clean backend: $DIFF_BE secondi"
echo "Tempo totale per clean: $SECONDS secondi"