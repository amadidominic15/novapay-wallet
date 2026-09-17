# Threat Model – NovaPay Wallet Deployment (STRIDE)

| Threat ID | Category                  | Description                                              | Mitigation                                                                 |
|-----------|---------------------------|----------------------------------------------------------|----------------------------------------------------------------------------|
| T1        | Spoofing                  | Attacker impersonates a legitimate service identity      | IAM roles with least-privilege, no long-lived access keys                  |
| T2        | Tampering                 | Malicious modification of wallet balances or image       | Image signing (future), Trivy gate, immutable tags, read-only FS (stretch) |
| T3        | Repudiation               | Actor denies having performed an action                  | Structured JSON audit logs, CloudTrail / LocalStack equivalent             |
| T4        | Information Disclosure    | Unauthorized read of wallet data or secrets              | Non-root container, Secrets Manager, no secrets in image/git, private subnet |
| T5        | Denial of Service         | Overwhelm the service or datastore                       | Rate limiting (app level), DynamoDB on-demand, health/ready endpoints      |
| T6        | Elevation of Privilege    | Compromised container gains host or broader AWS rights   | Non-root UID 10001, least-privilege IAM (no `*`), minimal base image       |

## Key design decisions that reduce risk

- Multi-stage Dockerfile → smaller attack surface
- Pipeline fails hard on CRITICAL findings and on any secret
- IAM policies are resource-specific; wildcards are forbidden unless justified in writing
- All secrets live in Secrets Manager; rotation is documented
