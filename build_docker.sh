#!/bin/bash
SECONDS=0  # reset timer
terraform -chdir=./infra_frontend apply -auto-approve
INTERTEMPO=0
DIFF_FE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

BACKEND_CONFIG_FILE=./infra_backend_docker/terraform.tfvars
CODEBUILD_BACKEND=$(awk -F'=' '/^codebuild_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")
BUILD_PROJECT_NAME=arn:aws:codebuild:eu-central-1:152371567679:project/"$CODEBUILD_BACKEND"

terraform -chdir=./infra_backend_docker apply -auto-approve

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


terraform -chdir=./infra_backend_docker/second_stack init
terraform -chdir=./infra_backend_docker/second_stack import aws_codebuild_project.docker_build $BUILD_PROJECT_NAME
terraform -chdir=./infra_backend_docker/second_stack apply -auto-approve
DIFF_BE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

echo "Tempo per build frontend: $DIFF_FE secondi"
echo "Tempo per build backend: $DIFF_BE secondi"
echo "Tempo totale per build: $SECONDS secondi"