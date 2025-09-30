resource "aws_dynamodb_table" "scenarios" {
  name           = "scenarios"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "scenarioid"

  attribute {
    name = "scenarioid"
    type = "S"
  }

  tags = local.tags
}