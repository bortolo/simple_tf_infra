
# Questo funziona solo per HTTP o alias interni Route 53.
# Se vuoi HTTPS con root + www → serve CloudFront con certificato ACM e redirect integrato.

# Se vuoi, posso scriverti un esempio completo Terraform che:

# Crea bucket SPA (www) con index + error document

# Crea bucket redirect (root) per il dominio apex

# Crea record Route 53 alias corretti per root + www

# In questo modo eviti NXDOMAIN, 404 e puoi eventualmente aggiungere CloudFront per HTTPS.


# Perchè serve questa root_redirect?
# La tua hosted zone per andreabortolossi.it esiste, e il record www.andreabortolossi.it punta al bucket → funziona.
# Ma il record per il dominio apex/root (andreabortolossi.it) non esiste → quindi nslookup andreabortolossi.it non restituisce nulla.
# Di conseguenza, se qualcuno digita andreabortolossi.it senza www, otterrà NXDOMAIN.
# resource "aws_route53_record" "root_redirect" {
#   zone_id = data.aws_route53_zone.my_zone.zone_id
#   name    = "andreabortolossi.it"
#   type    = "A"

#   alias {
#     name                   = "${var.bucket_name}.${aws_s3_bucket_website_configuration.spa_conf.website_domain}"
#     zone_id                = "Z21DNDUVLTQW6Q"
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.my_zone.zone_id
#   name    = "www.${var.my_site_url}"
#   type    = "A"

#   alias {
#     name                   = "${var.bucket_name}.${aws_s3_bucket_website_configuration.spa_conf.website_domain}"
#     zone_id                = "Z21DNDUVLTQW6Q" #Zone id per eu-central-1 https://docs.aws.amazon.com/general/latest/gr/s3.html
#     evaluate_target_health = false
#   }
# }

# Bucket redirect per root
resource "aws_s3_bucket" "root_redirect" {
  bucket = var.my_site_url
}

resource "aws_s3_bucket_website_configuration" "root_redirect_website" {
  bucket = aws_s3_bucket.root_redirect.id

  redirect_all_requests_to {
    host_name = "www.${var.my_site_url}"
    protocol  = "http"
  }
}

# Route53 record www → bucket SPA
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = "${var.bucket_name}.${aws_s3_bucket_website_configuration.spa_conf.website_domain}"
    zone_id                = "Z21DNDUVLTQW6Q"  # hosted zone ID S3 website eu-central-1
    evaluate_target_health = false
  }
}

# Route53 record root → bucket redirect
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = var.my_site_url
  type    = "A"

  alias {
    name                   = "${var.my_site_url}.${aws_s3_bucket_website_configuration.spa_conf.website_domain}"
    zone_id                = "Z21DNDUVLTQW6Q"
    evaluate_target_health = false
  }
}