# terraform-aws-nodejs-ecs-fargate-sample
Sample Terraform project to provision a simple dockerized nodejs webapp via ECS Fargate using an ALB

This project assumes a linux-based workspace is used.

## Project Goals
- [X]  Infrastructure and the resources should be provisioned using Terraform
- [X]  The web app should be accessible by WAN using HTTP port (80) and return a “Hello, world!” page.
- [X]  The web app should be Dockerized. Meaning that it can be run locally using docker and accessible via localhost:80
- [X]  Web app should be deployed to AWS ECS (Fargate). There should be at least 2 instances of this app.
- [X]  There should be ALB sitting on top of the web app.
- [X]  Terraform file and web app source in the same GitHub repository

## Requirements
- [Docker](https://docs.docker.com/get-docker/) 19.03.6+
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) v1.1.3+
- An AWS Account and [profile configured via aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

# Usage
## Local Development 
### Create webapp image and run
In webapp workfolder:  
`$ cd webapp`

Build a docker image locally:  
`$ docker build -f Dockerfile . -t <tagname>`

Run an instance of the webapp image accessible on any local preferred/open port. ie 80 (http://localhost:80):
`$ docker run -p 80:8080 -d <tagname>`

# Provisioning on AWS
In tf workfolder:  
`$ cd tf`

Initialize the work directory:  
`$ terraform init`

Preview changes to be applied:  
`$ terraform plan`

Apply actions from plan:  
`$ terraform apply`

Tear down configured remote objects and/or resources:    
`$ terraform destroy`

To reach the sample service, simply go to your LoadBalancers in AWS console and open the configured `DNS name` of the provisioned ALB in your browser.

## Overriding variables and avoiding the annoying aws profile prompt:
Simply create a .tfvars file and override the `aws profile` variable: ie.  
`$ echo aws_profile = "yourprofile" > tf/secret.tfvars`

Run `terraform apply` referencing your tfvars as a var-file. ie:  
`$ terraform apply -var-file="secret.tfvars"`

The `aws_region` which is `ca-central-1` by default can also be overridden by amending the value the tfvars file.

# Potential Improvements / TODO
- [ ] Output DNS of ALB
- [ ] R&D CloudWatch for ECS logs
- [ ] Customize internal subnet (non-default allocated vpc)
- [ ] R&D ECR Lifecycle Policies
- [ ] High level Diagram

# References
- [A guide to provisioning AWS ECS Fargate using Terraform](https://dev.to/txheo/a-guide-to-provisioning-aws-ecs-fargate-using-terraform-1joo)
- [How to Deploy a Dockerised Application on AWS ECS With Terraform](https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785)
- https://github.com/KevinSeghetti/aws-terraform-ecs

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)