### common ###
variable "location" {
  type        = string
  default     = "uksouth"
  description = "Azure region where resources will be hosted."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pairs that is used to tag resources created."
}

### solution resource group ###
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create where the cognitive account OpenAI service is hosted."
  nullable    = false
}

### OpenAI service Module params ###
### key vault ###
variable "kv_config" {
  type = object({
    name = string
    sku  = string
  })
  default = {
    name = "gptkv"
    sku  = "standard"
  }
  description = "Key Vault configuration object to create azure key vault to store openai account details."
  nullable    = false
}

variable "keyvault_firewall_default_action" {
  type        = string
  default     = "Deny"
  description = "Default action for keyvault firewall rules."
}

variable "keyvault_firewall_bypass" {
  type        = string
  default     = "AzureServices"
  description = "List of keyvault firewall rules to bypass."
}

variable "keyvault_firewall_allowed_ips" {
  type        = list(string)
  default     = []
  description = "value of keyvault firewall allowed ip rules."
}

variable "keyvault_firewall_virtual_network_subnet_ids" {
  type        = list(string)
  default     = []
  description = "value of keyvault firewall allowed virtual network subnet ids."
}

### openai service ###
variable "create_openai_service" {
  type        = bool
  description = "Create the OpenAI service."
  default     = false
}

variable "openai_account_name" {
  type        = string
  description = "Name of the OpenAI service."
  default     = "demo-account"
}

variable "openai_custom_subdomain_name" {
  type        = string
  description = "The subdomain name used for token-based authentication. Changing this forces a new resource to be created. (normally the same as the account name)"
  default     = "demo-account"
}

variable "openai_sku_name" {
  type        = string
  description = "SKU name of the OpenAI service."
  default     = "S0"
}

variable "openai_local_auth_enabled" {
  type        = bool
  default     = true
  description = "Whether local authentication methods is enabled for the Cognitive Account. Defaults to `true`."
}

variable "openai_outbound_network_access_restricted" {
  type        = bool
  default     = false
  description = "Whether or not outbound network access is restricted. Defaults to `false`."
}

variable "openai_public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether or not public network access is enabled. Defaults to `false`."
}

