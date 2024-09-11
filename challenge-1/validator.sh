#!/bin/bash

# Check HTTP to HTTPS redirection
ALB_DNS_NAME = $(terraform output -raw alb_dns_name) # Fetching the ALB DNS name from the terraform output.tf file
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://$ALB_DNS_NAME)
if [ $HTTP_STATUS -eq 301 ]; then
  echo "HTTP to HTTPS redirection test passed."
else
  echo "HTTP to HTTPS redirection test failed."
fi

# Check if the content is served correctly
HTTP_CONTENT=$(curl -s http://$ALB_DNS_NAME)
EXPECTED_CONTENT="<h1>Hello World!</h1>"
if [[ $HTTP_CONTENT == *"$EXPECTED_CONTENT"* ]]; then
  echo "Content test passed."
else
  echo "Content test failed."
fi