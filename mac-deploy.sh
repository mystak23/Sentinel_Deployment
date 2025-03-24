#!/bin/bash

# Zeptá se uživatele na Tenant ID zákazníka
# read -p "Zadej Tenant ID zákazníka: " tenant_id

# URL k Azure Template a UI Definition
template_url="https%3A%2F%2Fraw.githubusercontent.com%2Fmystak23%2FSentinel_Deployment%2Fmain%2Fazuredeploy.json"
ui_definition_url="https%3A%2F%2Fraw.githubusercontent.com%2Fmystak23%2FSentinel_Deployment%2Fmain%2FcreateUiDefinition.json"
tenant_id="fec3a0fa-64ae-446f-a3a6-2b0eeae14c73"

# Sestavení finální URL
deploy_url="https://portal.azure.com/#create/Microsoft.Template/uri/$template_url/createUIDefinitionUri/$ui_definition_url?tenantId=$tenant_id"

# Otevře odkaz v prohlížeči
xdg-open "$deploy_url" 2>/dev/null || open "$deploy_url"