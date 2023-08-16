### Common Variables ###
resource_group_name = "DSC-PrivateGPT-Dev"
location            = "uksouth"
tags = {
  Terraform   = "True"
  Description = "Private ChatGPT hosted on Azure OpenAI"
  Enviornment = "Development"
  Author      = "Marcel Lupo"
  GitHub      = "https://github.com/Pwd9000-ML/terraform-azurerm-openai-private-chatgpt"
}

### OpenAI Service Module Inputs ###
kv_config = {
  name = "gptkvdev1000"
  sku  = "standard"
}
keyvault_firewall_default_action             = "Deny"
keyvault_firewall_bypass                     = "AzureServices"
keyvault_firewall_allowed_ips                = ["0.0.0.0/0"] #for testing purposes only - allow all IPs
keyvault_firewall_virtual_network_subnet_ids = []

### Create OpenAI Service ###
create_openai_service                     = true
openai_account_name                       = "gptdev1000"
openai_custom_subdomain_name              = "gptdev1000" #translates to "https://gptdev1000.openai.azure.com/"
openai_sku_name                           = "S0"
openai_local_auth_enabled                 = true
openai_outbound_network_access_restricted = false
openai_public_network_access_enabled      = true
openai_identity = {
  type = "SystemAssigned"
}

### Create Model deployment ###
create_model_deployment = true
model_deployment = [
  {
    deployment_id  = "gpt35turbo16k"
    model_name     = "gpt-35-turbo-16k"
    model_format   = "OpenAI"
    model_version  = "0613"
    scale_type     = "Standard"
    scale_capacity = 8
  } #,
  # {
  #   deployment_id  = "gpt35turbo"
  #   model_name     = "gpt-35-turbo"
  #   model_format   = "OpenAI"
  #   model_version  = "0613"
  #   scale_type     = "Standard"
  #   scale_capacity = 34 # 34K == Roughly 204 RPM (Requests per minute)
  # },
  # {
  #   deployment_id  = "gpt4"
  #   model_name     = "gpt-4"
  #   model_format   = "OpenAI"
  #   model_version  = "0613"
  #   scale_type     = "Standard"
  #   scale_capacity = 16
  # },
  #{
  #  deployment_id  = "gpt432k"
  #  model_name     = "gpt-4-32k"
  #  model_format   = "OpenAI"
  #  model_version  = "0613"
  #  scale_type     = "Standard"
  #  scale_capacity = 5
  #}
]

### log analytics workspace for container apps ###
laws_name              = "gptlawsdev1000"
laws_sku               = "PerGB2018"
laws_retention_in_days = 30

### Container App Enviornment ###
cae_name = "gptcaedev1000"

### Container App ###
ca_name          = "gptcadev1000"
ca_revision_mode = "Single"
ca_identity = {
  type = "SystemAssigned"
}
ca_ingress = {
  allow_insecure_connections = false
  external_enabled           = true
  target_port                = 3000
  transport                  = "auto"
  traffic_weight = {
    latest_revision = true
    percentage      = 100
  }
}
ca_container_config = {
  name         = "gpt-chatbot-ui"
  image        = "ghcr.io/pwd9000-ml/chatbot-ui:main"
  cpu          = 1     #2
  memory       = "2Gi" #"4Gi"
  min_replicas = 0
  max_replicas = 5

  ## Environment Variables (Required)##
  env = [
    {
      name        = "OPENAI_API_KEY"
      secret_name = "openai-api-key" #see locals.tf (Can also be added from key vault created by module, or existing key)
    },
    {
      name        = "OPENAI_API_HOST"
      secret_name = "openai-api-host" #see locals.tf (Can also be added from key vault created by module, or existing host/endpoint)
    },
    {
      name  = "OPENAI_API_TYPE"
      value = "azure"
    },
    {
      name  = "AZURE_DEPLOYMENT_ID" #see model_deployment variable (deployment_id)
      value = "gpt35turbo16k"       #"gpt432k"
    },
    {
      name  = "DEFAULT_MODEL"    #see model_deployment variable (model_name)
      value = "gpt-35-turbo-16k" #"gpt-4-32k"
    }
  ]
}

### key vault access ###
key_vault_access_permission = ["Key Vault Secrets User"]

### CDN - Front Door ###
create_front_door_cdn   = false