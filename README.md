# 📂 Author

Matěj Hrabálek -- https://www.linkedin.com/in/matejhrabalek/

# 📌 Sentinel Deployment

This repository contains scripts and configurations for automating the deployment and configuration of **Microsoft Sentinel**.

This is the modified https://github.com/javiersoriano/sentinel-all-in-one repository with additional scripts.

## 📂 Repository Structure

- **`LinkedTemplates/`** – Collection of sub-templates for deployment, including settings, workspace deployment and content hub solutions.

- **`README.md`** – Documentation and usage guide for this repository.

- **`azuredeploy.json`** – ARM deployment template.

- **`./SentinelDeploy.ps1`** – Main deploying script.

## 📌 What the script is doing

The `SentinelDeploy.ps1` script performs a full deployment of Microsoft Sentinel using an ARM template. 

These parameters are general and might be modified in the script:
   - **Location:** North Europe
   - **Tier:** Pay-as-you-go

It automates the following steps:

1. 🚀 **Deploys Microsoft Sentinel Workspace**  
   - Creates a new Resource Group using `azuredeploy.json`
   - Deploys Log Analytics workspace using `azuredeploy.json`
   - Changes default Log Analytics workspace retention to 90 days using `azuredeploy.json`
   - Enables Microsoft Sentinel UEBA using `azuredeploy.json`
   - Enables Microsoft Sentinel auditing using `azuredeploy.json`

2. 🛠️ **Registers Required Resource Providers**  
   - Ensures all necessary Azure resource providers are registered.

3. 📊 **Configures Diagnostic Settings**  
   - Enables diagnostic logging for both the Log Analytics workspace and the subscription.

4. 🛠️ **Install Content Hub Solutions**  
   - Ensures all necessary Azure resource providers are registered.

5. 🗃️ **Sets Retention Policies**  
   - Applies default archive and interactive retention for selected Log Analytics tables. The default values are **90** days for interactive retention and **730** days for archive retention. The tables **SecurityIncident** and **SecurityAlert** have the interactive retention for two years. It can be modified.

## 📌 What the script is NOT doing

For now, this must be deployed using Azure Portal:

1. 🛠️ **Integrate Workspace in the Security Portal**
2. 🚀 **Enable UEFA for specific tables**  
3. 📊 **Enable Data connectors** except Azure Activity table, which is auto-deployed after creating Diagnostic Settings in the subscription. 

# 🚀 Deployment Guide

## 1️⃣ Prerequisites

Ensure you have the following:
- **Owner** permissions on the target Azure subscription
- **Security Administrator or Global Administrator** permissions in tenant
- **PowerShell 7+** installed
git 
## 2️⃣ Deployment Steps

### 1️⃣ Run the script

Run the script

`./SentinelDeploy.ps1`

### 2️⃣ Enter parameters

RgName: `<your_RG_name>`
WorkspaceName: `<your_LA_name>`
