data "aws_route53_zone" "my_zone" {
  name         = "andreabortolossi.it"  # deve terminare con il punto finale
  private_zone = false
}

resource "aws_route53_record" "my_record" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "npv.andreabortolossi.it"     # sottodominio che vuoi associare
  type    = "A"
  ttl     = 300
  records = [module.webserver.public_ip]
}
