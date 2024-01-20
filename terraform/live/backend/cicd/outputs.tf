################################################################################
# Backend CI/CD
################################################################################
output "appspec" {
  value = [for codedeploy in module.deploy.appspec : codedeploy.appspec]
}
