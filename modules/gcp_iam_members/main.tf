locals {
  member_types = {
    "user"           = var.users
    "group"          = var.groups
    "serviceAccount" = var.serviceAccounts
    "domain"         = var.domains
  }

  all_principals = flatten([
    for member_type, principals in local.member_types : [
      for principal in principals : "${member_type}:${principal}"
    ]
  ])

  member_role_pairs = flatten([
    for principal in local.all_principals : [
      for index, role_with_condition in var.roles_with_conditions : {
        principal             = principal
        role                  = role_with_condition.role
        condition_title       = role_with_condition.condition_title
        condition_expression  = role_with_condition.condition_expression
      }
    ]
  ])
}

resource "google_project_iam_member" "iam_member" {
  for_each = {
    for index, member_role_pair in local.member_role_pairs : index => member_role_pair
  }
  project = var.project_id

  role = each.value.role
  member  = each.value.principal

  dynamic "condition" {
    for_each = try(each.value.condition_expression, null) != null ? { "condition" = each.value } : {}
    content {
      title       = "${each.value.condition_title}-${substr(sha256("${jsonencode(local.all_principals)}${each.value.condition_expression}"), 0 , 7)}"
      expression  = each.value.condition_expression
    }
  }
}
