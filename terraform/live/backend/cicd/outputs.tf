################################################################################
# Backend CI/CD
################################################################################
output "appspec" {
  value = [for codedeploy in module.codedeploy.appspec : codedeploy.appspec]
}
