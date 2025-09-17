#######################################################################################
# CODEDEPLOY
#######################################################################################

resource "aws_codedeploy_app" "foo_app" {
  compute_platform = "Server"
  name             = var.application_name
}

/*resource "aws_codedeploy_deployment_config" "foo" {
  deployment_config_name = "test-deployment-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 2
  }
}*/

resource "aws_codedeploy_deployment_group" "foo" {
  app_name               = aws_codedeploy_app.foo_app.name
  deployment_group_name  = "TaggedEC2Instances"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  #deployment_config_name = aws_codedeploy_deployment_config.foo.id

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "npv_web_app"
  }

}