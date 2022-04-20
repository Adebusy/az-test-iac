variable "Deployment" {
  type    = string
  default = "testdeploy"
}

variable "RG_Name" {
  type    = string
  default = "test_RG"
}

variable "RG_Location" {
  type    = string
  default = "West Europe"
}

variable "VN_name" {
  type    = string
  default = "test_VN"
}

variable "SN_name" {
  type    = string
  default = "testsubnet"
}

variable "VN_address_space" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "VN_subnet" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "test_NIC" {
  type    = string
  default = "test_NIC"
}

variable "VM_Name" {
  type    = string
  default = "vm-test-server"
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}

variable "admin_password" {
  type    = string
  default = "P@55w0rd"
}

variable "network_SG" {
  type    = string
  default = "myNetworkSecurityGroup"
}
