# AI Usage Log

## Tools used

- Cursor (Claude / GPT-4o) for scaffolding Dockerfile, Terraform, GitHub Actions and initial application stub
- ChatGPT for reviewing IAM policy wording and threat-model language

## Concrete prompts & outcomes

1. **Prompt**: “Write a multi-stage Dockerfile for a FastAPI app that runs as non-root and has a healthcheck.”
   - **Result**: First draft left the final stage as root. I changed it to `USER 10001` and added an explicit non-root user creation.

2. **Prompt**: “Generate a least-privilege IAM policy for a service that only needs GetItem/Query/Scan on one DynamoDB table and GetSecretValue on one secret.”
   - **Result**: AI initially produced `"Action": ["dynamodb:*"]` and `"Resource": "*"`. I rejected the wildcards and rewrote the policy with explicit actions and resource ARNs (see `terraform/main.tf`).

3. **Prompt**: “Create a GitHub Actions workflow that fails the build on critical Trivy findings and on any secret detected by Gitleaks.”
   - **Result**: Structure was correct, but the Trivy step originally used `exit-code: 0`. I set it to `1` so the job fails on CRITICAL.

## Specific insecure AI default that was caught and fixed

Classic real-world failure mode: AI-generated Terraform IAM policy contained wildcard actions and resources (`"*"`).  
Caught by reading the generated policy against the hard constraint “No IAM policy uses a wildcard … unless explicitly justified”.  
Replaced with the narrow, single-resource statements that appear in the final `main.tf`.