variable "openai_identity" {
  type = object({
    type = string
  })
  default = {
    type = "SystemAssigned"
  }
  description = <<-DESCRIPTION
    type = object({
      type         = (Required) The type of the Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
      identity_ids = (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this OpenAI Account.
    })
  DESCRIPTION
}

### model deployment ###
variable "create_model_deployment" {
  type        = bool
  description = "Create the model deployment."
  default     = false
}

variable "model_deployment" {
  type = list(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    scale_type      = string
    scale_tier      = optional(string)
    scale_size      = optional(number)
    scale_family    = optional(string)
    scale_capacity  = optional(number)
    rai_policy_name = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
      type = list(object({
        deployment_id   = (Required) The name of the Cognitive Services Account `Model Deployment`. Changing this forces a new resource to be created.
        model_name = {
          model_format  = (Required) The format of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created. Possible value is OpenAI.
          model_name    = (Required) The name of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created.
          model_version = (Required) The version of Cognitive Services Account Deployment model.
        }
        scale = {
          scale_type     = (Required) Deployment scale type. Possible value is Standard. Changing this forces a new resource to be created.
          scale_tier     = (Optional) Possible values are Free, Basic, Standard, Premium, Enterprise. Changing this forces a new resource to be created.
          scale_size     = (Optional) The SKU size. When the name field is the combination of tier and some other value, this would be the standalone code. Changing this forces a new resource to be created.
          scale_family   = (Optional) If the service has different generations of hardware, for the same SKU, then that can be captured here. Changing this forces a new resource to be created.
          scale_capacity = (Optional) Tokens-per-Minute (TPM). If the SKU supports scale out/in then the capacity integer should be included. If scale out/in is not possible for the resource this may be omitted. Default value is 1. Changing this forces a new resource to be created.
        }
        rai_policy_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.
      }))
  DESCRIPTION
  nullable    = false
}

### log analytics workspace ###
variable "laws_name" {
  type        = string
  description = "Name of the log analytics workspace to create."
  default     = "gptlaws"
}

variable "laws_sku" {
  type        = string
  description = "SKU of the log analytics workspace to create."
  default     = "PerGB2018"
}

variable "laws_retention_in_days" {
  type        = number
  description = "Retention in days of the log analytics workspace to create."
  default     = 30
}

### container app environment ###
variable "cae_name" {
  type        = string
  description = "Name of the container app environment to create."
  default     = "gptcae"
}

### container app ###
variable "ca_name" {
  type        = string
  description = "Name of the container app to create."
  default     = "gptca"
}

variable "ca_revision_mode" {
  type        = string
  description = "Revision mode of the container app to create."
  default     = "Single"
}

variable "ca_identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = <<-DESCRIPTION
    type = object({
      type         = (Required) The type of the Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
      identity_ids = (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this OpenAI Account.
    })
  DESCRIPTION
}

variable "ca_ingress" {
  type = object({
    allow_insecure_connections = optional(bool)
    external_enabled           = optional(bool)
    target_port                = number
    transport                  = optional(string)
    traffic_weight = optional(object({
      percentage      = number
      latest_revision = optional(bool)
    }))
  })
  default = {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000
    transport                  = "auto"
    traffic_weight = {
      percentage      = 100
      latest_revision = true
    }
  }
  description = <<-DESCRIPTION
    type = object({
      allow_insecure_connections = (Optional) Allow insecure connections to the container app. Defaults to `false`.
      external_enabled           = (Optional) Enable external access to the container app. Defaults to `true`.
      target_port                = (Required) The port to use for the container app. Defaults to `3000`.
      transport                  = (Optional) The transport protocol to use for the container app. Defaults to `auto`.
      type = object({
        percentage      = (Required) The percentage of traffic to route to the container app. Defaults to `100`.
        latest_revision = (Optional) The percentage of traffic to route to the container app. Defaults to `true`.
      })
  DESCRIPTION
}

variable "ca_container_config" {
  type = object({
    name         = string
    image        = string
    cpu          = number
    memory       = string
    min_replicas = optional(number, 0)
    max_replicas = optional(number, 10)
    env = optional(list(object({
      name        = string
      secret_name = optional(string)
      value       = optional(string)
    })))
  })
  default = {
    name         = "gpt-chatbot-ui"
    image        = "ghcr.io/pwd9000-ml/chatbot-ui:main"
    cpu          = 1
    memory       = "2Gi"
    min_replicas = 0
    max_replicas = 10
    env          = []
  }
  description = <<-DESCRIPTION
    type = object({
      name                    = (Required) The name of the container.
      image                   = (Required) The name of the container image.
      cpu                     = (Required) The number of CPU cores to allocate to the container.
      memory                  = (Required) The amount of memory to allocate to the container in GB.
      min_replicas            = (Optional) The minimum number of replicas to run. Defaults to `0`.
      max_replicas            = (Optional) The maximum number of replicas to run. Defaults to `10`.
      env = list(object({
        name        = (Required) The name of the environment variable.
        secret_name = (Optional) The name of the secret to use for the environment variable.
        value       = (Optional) The value of the environment variable.
      }))
    })
  DESCRIPTION
}

variable "ca_secrets" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "secret1"
      value = "value1"
    },
    {
      name  = "secret2"
      value = "value2"
    }
  ]
  description = <<-DESCRIPTION
    type = list(object({
      name  = (Required) The name of the secret.
      value = (Required) The value of the secret.
    }))
  DESCRIPTION  
}

# Key Vault Access #
### key vault access ###
variable "key_vault_access_permission" {
  type        = list(string)
  default     = ["Key Vault Secrets User"]
  description = "The permission to grant the container app to the key vault. Set this variable to `null` if no Key Vault access is needed. Defaults to `Key Vault Secrets User`."
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "(Required) - The id of the key vault to grant access to."
}

# DNS zone #
variable "create_dns_zone" {
  description = "Create a DNS zone for the CDN profile. If set to false, an existing DNS zone must be provided."
  type        = bool
  default     = false
}

variable "dns_resource_group_name" {
  description = "The name of the resource group to create the DNS zone in / or where the existing zone is hosted."
  type        = string
  nullable    = false
  default     = "dns-rg"
}

variable "custom_domain_config" {
  type = object({
    zone_name = string
    host_name = string
    ttl       = optional(number, 3600)
    tls = optional(list(object({
      certificate_type    = optional(string, "ManagedCertificate")
      minimum_tls_version = optional(string, "TLS12")
    })))
  })
  default = {
    zone_name = "mydomain7335.com"
    host_name = "PrivateGPT"
    ttl       = 3600
    tls = [{
      certificate_type    = "ManagedCertificate"
      minimum_tls_version = "TLS12"
    }]
  }
  description = <<-DESCRIPTION
    type = object({
      zone_name = (Required) The name of the DNS zone to create the CNAME and TXT record in for the CDN Front Door Custom domain.
      host_name = (Required) The host name of the DNS record to create. (e.g. Contoso)
      ttl       = (Optional) The TTL of the DNS record to create. (e.g. 3600)
      tls       = optional(list(object({
        certificate_type    = (Optional) Defines the source of the SSL certificate. Possible values include 'CustomerCertificate' and 'ManagedCertificate'. Defaults to 'ManagedCertificate'.
        NOTE: It may take up to 15 minutes for the Front Door Service to validate the state and Domain ownership of the Custom Domain.
        minimum_tls_version = (Optional) TLS protocol version that will be used for Https. Possible values include TLS10 and TLS12. Defaults to TLS12.
      }))))
    })
  DESCRIPTION
}

