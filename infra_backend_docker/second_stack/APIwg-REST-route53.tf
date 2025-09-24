resource "aws_route53_zone" "private" {
  name = "myapi.internal"       # nome della zona
  vpc {
    vpc_id = data.aws_vpc.selected.id
  }
}

# 2. Record CNAME che punta al DNS standard dell'API
resource "aws_route53_record" "api_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api.myapi.internal"
  type    = "CNAME"
  ttl     = 300
  records = [
    "${aws_api_gateway_rest_api.private_api.id}.execute-api.${var.aws_region}.amazonaws.com"
  ]
}


# Opzione A — Non usare custom domain (più semplice)
# Se non ti serve un nome “api.myapi.internal” esplicito, puoi usare l’URL dell’API ({api-id}.execute-api...) tramite il VPC endpoint con private_dns_enabled = true. 
# In questo caso non devi gestire certificati: TLS è gestito da AWS. 
# In questo modo però non puoi personalizzare url per il VPCendpoint e quindi ogni volta devi aggiornare url del codice frontend per fare la chiamata corretta

# Opzione B — Usa un dominio pubblico che controlli + ACM (DNS validation) — soluzione raccomandata
# Registra un dominio pubblico che controlli (es. example.com) oppure usa un subdomain che possiedi (internal.example.com).
# Richiedi un certificato ACM nella stessa regione (DNS validation) — gratuito e gestito (ACM si rinnova automaticamente).
# Crea una Private Hosted Zone in Route53 (associata alla tua VPC) per risolvere api.example.com internamente verso l'API Gateway 
# (alias verso regional_domain_name del domain resource).
# Questo evita completamente l'uso di ACM PCA.