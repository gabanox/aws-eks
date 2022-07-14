#!/bin/bash
# Add AWS account number as envvar
export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query 'Account' --output text)
# Create an IAM OIDC (Open ID Connect) provider
eksctl utils associate-iam-oidc-provider --region $2 --cluster $1 --approve
# Download the IAM policy for the ALB Ingress Controller pod
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.2/docs/install/iam_policy.json
# Create an IAM policy called ALBIngressControllerIAMPolicy
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
# Create a Kubernetes service account named aws-load-balancer-controller in the kube-system namespace for the AWS Load Balancer Controller and annotate the Kubernetes service account with the name of the IAM role.
eksctl create iamserviceaccount --cluster=$1 --namespace=kube-system --name=aws-load-balancer-controller --role-name "AmazonEKSLoadBalancerControllerRole" --attach-policy-arn=arn:aws:iam::$ACCOUNT_NUMBER:policy/AWSLoadBalancerControllerIAMPolicy --approve
sleep 5
# Add helm eks-charts repository
helm repo add eks https://aws.github.io/eks-charts
# helm update
helm repo update
# Install the AWS Load Balancer Controller.
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$1 --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller 

## Reference: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
