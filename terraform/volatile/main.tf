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

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.eks-vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.eks-subnet-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.eks-subnet-2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "eks-subnet-1" {
  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks-subnet-2" {
  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
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

resource "aws_iam_role" "node-group-role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_eks_node_group" "node_group" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  node_role_arn = aws_iam_role.node-group-role.arn
  subnet_ids = [
    aws_subnet.eks-subnet-1.id,
    aws_subnet.eks-subnet-2.id
  ]

  instance_types = ["t3.small"]
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }
}
