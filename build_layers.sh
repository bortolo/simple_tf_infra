#!/bin/bash
SECONDS=0  # reset timer
terraform -chdir=./infra_frontend apply -auto-approve
INTERTEMPO=0
DIFF_FE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

BACKEND_CONFIG_FILE=./infra_backend_layers/terraform.tfvars
BUCKET_BACKEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")
L_LAYERS_BACKEND=$(awk -F'=' '/^codebuild_name_layer/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")


terraform -chdir=./infra_backend_layers apply -auto-approve
DIFF_BE=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

# Per preparare e installare i layer su lambda
aws codebuild start-build --project-name $L_LAYERS_BACKEND
DIFF_LY=$((SECONDS-INTERTEMPO))
INTERTEMPO=$SECONDS

echo "Tempo per build frontend: $DIFF_FE secondi"
echo "Tempo per build backend: $DIFF_BE secondi"
echo "Tempo per build layers: $DIFF_LY secondi"
echo "Tempo totale per build: $SECONDS secondi"