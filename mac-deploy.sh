#!/bin/bash

# Zeptá se uživatele na Tenant ID zákazníka
read -p "Zadej Tenant ID zákazníka: " tenant_id

# URL k Azure Template a UI Definition
template_url="https%3A%2F%2Fmystak23.github.io%2Fmystak23%2FSentinel_Deployment%2Fazuredeploy.json"
ui_definition_url="https%3A%2F%2Fmystak23.github.iom%2Fmystak23%2FSentinel_Deployment%2FcreateUiDefinition.json"

# Sestavení finální URL
deploy_url="https://portal.azure.com/#create/Microsoft.Template/uri/$template_url/createUIDefinitionUri/$ui_definition_url?tenantId=$tenant_id"

# Otevře odkaz v prohlížeči
xdg-open "$deploy_url" 2>/dev/null || open "$deploy_url"