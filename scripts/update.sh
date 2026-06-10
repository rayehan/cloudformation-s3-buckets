#!/bin/bash
set -euo pipefail

STACK_NAME="tst-s3-bucket-stack"
TEMPLATE_FILE="templates/s3-bucket.yml"
PARAMETER_FILE="parameters/tst-s3-bucket-params.json"

echo "Validating CloudFormation template..."
aws cloudformation validate-template \
  --template-body file://"$TEMPLATE_FILE" >/dev/null

echo "Updating CloudFormation stack: $STACK_NAME"

set +e
UPDATE_OUTPUT=$(aws cloudformation update-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://"$TEMPLATE_FILE" \
  --parameters file://"$PARAMETER_FILE" 2>&1)
UPDATE_EXIT_CODE=$?
set -e

if [ $UPDATE_EXIT_CODE -ne 0 ]; then
  if echo "$UPDATE_OUTPUT" | grep -q "No updates are to be performed"; then
    echo "No updates are required. Stack is already up to date."
    exit 0
  else
    echo "Stack update failed:"
    echo "$UPDATE_OUTPUT"
    exit $UPDATE_EXIT_CODE
  fi
fi

echo "Waiting for stack update to complete..."

aws cloudformation wait stack-update-complete \
  --stack-name "$STACK_NAME"

echo "Stack updated successfully."

echo "Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query 'Stacks[0].Outputs' \
  --output table