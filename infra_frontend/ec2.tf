#######################################################################################
# EC2
#######################################################################################

resource "aws_key_pair" "this" {
  key_name   = "ec2-key-pair"
  public_key = file("./resources/id_rsa.pub")
  tags = local.tags
}

module "webserver" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "webserver"
  ami                         = "ami-0e6a13e7a5b66ff4d" #Amazon Linux 2
  instance_type               = "t2.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group_web.security_group_id]
  associate_public_ip_address = true
  key_name                    = "ec2-key-pair"

  user_data_base64            = base64encode(file("./resources/userdata_apache.txt"))
  user_data_replace_on_change = true

  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name


  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = false
      volume_type = "gp2"
      volume_size = 8
      tags = {
        Name = "my-root-block"
      }
    },
  ]

    tags = local.tags

}