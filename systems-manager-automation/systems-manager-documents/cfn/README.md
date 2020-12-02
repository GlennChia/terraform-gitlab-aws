# 1. SSM documents

| SSM Document Name | Description                                                  | Remarks                                                      |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| iam-cfn.yaml      | 1. Creates a CloudFormation Stack which deploys an IAM instance profile<br />2. It retrieves the output of the stack which is the instance profile ARN<br />3. Finally, it deletes the stack | Additional steps can be inserted anywhere between that makes use of the IAM instance profile ARN |

