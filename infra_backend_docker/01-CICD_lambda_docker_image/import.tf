# Connessione a github (la connessione deve essere già disponibile per questa region)
data "aws_codestarconnections_connection" "example" {
  name = var.github_connection_name
}