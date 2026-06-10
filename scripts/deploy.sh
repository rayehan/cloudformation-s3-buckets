#!/bin/bash
set -euo pipefail

STACK_NAME="tst-s3-bucket-stack"
TEMPLATE_FILE="templates/s3-bucket.yml"
PARAMETER_FILE="parameters/tst-s3-bucket-params.json"

echo "Validating CloudFormation template..."
aws cloudformation validate-template \
  --template-body file://"$TEMPLATE_FILE" >/dev/null

echo "Creating CloudFormation stack: $STACK_NAME"

aws cloudformation create-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://"$TEMPLATE_FILE" \
  --parameters file://"$PARAMETER_FILE"

echo "Waiting for stack creation to complete..."

aws cloudformation wait stack-create-complete \
  --stack-name "$STACK_NAME"

echo "Stack created successfully."

echo "Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query 'Stacks[0].Outputs' \
  --output table