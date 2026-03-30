output "iam_members" {
  description = "IAM members with roles and conditions for users, groups, service accounts, and domains."
  value = [
    for index, member in google_project_iam_member.iam_member : {
      role            = member.role
      condition_title = try(member.condition[0].title, null)
      condition_expr  = try(member.condition[0].expression, null)
      member          = member.member
    }
  ]
}