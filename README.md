# terraform-aws-nodejs-ecs-fargate-sample
Sample Terraform project to provision a simple dockerized nodejs webapp via ECS Fargate using an ALB

This project assumes a linux-based workspace is used.

## Project Goals
- [X]  Infrastructure and the resources should be provisioned using Terraform
- [ ]  The web app should be accessible by WAN using HTTP port (80) and return a “Hello, world!” page.
- [X]  The web app should be Dockerized. Meaning that it can be run locally using docker and accessible via localhost:80
- [X]  Web app should be deployed to AWS ECS (Fargate). There should be at least 2 instances of this app.
- [ ]  There should be ALB sitting on top of the web app.
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
`docker run -p 80:8080 -d <tagname>`

# Provisioning on AWS
Initialize the work directory:  
`$ terraform init`

Preview changes to be applied:  
`$ terraform plan`

Apply actions from plan:  
`$ terraform apply`

Tear down configured remote objects and/or resources:    
`$ terraform destroy`

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)