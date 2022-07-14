# EKS lab and test environment setup

Create an EKS environmet for testing and development

1. First add as an environment variable the EKS environment name you would like to use (e.g. env1). Replace with your desired EKS environment name.

    ```sh
    export envName=<my-env-name>
    ```

1. Run this command from a CLI console (e.g. CloudShell).

    ```sh
    aws cloudformation create-stack --stack-name $envName --template-url https://ee-assets-prod-us-east-1.s3.amazonaws.com/modules/b2712516c3c24d58a606eecfb837cb1e/v1/eks-work-env.template --capabilities CAPABILITY_IAM
    ```

1. Wait until deployment has a completed state. Run this command to confirm the deployment status.

    ```sh
    aws cloudformation describe-stacks --stack-name $envName  --query 'Stacks[*].StackStatus' --output text
    ```

1. Run the below command to attach an IAM instance profile to the **Cloud9** environment instance and disable temporary credentials.

    ```sh
    curl https://raw.githubusercontent.com/gcanales75/eks-work-env/main/setIamPermissions.sh > setIamPermissions.sh
    chmod +x setIamPermissions.sh
    ./setIamPermissions.sh $envName
    ```

1. Go to Cloud9 console and select **Open IDE** on your environment. Once logged in into the console clone the repo with the setup scripts

    ```sh
    git clone https://github.com/gcanales75/eks-work-env.git
    ```

1. Runnin the below command will run a script that will install the following software and libraries:

    - python 3.8
    - pip
    - Upgrade aws cli
    - kubectl
    - aws-iam-authenticator
    - eksctl
    - helm

    ```sh
    chmod +x cloud9setup.sh
    ./cloud9setup.sh
    ```

1. Run this command to create a 2 nodes EKS cluster, using `t3.medium` instance type. If you would like to change the cluster configuration you can update `eksctl-spinup-cluster.sh` file. Replace <cluster-name> with the desired value.

    ```sh
    chmod +x eksctl-spinup-cluster.sh
    ./eksctl-spinup-cluster.sh <cluster-name>
    ```

    Cluster will take 15-20 minutes to fully deploy.

1. Run this command to monitor cluster creation status

    ```sh
    aws eks describe-cluster --name <cluster-name> --query 'cluster.status' --output text
    ```

    Wait until the cluster status is `ACTIVE` state to proceed with the following step

1. Now you can authenticate

    ```sh
    aws eks update-kubeconfig --region us-west-2 --name <cluster-name>
    ````

1. Run this command to confirm your **Cloud9** environment can communicate with the EKS cluster

    ```sh
    kubectl get svc
    ```


Happy building!