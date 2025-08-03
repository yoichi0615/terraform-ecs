data "aws_route53_zone" "main" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_route53_record" "main" {
  for_each = var.records

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [1] : []
    content {
      name                   = each.value.alias.name
      zone_id                = each.value.alias.zone_id
      evaluate_target_health = each.value.alias.evaluate_target_health
    }
  }
}
