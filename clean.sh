#!/bin/bash
FRONTEND_CONFIG_FILE=./infra_frontend/terraform.tfvars
BUCKET_FRONTEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$FRONTEND_CONFIG_FILE")

BACKEND_CONFIG_FILE=./infra_backend/terraform.tfvars
BUCKET_BACKEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")

# Ricordarsi di disattivari eventuali VPN per lanciare i comandi aws s3
aws s3 rm s3://$BUCKET_BACKEND --recursive
aws s3 rm s3://$BUCKET_FRONTEND --recursive
rm layer.zip
rm -rf venv
rm -rf python

terraform -chdir=./infra_frontend destroy -auto-approve
terraform -chdir=./infra_backend destroy -auto-approve