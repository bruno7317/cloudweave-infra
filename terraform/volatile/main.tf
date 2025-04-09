terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_iam_role" "eks-role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach-eks-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_vpc" "eks-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks-subnet-1" {
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "eks-subnet-2" {
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = "10.0.8.0/24"
  availability_zone = "${var.region}b"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "cloudweave-eks-cluster"
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks-subnet-1.id,
      aws_subnet.eks-subnet-2.id
    ]
  }
}
