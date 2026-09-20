output "vpc_id" {
  value = aws_vpc.main.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.wallets.name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "compute_instance_id" {
  value = aws_instance.wallet.id
}
