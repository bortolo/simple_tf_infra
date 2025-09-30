#!/bin/bash
SECONDS=0  # reset timer
terraform -chdir=./infra_frontend init
terraform -chdir=./infra_frontend apply -auto-approve
INTERTEMPO=0
DIFF_FE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

BACKEND_CONFIG_FILE=./infra_backend_docker/01-CICD_lambda_docker_image/var_owned.auto.tfvars
BUCKET_BACKEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")
CODEBUILD_BACKEND=$(awk -F'=' '/^docker_build_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")
BUILD_PROJECT_NAME=arn:aws:codebuild:eu-central-1:152371567679:project/"$CODEBUILD_BACKEND"

terraform -chdir=./infra_backend_docker/01-CICD_lambda_docker_image init
terraform -chdir=./infra_backend_docker/01-CICD_lambda_docker_image apply -auto-approve

# aspetto che parta la build (altrimenti non entra nel ciclo)
sleep 15

# controllo che finisca la build
while true; do
  IN_PROGRESS=$(aws codebuild batch-get-builds --ids $(aws codebuild list-builds-for-project --project-name $CODEBUILD_BACKEND --sort-order DESCENDING --query 'ids' --output text) --query 'builds[?buildStatus==`IN_PROGRESS`].id' --output text)  
  if [ -z "$IN_PROGRESS" ]; then
    echo "[NOTE] No more build are running"
    break
  else
    echo "[WAITING] First docker image build running (build id: $IN_PROGRESS)"
  fi
  sleep 10
done


terraform -chdir=./infra_backend_docker/02-lambda_and_dynamo init
terraform -chdir=./infra_backend_docker/02-lambda_and_dynamo apply -auto-approve

# Ora che ho creato la lambda function con una prima immagine posso creare la CICD definitiva
terraform -chdir=./infra_backend_docker/03-CICD_lambda_deployment init
terraform -chdir=./infra_backend_docker/03-CICD_lambda_deployment apply -auto-approve
terraform -chdir=./infra_backend_docker/04-api_gw init
terraform -chdir=./infra_backend_docker/04-api_gw apply -auto-approve

terraform -chdir=./infra_frontend output
terraform -chdir=./infra_backend_docker/02-lambda_and_dynamo output
terraform -chdir=./infra_backend_docker/03-CICD_lambda_deployment output
terraform -chdir=./infra_backend_docker/04-api_gw output

DIFF_BE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

echo "Tempo per build frontend: $DIFF_FE secondi"
echo "Tempo per build backend: $DIFF_BE secondi"
echo "Tempo totale per build: $SECONDS secondi"