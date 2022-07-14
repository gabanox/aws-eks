EKS Cluster auth
aws eks update-kubeconfig \
 --region $AWS_REGION \
 --name <cluster-name>

Describe cluster status
aws eks describe-cluster \
 --name <cluster-name> \
 --query 'cluster.status' \
 --output text

Confirm auth
kubectl get svc

Create ECR repo
aws ecr create-repository \
 --repository-name <repo-name> \
 --region us-west-2

Auth to ECR
aws ecr get-login-password \
--region $AWS_DEFAULT_REGION \
 | docker login \
 --username AWS \
 --password-stdin $ACCOUNT_NUMBER.dkr.ecr.us-west-2.amazonaws.com

Tag and push
docker tag website:latest $ECR_REPO_URI:latest
docker push $ECR_REPO_URI:latest

