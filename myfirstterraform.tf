provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "terraferic" {
  ami = "ami-4f55e332"

  #ami           = "ami-bf17a1c2"
  instance_type = "t2.micro"
  count         = 1

  tags {
    Name = "TerrifEric One"
    Env  = "Test"
  }
}
