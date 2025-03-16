
# Azure Provider - The foundation for all Azure resource deployments
# Authenticates and manages communication with Azure API
provider "azurerm" {
  features {}
}

# Resource Group - Logical container for related Azure resources
# Acts as a boundary for access control, billing and lifecycle management
resource "azurerm_resource_group" "rg" {
  name     = "my-project-rg"
  location = "eastus"
}

# Virtual Network - Isolated network environment in Azure
# Enables secure communication between Azure resources and the internet
# The address space defines the range of IP addresses available
resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet - Segment of the virtual network with its own security and routing
# Used to group related resources and control network traffic flow
resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP - Provides internet-facing IP address for resources
# Can be static or dynamic allocation
resource "azurerm_public_ip" "pip" {
  name                = "my-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Network Security Group - Virtual firewall for network traffic
# Contains security rules to allow or deny traffic to resources
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface - Enables network connectivity for compute resources
# Links VMs to virtual networks, public IPs and security groups
resource "azurerm_network_interface" "nic" {
  name                = "my-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.pip.id
  }
}

# Storage Account - Used for storing blobs, files, queues and tables
# Provides secure and scalable cloud storage
resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# SQL Server - Managed relational database server
# Hosts SQL databases with built-in security and management
resource "azurerm_sql_server" "sqlserver" {
  name                         = "my-sqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd123!"
}

# SQL Database - Managed relational database
# Provides high availability and automated backups
resource "azurerm_sql_database" "db" {
  name                = "mydb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqlserver.name
}

# App Service Plan - Defines compute resources for web apps
# Determines pricing tier and compute capacity
resource "azurerm_app_service_plan" "appplan" {
  name                = "my-app-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Web App - Platform as a Service for hosting web applications
# Supports multiple programming languages and frameworks
resource "azurerm_app_service" "webapp" {
  name                = "my-web-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appplan.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "10.14.1"
  }
}

# Function App - Serverless compute service for event-driven applications
# Runs code in response to events without managing infrastructure
resource "azurerm_function_app" "function" {
  name                       = "my-function-app"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.appplan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
}

# Key Vault - Secure store for secrets, keys and certificates
# Provides centralized secrets management with access control
resource "azurerm_key_vault" "keyvault" {
  name                        = "my-key-vault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# Container Registry - Private registry for Docker images
# Stores and manages container images for deployment
resource "azurerm_container_registry" "acr" {
  name                = "mycontainerregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# Kubernetes Service - Managed Kubernetes cluster service
# Orchestrates containerized applications at scale
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myakscluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Redis Cache - In-memory data store for high-performance caching
# Improves application performance by reducing database load
resource "azurerm_redis_cache" "redis" {
  name                = "my-redis-cache"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
}

# Service Bus - Enterprise message broker service
# Enables asynchronous communication between applications
resource "azurerm_servicebus_namespace" "servicebus" {
  name                = "my-service-bus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

# Event Hub - Big data streaming platform and event ingestion service
# Processes millions of events per second with low latency
resource "azurerm_eventhub_namespace" "eventhub" {
  name                = "my-event-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
}

# Application Insights - Application performance management service
# Monitors live applications and detects performance anomalies
resource "azurerm_application_insights" "appinsights" {
  name                = "my-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Output values for important resource information
output "webapp_url" {
  value = azurerm_app_service.webapp.default_site_hostname
}

output "sql_server_fqdn" {
  value = azurerm_sql_server.sqlserver.fully_qualified_domain_name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

# Environment variable for deployment environment
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Location variable for Azure region
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Backend configuration for storing Terraform state
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                 = "terraform.tfstate"
  }
}
