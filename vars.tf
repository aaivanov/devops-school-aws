variable "access_keys" {
  type = object({
    access_key_id = string
    Secret_access_key = string
  })
}


variable "settings" {
  type = object({
    region = string
    tag_prefix = string
    ami = string
    instance_type = string
    vpc =  object({
      cidr_block = string
    })
    subnet = object ({
      cidr_block_a = string
      cidr_block_b = string   
    })
  })
}

