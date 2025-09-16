#!/bin/bash
terraform -chdir=./infra_frontend apply -auto-approve

BACKEND_CONFIG_FILE=./infra_backend/terraform.tfvars
BUCKET_BACKEND=$(awk -F'=' '/^bucket_name/ {gsub(/"/,"",$2); gsub(/ /,"",$2); print $2}' "$BACKEND_CONFIG_FILE")

# Per preparare lo zip dei layers
mkdir python
python3 -m venv venv 
source venv/bin/activate
pip install pandas plotly numpy -t python/
zip -r layer.zip python
aws s3 cp layer.zip s3://$BUCKET_BACKEND/layer.zip

terraform -chdir=./infra_backend apply -auto-approve