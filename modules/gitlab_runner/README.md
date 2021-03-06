# GitLab Runner Module

## Issues and fixes

<b>Issue 1: Getting a token for a shared runner</b>

The documentation did not specify where to get a shared runner token. After clicking around, it is Admin area -> Overview -> Runners -> Set up Shared Runner manually -> Grab token from here

<b>Issue 2: `status=couldn't execute POST against` reason is `dial tcp 52.221.35.242:80: i/o timeout`</b>

Solution: use the Docker version for registering runners [here](https://docs.gitlab.com/runner/register/index.html#docker)

## Additional details

For a one liner to install the runners

```bash
sudo gitlab-runner register \
  --non-interactive \
  --url "GITLAB_URL" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --executor "docker+machine" \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --tag-list "docker,aws" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_security\_group\_id | The id of the bastion security group | `string` | n/a | yes |
| http\_ingress\_security\_group\_id | The id of the security group allows to hit HTTP endpoint | `string` | n/a | yes |
| instance\_type | Instance type for the GitLab runner | `string` | `"t2.micro"` | no |
| key\_name | The key name of a key that has already been created that will be attached to the GitLab Runner instance | `string` | n/a | yes |
| subnet\_id | Private subnet id | `string` | n/a | yes |
| vpc\_id | The id of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_id | The id of the security group associated with the gitlab runner |

