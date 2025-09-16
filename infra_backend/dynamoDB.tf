#######################################################################################
# DYNAMO DB
#######################################################################################

resource "aws_dynamodb_table" "ListOfUsers" {
  name           = "ListOfUsers"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "employeeid"

  attribute {
    name = "employeeid"
    type = "S"
  }

  tags = local.tags
}