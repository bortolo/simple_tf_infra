data "aws_route53_zone" "my_zone" {
  name         = "${var.my_site_url}."
  private_zone = false
}
