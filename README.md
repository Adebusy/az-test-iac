# az-test-iac
azure test on infrastructure as code

This terraform configuration files creates an Ubuntu enviroment on azure based on the variables in variables.tf file, downloads and install docker on the server, then clone a project written in Golang on Github, build the project, and runs the project on port 8060 

To run this terraform iac, follow the below steps

(1) login to your azure subscription :az login
(2) run command "terraform init" to download the azure packages for terraform
(3) run command "terraform plan" to create an execution plan,
(4) run command "terraform apply" to provision the environment on azure