# Front Door #
variable "create_front_door_cdn" {
  description = "Create a Front Door profile."
  type        = bool
  default     = false
}

variable "cdn_profile_name" {
  description = "The name of the CDN profile to create."
  type        = string
  default     = "example-cdn-profile"
}

variable "cdn_sku_name" {
  description = "Specifies the SKU for the CDN Front Door Profile. Possible values include 'Standard_AzureFrontDoor' and 'Premium_AzureFrontDoor'."
  type        = string
  default     = "Standard_AzureFrontDoor"
}

variable "cdn_endpoint" {
  type = object({
    name    = string
    enabled = optional(bool, true)
  })
  default = {
    name    = "PrivateGPT"
    enabled = true
  }
  description = <<DESCRIPTION
    typp = object({
      name    = (Required) The name of the CDN endpoint to create.
      enabled = (Optional) Is the CDN endpoint enabled? Defaults to `true`.
    })
  DESCRIPTION
}

variable "cdn_origin_groups" {
  type = list(object({
    name                                                      = string
    session_affinity_enabled                                  = optional(bool, false)
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 5)
    health_probe = optional(object({
      interval_in_seconds = optional(number, 100)
      path                = optional(string, "/")
      protocol            = optional(string, "Http")
      request_type        = optional(string, "HEAD")
    }))
    load_balancing = optional(object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }))
  }))
  default = [
    {
      name                                                      = "PrivateGPTOriginGroup"
      session_affinity_enabled                                  = false
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 5
      health_probe = {
        interval_in_seconds = 100
        path                = "/"
        protocol            = "Http"
        request_type        = "HEAD"
      }
      load_balancing = {
        additional_latency_in_milliseconds = 50
        sample_size                        = 4
        successful_samples_required        = 3
      }
    }
  ]
  description = <<-DESCRIPTION
    type = list(object({
      name                                                      = (Required) The name of the CDN origin group to create.
      session_affinity_enabled                                  = (Optional) Is session affinity enabled? Defaults to `false`.
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = (Optional) The time in minutes to restore traffic to a healed or new endpoint. Defaults to `5`.
      health_probe = (Optional) The health probe settings.
      type = object({
        interval_in_seconds = (Optional) The interval in seconds between health probes. Defaults to `100`.
        path                = (Optional) The path to use for health probes. Defaults to `/`.
        protocol            = (Optional) The protocol to use for health probes. Possible values include 'Http' and 'Https'. Defaults to `Http`.
        request_type        = (Optional) The request type to use for health probes. Possible values include 'GET', 'HEAD', and 'OPTIONS'. Defaults to `HEAD`.
      }))
      load_balancing = (Optional) The load balancing settings.
      type = object({
        additional_latency_in_milliseconds = (Optional) The additional latency in milliseconds for probes to fall into the lowest latency bucket. Defaults to `50`.
        sample_size                        = (Optional) The number of samples to take for load balancing decisions. Defaults to `4`.
        successful_samples_required        = (Optional) The number of samples within the sample period that must succeed. Defaults to `3`.
      }))
    }))
    DESCRIPTION
}

