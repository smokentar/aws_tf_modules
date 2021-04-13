# Terraform reusable modules v1
## Note: not production ready

### Overview

This repository consists of terraform modules that deploy a MYSQL database and a basic web cluster fronted by ALB into an AWS account.
<br />There are two branches: `master` / `staging` which are used by the Prod / Staging environment defined in [aws_tf_infra_v1](https://github.com/smokentar/aws_tf_infra_v1)

### Change management
Changes to module templates should follow a standard procedure:
1. Clone the repository locally
<br /> `git clone https://github.com/smokentar/aws_tf_modules.git`
2. Create a new branch for editing
<br /> `git checkout -b "example-edit"`
3. Create a PR to review and merge the `example-edit` branch to `staging`
4. Test the changes introduced through the Staging environment in [aws_tf_infra_v1](https://github.com/smokentar/aws_tf_infra_v1)
5. Create a PR to review and merge the `example-edit` branch to `master`
6. Delete the local and remote `example-edit` branch 
