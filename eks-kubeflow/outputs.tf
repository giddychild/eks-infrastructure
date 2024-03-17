output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

# output "wg_security_group_id" {
#   description = "The ID of the security group"
#   value       = resource.aws_security_group.wireguard_sg.id
# }
