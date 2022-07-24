# EKS lab and test environment setup

Create an EKS environmet for testing and development

This repository contains the instructions to deploy a simple *Kubernetes* environment on **EKS** and manage it with **Cloud9**. The resources that will created are:

- Cloud9 IDE
- IAM instance profile, IAM role and an IAM policy
- 2 worker nodes EKS cluster

1. Open a console with **AWS CLI** preinstalled on launch a **CloudShell** console.

1. First add as an environment variable the EKS environment name you would like to use (e.g. env1). Replace with your desired EKS environment name.

    ```sh
    export envName=<my-env-name>
    ```

1. Run this command from a CLI console (e.g. CloudShell) to run a CloudFormation template which will create a **Cloud9** development environment.

    ```sh
    aws cloudformation create-stack --stack-name $envName --template-url https://ee-assets-prod-us-east-1.s3.amazonaws.com/modules/b2712516c3c24d58a606eecfb837cb1e/v1/eks-work-env.template --capabilities CAPABILITY_IAM
    ```

1. Wait until deployment has a `CREATE_COMPLETE` state. Run this command to confirm the deployment status.

    ```sh
    aws cloudformation describe-stacks --stack-name $envName  --query 'Stacks[*].StackStatus' --output text
    ```

1. Run the below command to attach an IAM instance profile to the **Cloud9** environment instance and disable temporary credentials.

    ```sh
    curl https://raw.githubusercontent.com/gcanales75/eks-work-env/main/setIamPermissions.sh > setIamPermissions.sh
    chmod +x setIamPermissions.sh
    ./setIamPermissions.sh $envName

    ```

1. You must see this string in the stdout: `"State": "associating"`.

1. Go to Cloud9 console and select **Open IDE** on your environment. Once logged in into the console clone the repo with the setup scripts

    ```sh
    git clone https://github.com/gcanales75/eks-work-env.git
    ```

1. Running the below command will run a script that will install the following software and libraries:

    - python 3.8
    - pip
    - Upgrade aws cli
    - kubectl
    - aws-iam-authenticator
    - eksctl
    - helm

    ```sh
    cd eks-work-env/
    chmod +x cloud9setup.sh
    ./cloud9setup.sh

    ```

1. Now you will create your EKS cluster, but first add as an environment variable the EKS cluster name you would like to use (e.g. eks-lab-cluster). Replace <cluster-name> with your desired EKS cluster name.

    ```sh
    export clusterName=<cluster-name>
    ```

1. Also add as an env variable the region you are working on.

    ```sh
    export AWS_REGION=<my-aws-region-code>
    ```

1. Run this command to create a 2 nodes EKS cluster, using `t3.medium` instance type. If you would like to change the cluster configuration you can update `eksctl-spinup-cluster.sh` file.

    ```sh
    chmod +x eksctl-spinup-cluster.sh
    ./eksctl-spinup-cluster.sh $clusterName $AWS_REGION
    ```

    Cluster will take 15-20 minutes to fully deploy, do not interrupt the script execution. If you see an error message take a look at the CloudFormation template error messages, you may have reached a VPC limit in your region. You could either delete an unused VPC o select a different region for your cluster deployment.

1. Once finished the command execution, run this command to confirm the cluster status

    ```sh
    aws eks describe-cluster --name $clusterName --region $AWS_REGION --query 'cluster.status' --output text 
    ```

    Wait until the cluster status is `ACTIVE` state to proceed with the following step

1. Now you can authenticate

    ```sh
    aws eks update-kubeconfig --region $AWS_REGION --name $clusterName
    ````

1. If you see this error message during your building activities, just re-run the previous command

    ```
    Unable to connect to the server: getting credentials: decoding stdout: no kind "ExecCredential" is registered for version "client.authentication.k8s.io/v1alpha1" in scheme "pkg/client/auth/exec/exec.go:62"
    ```

1. Run this command to confirm your **Cloud9** environment can communicate with the EKS cluster

    ```sh
    kubectl get svc
    ```

    You must see a similar output:

    ```
    NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   16m
    ```

For more info go to:

- [eksctl](https://eksctl.io/)
- [Creating an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
- Kubernetes [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Happy building!