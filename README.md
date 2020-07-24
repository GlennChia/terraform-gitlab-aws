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

