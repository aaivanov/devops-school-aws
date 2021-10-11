settings = {
  "region" = "eu-central-1"
  "tag_prefix" = "Prod"
  "instance_type" = "t2.micro"
  "ami" = "ami-05f7491af5eef733a"
  "instance_min_count" = "2"
  "vpc" = {
    "cidr_block" = "10.23.0.0/16"
  }
  "subnet" = {
     "cidr_block_a" = "10.23.1.0/24"
     "cidr_block_b" = "10.23.2.0/24"
     "cidr_block_c" = "10.23.3.0/24"
   }
}
