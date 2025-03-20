# Author

Matěj Hrabálek -- https://www.linkedin.com/in/matejhrabalek/

# 📌 Sentinel Deployment

This repository contains scripts and configurations for automating the deployment and configuration of **Microsoft Sentinel**.

This is the modified https://github.com/javiersoriano/sentinel-all-in-one repository.

## 📂 Repository Structure

- **`Scripts/`** – Collection of scripts for deploying Microsoft Sentinel
- **`LinkedTemplates/`** – ARM templates for deploying Sentinel and related resources.
- **`Media/`** – Additional media files

- **`README.md`** – Documentation and usage guide for this repository.

- **`azuredeploy.json`** – Main deployment template.
- **`createUiDefinition.json`** – Template for creating Azure GUI in order to deploy azuredeploy.json.

## 🚀 Deployment Guide

### 1️⃣ Prerequisites

Ensure you have the following:
- **Owner** permissions on the target Azure subscription
- **PowerShell 7+** or **Python 3.x** (depending on the scripts used)

### 2️⃣ Deployment Steps

#### **Option 1: Deploy Sentinel using ARM Templates**

Click on the following button

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmystak23%2FSentinel_Deployment%2Fmain%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fmystak23%2FSentinel_Deployment%2Fmain%2FcreateUiDefinition.json)
