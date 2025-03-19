# Zeptá se uživatele na Tenant ID zákazníka
$tenant_id = Read-Host "Zadej Tenant ID zákazníka"

# URL k Azure Template a UI Definition
$template_url = "https%3A%2F%2Fstoredevops123.blob.core.windows.net%2Fdevops%2Fazuredeploy.json"
$ui_definition_url = "https%3A%2F%2Fstoredevops123.blob.core.windows.net%2Fdevops%2FcreateUiDefinition.json"

# Sestavení finální URL
$deploy_url = "https://portal.azure.com/#create/Microsoft.Template/uri/$template_url/createUIDefinitionUri/$ui_definition_url?tenantId=$tenant_id"

# Otevře odkaz v prohlížeči
Start-Process $deploy_url