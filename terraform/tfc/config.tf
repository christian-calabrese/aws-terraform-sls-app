terraform {

  cloud {}

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "= 0.40.0"
    }
  }

}

provider "tfe" {
  token = var.tfe_token
}