variable "cdn_gpt_origin" {
  type = object({
    name                           = string
    origin_group_name              = string
    enabled                        = optional(bool, true)
    certificate_name_check_enabled = optional(bool, true)
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    priority                       = optional(number, 1)
    weight                         = optional(number, 1000)
  })
  default = {
    name                           = "PrivateGPTOrigin"
    origin_group_name              = "PrivateGPTOriginGroup"
    enabled                        = true
    certificate_name_check_enabled = true
    http_port                      = 80
    https_port                     = 443
    priority                       = 1
    weight                         = 1000
  }
  description = <<-DESCRIPTION
    type = object({
      name                           = (Required) The name which should be used for this Front Door Origin. Changing this forces a new Front Door Origin to be created.
      origin_group_name              = (Required) The name of the CDN origin group to associate this origin with.
      enabled                        = (Optional) Is the CDN origin enabled? Defaults to `true`.
      certificate_name_check_enabled = (Required) Specifies whether certificate name checks are enabled for this origin. Defaults to `true`.
      http_port                      = (Optional) The HTTP port of the origin. (e.g. 80)
      https_port                     = (Optional) The HTTPS port of the origin. (e.g. 443)
      priority                       = (Optional) The priority of the origin. (e.g. 1)
      weight                         = (Optional) The weight of the origin. (e.g. 1000)
    })
  DESCRIPTION
}

