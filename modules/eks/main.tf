/**
* # EKS Module
*
* ## Additional details
*
* <b>Detail 1: Creating the Amazon EKS cluster role</b>
*
* This [link](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role) has a sample CloudFormation script that was easy to convert to Terraform
*
* <b>Detail 2: Manual part of setup</b>
*
* This is the [link](https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#add-existing-clusterhttps://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#add-existing-cluster) specifying how to add a cluster to GitLab
*
* Steps
*
* 1. This [link](https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html) details how to configure kubectl so that you can connect to an Amazon EKS cluster. Run the following command to add the context to `.kube\config`. If `aws configure` wasn't used to set the region, use the `--region` flag in the command below. Use the name of the EKS cluster that was created
* ```bash
* aws eks update-kubeconfig --name gitlab
* <<'OUTPUT'
*   Added new context arn:aws:eks:ap-southeast-1:<AWS_ACCOUNT_ID>:cluster/gitlab to C:\Users\<OS_USER>\.kube\config
*
* OUTPUT
* ```
* 2. Run the following to execute the yaml file provided
* ```bash
* kubectl apply -f gitlab-admin-service-account.yaml
* <<'OUTPUT'
*   serviceaccount/gitlab-admin created
*   clusterrolebinding.rbac.authorization.k8s.io/gitlab-admin created
*
* OUTPUT
* ```
* 3. Run the following command. Note that it does not work in a Windows command prompt
* ```bash
* kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-admin | awk '{print $1}')
* <<'OUTPUT'
* Name:         gitlab-admin-token-sxpsp
* Namespace:    kube-system
* Labels:       <none>
* Annotations:  kubernetes.io/service-account.name: gitlab-admin
*               kubernetes.io/service-account.uid: 9190e371-3d5b-4c41-9713-6af39b08ead8
*
* Type:  kubernetes.io/service-account-token
*
* Data
* ====
* namespace:  11 bytes
* token:      REDACTED_TOKEN
* ca.crt:     1025 bytes
*
* OUTPUT
* ```
*
* 4. Run the following commands to get the CA certificate. Be sure to enter the full details into GitLab including the `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----` part
* ```bash
* kubectl get secrets
* <<'OUTPUT'
* NAME                  TYPE                                  DATA   AGE
* default-token-hqn4r   kubernetes.io/service-account-token   3      77m
*
* OUTPUT
*
* kubectl get secret <secret name> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
* <<'OUTPUT'
* -----BEGIN CERTIFICATE-----
* REDACTED CERTIFICATE DETAILS
* -----END CERTIFICATE-----
*
* OUTPUT
* ```
*
* To simplify the above, I created a helper script `utility.sh`. Remember to make the file executable with `chmod +x utility.sh`
*
*/

data "aws_iam_policy" "this" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "this" {
  name               = "eksClusterRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.this.arn
}

resource "aws_eks_cluster" "this" {
  name     = "gitlab"
  role_arn = aws_iam_role.this.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.this
  ]
}