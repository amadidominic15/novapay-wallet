# Incident Runbook – Suspected Unauthorized Access to the Wallet Database

**Scenario**: Alert or log indicates possible unauthorized access to the DynamoDB wallets table.

## 1. Detection (0–5 min)

- Confirm the alert source (Prometheus rule, log anomaly, or security tool).
- Capture the exact time window, principal, and actions observed.
- Note any correlated spikes in `novapay_wallet_requests_total{status=~"5.."}`.

## 2. Immediate containment (5–15 min)

1. Disable or revoke the compromised IAM role / temporary credentials.
2. Rotate the Secrets Manager secret:
   ```bash
   # LocalStack example
   awslocal secretsmanager put-secret-value \
     --secret-id novapay-wallet/db-credentials \
     --secret-string '{"username":"novapay_app","password":"<new-random>"}'
   ```
3. Force a new deployment of the wallet service so it reloads the secret.
4. If a source IP is known, tighten the security-group ingress rules.

## 3. Investigation (15–60 min)

- Snapshot the DynamoDB table for forensics.
- Review access logs / CloudTrail equivalent for the window of compromise.
- Identify which wallets (if any) were accessed and whether balances changed.
- Check whether any other secrets or roles were used by the same principal.

## 4. Eradication & recovery

- Confirm the root cause (compromised key, overly broad policy, etc.).
- Rotate all related credentials.
- Re-enable the service with the new secret and tightened policies.
- Verify `/health` and `/ready` return 200 and that metrics look normal.

## 5. Post-incident (within 24 h)

- Update this runbook with any new lessons learned.
- Add or tighten alerting rules if gaps were found.
- Notify the compliance / CBN contact if personal data was exposed (NDPA 2023).
- Schedule a blameless post-mortem.

## Contacts (fill in for production)

- On-call DevOps: …
- Security / IR: …
- Compliance / CBN liaison: …