variable "cdn_route" {
  type = object({
    name                       = string
    enabled                    = optional(bool, true)
    forwarding_protocol        = optional(string, "HttpsOnly")
    https_redirect_enabled     = optional(bool, false)
    patterns_to_match          = optional(list(string), ["/*"])
    supported_protocols        = optional(list(string), ["Http", "Https"])
    cdn_frontdoor_origin_path  = optional(string, null)
    cdn_frontdoor_rule_set_ids = optional(list(string), null)
    link_to_default_domain     = optional(bool, false)
    cache = optional(object({
      query_string_caching_behavior = string
      query_strings                 = optional(list(string), [])
      compression_enabled           = bool
      content_types_to_compress     = optional(list(string), [])
    }))
  })
  default = {
    name                       = "PrivateGPTRoute"
    enabled                    = true
    forwarding_protocol        = "HttpsOnly"
    https_redirect_enabled     = false
    patterns_to_match          = ["/*"]
    supported_protocols        = ["Http", "Https"]
    cdn_frontdoor_origin_path  = null
    cdn_frontdoor_rule_set_ids = null
    link_to_default_domain     = false
    cache = {
      query_string_caching_behavior = "IgnoreQueryString"
      query_strings                 = []
      compression_enabled           = false
      content_types_to_compress     = []
    }
  }
  description = <<-DESCRIPTION
    type = object({
      name                           = (Required) The name of the CDN route to create.
      enabled                        = (Optional) Is the CDN route enabled? Defaults to `true`.
      forwarding_protocol            = (Optional) The protocol this rule will use when forwarding traffic to backends. Possible values include `MatchRequest`, `HttpOnly` and `HttpsOnly`. Defaults to `HttpsOnly`.
      https_redirect_enabled         = (Optional) Is HTTPS redirect enabled? Defaults to `false`.
      patterns_to_match              = (Optional) The list of patterns to match for this rule. Defaults to `["/*"]`.
      supported_protocols            = (Optional) The list of supported protocols for this rule. Defaults to `["Http", "Https"]`.
      cdn_frontdoor_origin_path      = (Optional) The path to use when forwarding traffic to backends. Defaults to `null`.
      cdn_frontdoor_rule_set_ids     = (Optional) The list of rule set IDs to associate with this rule. Defaults to `null`.
      link_to_default_domain         = (Optional) Is the CDN route linked to the default domain? Defaults to `false`.
      cache = (Optional) The CDN route cache settings.
      type = object({
        query_string_caching_behavior = (Required) The query string caching behavior. Possible values include 'IgnoreQueryString', 'BypassCaching', 'UseQueryString', and 'NotSet'. Defaults to 'IgnoreQueryString'.
        query_strings                 = (Optional) The list of query strings to include or exclude from caching. Defaults to `[]`.
        compression_enabled           = (Required) Is compression enabled? Defaults to `false`.
        content_types_to_compress     = (Optional) The list of content types to compress. Defaults to `[]`.
      })
    })
  DESCRIPTION
}

variable "cdn_firewall_policy" {
  type = object({
    create_waf                        = bool
    name                              = string
    enabled                           = optional(bool, true)
    mode                              = optional(string, "Prevention")
    redirect_url                      = optional(string)
    custom_block_response_status_code = optional(number, 403)
    custom_block_response_body        = optional(string)
    custom_rules = optional(list(object({
      name                           = string
      action                         = string
      enabled                        = optional(bool, true)
      priority                       = number
      type                           = string
      rate_limit_duration_in_minutes = optional(number, 1)
      rate_limit_threshold           = optional(number, 10)
      match_conditions = list(object({
        match_variable     = string
        match_values       = list(string)
        operator           = string
        selector           = optional(string)
        negation_condition = optional(bool)
        transforms         = optional(list(string))
      }))
    })))
  })
  default = {
    create_waf                        = true
    name                              = "PrivateGPTFirewallPolicy"
    enabled                           = true
    mode                              = "Prevention"
    redirect_url                      = null
    custom_block_response_status_code = 403
    custom_block_response_body        = "WW91ciByZXF1ZXN0IGhhcyBiZWVuIGJsb2NrZWQu"
    custom_rules = [
      {
        name                           = "PrivateGPTFirewallPolicyCustomRule"
        action                         = "Block"
        enabled                        = true
        priority                       = 100
        type                           = "MatchRule"
        rate_limit_duration_in_minutes = 1
        rate_limit_threshold           = 10
        match_conditions = [
          {
            match_variable     = "RemoteAddr"
            match_values       = ["10.0.1.0/24", "10.0.2.0/24"]
            operator           = "IPMatch"
            selector           = null
            negation_condition = null
            transforms         = []
          }
        ]
      }
    ]
  }
  description = "The CDN firewall policies to create."
}

variable "cdn_security_policy" {
  type = object({
    name              = string
    patterns_to_match = list(string)
  })
  default = {
    name              = "PrivateGPTSecurityPolicy"
    patterns_to_match = ["/*"]
  }
  description = <<-DESCRIPTION
    type = object({
      name                 = (Required) The name of the CDN security policy to create.
      patterns_to_match    = (Required) The list of patterns to match for this policy. Defaults to `["/*"]`.
    })
  DESCRIPTION
}