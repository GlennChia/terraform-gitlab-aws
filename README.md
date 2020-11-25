# Terraform GitLab on AWS

# 1. Installations

## 1.1 Windows

Terraform Guide

- [Installation Link](https://learn.hashicorp.com/terraform/getting-started/install)
- Click the "Chocolatey on Windows" tab. Manual installation did not work for me
- Make sure to run as Administrator using Command Prompt

Chocolaty install

- [Installation link](https://chocolatey.org/install#install-step1)
- Install in PowerShell. Run as Administrator

Install terraform-docs

- Use Chocolaty to install. Run on Command Prompt. [Link](https://github.com/terraform-docs/terraform-docs)

  ```bash
  choco install terraform-docs
  ```


# 2. Instructions

1. Run `terraform init` in each environment's folder
2. Run `terraform get` in the environment's folder to register the local modules
3. Run `terraform validate` to check for syntax errors. Run `terraform fmt` to format code
4. Run `terraform plan` to understand the changes made
5. Run `terraform apply -var-file="terraform.tfvars"` to run with the variables file (Create this file based on `terraform.template.tfvars` provided)
Note: If we want to skip the prompt do `terraform apply -var-file="terraform.tfvars" -auto-approve`
Note: If we want to target only certain resources, we can do `terraform apply -var-file="terraform.tfvars" -target module.eks`
6. Run `terraform destroy` after deployment if used for testing

# 3. Directory Structure and best practices

The following links were used to provide guidance on the Directory Structure

- [Medium: Using Terraform at a Production Level](https://medium.com/@njfix6/using-terraform-at-a-production-level-ec1705a19d82)
- [Terraform docs: Creating Modules](https://www.terraform.io/docs/modules/index.html)
- [GitHub repo: Large-size infrastructure using Terraform](https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/large-terraform)

Best practices for naming conventions

- [Terraform docs: Naming conventions](https://www.terraform-best-practices.com/naming)

Code Styling

- [Terraform docs: Code styling](https://www.terraform-best-practices.com/code-styling)
- [GitHub: terraform-docs](https://github.com/terraform-docs/terraform-docs)
- [Article: Automatic Terraform documentation with terraform-docs](https://www.unixdaemon.net/cloud/automatic-terraform-documentation-with-terraform-docs/)
- Run `terraform-docs markdown . > README.md` to generate documentation
- For the main file I use `terraform-docs markdown . --no-providers > README.md` because somehow my provider was showing up in requirements instead
- For modules I use `terraform-docs markdown . --no-providers --no-requirements  > README.md`

Using modules

- [How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/@brikis98?source=post_page-----25526d65f73d----------------------)

# 4. Interesting bash tips

**Getting part of the output of a command in bash**

Refer to this [link](https://stackoverflow.com/questions/25116521/how-do-i-get-a-part-of-the-output-of-a-command-in-linux-bash)

Example: This command refers to the first output of the second line

```bash
kubectl get secrets | awk 'NR==2{print $1}'
```

**Storing the output of a command in bash in a variable to be referenced elsewhere in a bash file**

Refer to this [link](https://www.tecmint.com/assign-linux-command-output-to-variable/#:~:text=shell%20scripting%20purpose.-,To%20store%20the%20output%20of%20a%20command%20in%20a%20variable,command%20%5Boption%20...%5D)

Example

```bash
token_name=$(kubectl get secrets | awk 'NR==2{print $1}')
```

# 5. Install GitLab runners using EKS via helm

Make sure to have `kubectl` and `helm` installed

- For Windows

  1. Kubectl: [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/). Download the executable and add it to the path

  2. Helm: [Install Helm](https://helm.sh/docs/intro/install/)

     ```bash
     choco install kubernetes-helm
     ```

Configure according to: [GitLab Runner Helm Chart](https://docs.gitlab.com/runner/install/kubernetes.html)

- Clone the [gitlab-runner repo](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/tree/master)
- Follow the GitLab documents for configuring values.yaml. Note: I had some issues with a custom service account. Hence, I enabled RBAC and let EKS handle the service account

To pull a runner image from ECR

- Download the Gitlab runner alpine image from [gitlab/gitlab-runner](https://hub.docker.com/r/gitlab/gitlab-runner/tags). Note: This must be alpine to avoid the error of `PANIC: mkdir /nonexistent: permission denied` after the `helm install` as elaborated below

  ```bash
  docker pull gitlab/gitlab-runner:alpine
  ```

- Then push the runner image to ECR. Replace <image_id> (Get this using `docker image ls`), <aws_account_id>, <ecr_repo_name>

  ```bash
  # Run with sudo privileges
  /usr/local/bin/aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.ap-southeast-1.amazonaws.com
  # Tag the image
  docker tag <image_id> <aws_account_id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ecr_repo_name>
  # Push to ECR
  docker push <aws_account_id>.dkr.ecr.ap-southeast-1.amazonaws.com/<ecr_repo_name>
  ```

Helm and kubectl commands to install

```bash
helm repo add gitlab https://charts.gitlab.io

# Helm install based on values.yaml
helm install --namespace gitlab-managed-apps gitlab-runner -f ./values.yaml gitlab/gitlab-runner
# ============
# Exmple Output
# NAME: gitlab-runner
# LAST DEPLOYED: Wed Oct 21 10:55:19 2020
# NAMESPACE: gitlab-managed-apps
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
# NOTES:
# Your GitLab Runner should now be registered against the GitLab instance reachable at: "http://<loadbalancer_dns_name>.ap-southeast-1.elb.amazonaws.com/"
# ============

# View the status of the pods
kubectl get pods --namespace gitlab-managed-apps
# ============
# Exmple Output
# NAME                                           READY   STATUS    RESTARTS   AGE
# gitlab-runner-gitlab-runner-5794d87676-5rlfr   1/1     Running   0          43m
# ============

# View the logs for the specific pod
kubectl logs gitlab-runner-gitlab-runner-5794d87676-5rlfr --namespace gitlab-managed-apps
```

Helpful Helm and Kubectl commands

```bash
# Get the helm install status
helm status gitlab-runner --namespace gitlab-managed-apps

# Get the service accounts that were created
kubectl get serviceaccounts --namespace gitlab-managed-apps

# If the pods have errors we can helm uninstill, edit values.yaml and then helm install again
helm uninstall gitlab-runner --namespace gitlab-managed-apps
```

To fix the `PANIC: mkdir /nonexistent: permission denied` after the `helm install`

- This GitLab issue fixed it. [Document how to use the ubuntu image with the helm chart](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/issues/97)

- Essentially there are 2 steps

  1. Download the gitlab-runner alpine image

  2. Change the `securityContext` in the values.yaml file

     ```yaml
     securityContext:
       fsGroup: 999
       runAsUser: 999
     ```

<u>**Granting permissions to run the commands on the cluster to an IAM role**</u>

Useful link: [How do I resolve an unauthorized server error when I connect to the Amazon EKS API server?](https://aws.amazon.com/premiumsupport/knowledge-center/eks-api-server-unauthorized-error/)

After updating the AWS credentials to the account that created the cluster, run the following command (replace `<eks_cluster_name>`)

```bash
aws eks update-kubeconfig --name <eks_cluster_name>
kubectl edit configmap aws-auth -n kube-system
```

This brings up the following default file

```bash
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::123456789123:role/<role_name>
      username: system:node:{{EC2PrivateDNSName}}
kind: ConfigMap
metadata:
  creationTimestamp: "2020-10-21T09:08:51Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "7459"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: 
```

Then if we want to add a role, for example `arn:aws:iam::123456789123:role/<role_name2>`

```bash
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::123456789123:role/<role_name1>
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::123456789123:role/<role_name2>
      username: testrole
      groups:
        - system:masters
kind: ConfigMap
metadata:
  creationTimestamp: "2020-10-21T09:08:51Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "228046"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: 
```

Verify that the update is correct

```bash
kubectl describe configmap -n kube-system aws-auth
```
