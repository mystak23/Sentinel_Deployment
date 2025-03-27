# -----------------------------------------
# Base deployment
# -----------------------------------------
# Parameters passed to the script
param (
    [Parameter(Mandatory=$false)]
    [string[]]$EnableDataConnectors = @(), # Add specific connectors and solutions later as needed.

    [Parameter(Mandatory=$false)]
    [string[]]$EnableSolutions1P = @(), # Add specific connectors and solutions later as needed.

    [Parameter(Mandatory=$true)]
    [string]$RgName,

    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName,

    [Parameter(Mandatory=$false)]
    [string]$location = 'northeurope',

    [Parameter(Mandatory=$false)]
    [ValidateSet('CapacityReservation', 'Free', 'LACluster', 'PerGB2018', 'PerNode', 'Premium', 'Standalone', 'Standard')]
    [string]$PricingTier = 'PerGB2018',

    [Parameter(Mandatory=$false)]
    [int]$CapacityReservation = 100,

    [Parameter(Mandatory=$false)]
    [int]$DailyQuota = 0,

    [Parameter(Mandatory=$false)]
    [int]$DataRetention = 90,

    [Parameter(Mandatory=$false)]
    [bool]$ImmediatePurgeDataOn30Days = $true,

    [Parameter(Mandatory=$false)]
    [string[]]$AadStreams = @(),

    [Parameter(Mandatory=$false)]
    [bool]$EnableUeba = $true,

    [Parameter(Mandatory=$false)]
    [string[]]$IdentityProviders = @("AzureActiveDirectory"),

    [Parameter(Mandatory=$false)]
    [bool]$EnableDiagnostics = $true,

    [Parameter(Mandatory=$false)]
    [string[]]$SeverityLevels = @()
)

# -----------------------------------------
# Constant values used in the script
# -----------------------------------------
## Parameters
$templateParameters = @{
    rgName                          = $RgName
    workspaceName                   = $WorkspaceName
    location                        = $location
    pricingTier                     = $PricingTier
    capacityReservation              = $CapacityReservation
    dailyQuota                      = $DailyQuota
    dataRetention                   = $DataRetention
    immediatePurgeDataOn30Days     = $ImmediatePurgeDataOn30Days
    enableDataConnectors            = $EnableDataConnectors
    enableSolutions1P               = $EnableSolutions1P
    aadStreams                      = $AadStreams
    enableUeba                      = $EnableUeba
    identityProviders               = $IdentityProviders
    enableDiagnostics                = $EnableDiagnostics
    severityLevels                  = $SeverityLevels
}

## Retention values
$archiveRetentionTableTime = -1 # -1 means workspace default for interactive retention
$interactiveRetentionTableTime = 730 # 2 years of interactive retention for SecurityAlert, SecurityIncident
$totalRetention = 730 # 2 years

## List of tables that have archive retention 
$archiveTables = @(
    "SigninLogs",
    "AzureActivity",
    "CommonSecurityLog",
    "OfficeActivity",
    "DeviceInfo",
    "DeviceNetworkInfo",
    "DeviceNetworkEvents",
    "DeviceTvmSecureConfigurationAssessment",
    "DeviceTvmSecureConfigurationAssessmentKB",
    "DeviceTvmSoftwareInventory",
    "DeviceTvmSoftwareVulnerabilities",
    "DeviceTvmSoftwareVulnerabilitiesKB",
    "DeviceProcessEvents",
    "DeviceFileEvents",
    "DeviceRegistryEvents",
    "DeviceLogonEvents",
    "DeviceImageLoadEvents",
    "DeviceEvents",
    "DeviceFileCertificateInfo",
    "EmailEvents",
    "EmailAttachmentInfo",
    "EmailPostDeliveryEvents",
    "UrlClickEvents",
    "CloudAppEvents",
    "IdentityLogonEvents",
    "IdentityQueryEvents",
    "IdentityDirectoryEvents",
    "AuditLogs",
    "AADNonInteractiveUserSignInLogs",
    "AADRiskyUsers",
    "AADUserRiskEvents"
    "AADServicePrincipalSignInLogs",
    "AADManagedIdentitySignInLogs",
    "AADProvisioningLogs",
    "ADFSSignInLogs",
    "AADRiskyServicePrincipals",
    "MicrosoftGraphActivityLogs",
    "MicrosoftPurviewInformationProtection",
    "Syslog",
    "SecurityEvent",
    "LAQueryLogs",
    "Alert",
    "AlertEvidence",
    "AlertInfo",
    "Usage",
    "Event"
)


## List of tables that have interactive retention
$interactiveTables = @(
    "SecurityIncident",
    "SecurityAlert"
)

# -----------------------------------------
# Base deployment execution
# -----------------------------------------
try {
    Write-Host "[START] 🚀 Starting deploying ARM template... The following will be deployed:" -ForegroundColor Blue
    Write-Host "[START] 🚀 Resource Group, Log Analytics Workspace, Microsoft Sentinel" -ForegroundColor Blue
    Write-Host "[START] 🚀 The following will be configured:" -ForegroundColor Blue
    Write-Host "[START] 🚀 Log Analytics Workspace default retention set to 90 days." -ForegroundColor Blue
    Write-Host "[START] 🚀 Microsoft Sentinel auditing enabled." -ForegroundColor Blue
    Write-Host "[START] 🚀 UEBA configured." -ForegroundColor Blue
    Write-Host "[START] 🚀 Content Hub solutions installed." -ForegroundColor Blue

    New-AzSubscriptionDeployment -TemplateFile "azuredeploy.json" -TemplateParameterObject $templateParameters -location $location *> $null

    Write-Host "[SUCCESS] ✅ ARM deployment completed successfully." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] ❌ ARM deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -----------------------------------------
# Resource provider registration
# -----------------------------------------
try {
    Write-Host "[START] 🛠️ Registering required Azure resource providers." -ForegroundColor Blue
    $providers = @(
        "Microsoft.OperationsManagement",
        "Microsoft.Insights",
        "Microsoft.OperationalInsights",
        "Microsoft.SecurityInsights",
        "Microsoft.Logic",
        "Microsoft.Web",
        "Microsoft.Storage",
        "Microsoft.HybridCompute"
    )

    foreach ($provider in $providers) {
        az provider register --namespace $provider *> $null
    }
    Write-Host "[SUCCESS] ✅ Successfully registered Azure resource providers." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] ❌ Failed to register Azure resource providers: $_" -ForegroundColor Red
}

# -----------------------------------------
# Diagnostic settings configuration
# -----------------------------------------
try {
    Write-Host "[START] 🔧 Setting Azure subscription context..." -ForegroundColor Blue
    az account set --subscription $SubscriptionId *> $null

    Write-Host "[START] 📜 Retrieving Log Analytics Workspace ID..." -ForegroundColor Blue
    $workspaceId = az monitor log-analytics workspace show `
        --workspace-name $WorkspaceName `
        --resource-group $RgName `
        --query id `
        --output tsv *> $null

    Write-Host "[START] ⚙️ Creating diagnostic settings for Log Analytics Workspace..." -ForegroundColor Blue
    az monitor diagnostic-settings create `
        --name "LAWorkspaceDiagnostics" `
        --resource $workspaceId `
        --workspace $workspaceId `
        --logs '[{"categoryGroup":"audit","enabled":true}, {"categoryGroup":"allLogs","enabled":true}]' `
        --metrics '[]' *> $null

    Write-Host "[START] 📊 Creating diagnostic settings for the Subscription..." -ForegroundColor Blue
    az monitor diagnostic-settings subscription create `
        --name "SubscriptionDiagnostics" `
        --workspace $workspaceId `
        --logs '[{"category":"Administrative","enabled":true}, {"category":"Security","enabled":true}, {"category":"ServiceHealth","enabled":true}, {"category":"Alert","enabled":true}, {"category":"Recommendation","enabled":true}, {"category":"Policy","enabled":true}, {"category":"Autoscale","enabled":true}, {"category":"ResourceHealth","enabled":true}]' *> $null

    Write-Host "[SUCCESS] ✅ Successfully created diagnostic settings for Log Analytics Workspace and Subscription." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] ❌ Failed to create diagnostic settings: $_" -ForegroundColor Red
}

# -----------------------------------------
# Table retention configuration
# -----------------------------------------
try {
    # Iterate through each table in the list and change retention
    Write-Host "[START] 📅 Setting archive retention for specified Log Analytics tables." -ForegroundColor Blue
    foreach ($tableName in $archiveTables) {
        az monitor log-analytics workspace table update `
            --resource-group $RgName `
            --workspace-name $WorkspaceName `
            --name $tableName `
            --retention-time $archiveRetentionTableTime `
            --total-retention-time $totalRetention *> $null
        Write-Host "[SUCCESS] ✅ Successfully set archive retention to $totalRetention days for $tableName." -ForegroundColor Green
    }

    # Set interactive retention to 2 years for SecurityAlert and SecurityIncident
    Write-Host "[START] 📅 Setting interactive retention for SecurityAlert and SecurityIncident tables." -ForegroundColor Blue
    foreach ($tableName in $interactiveTables) {
        az monitor log-analytics workspace table update `
            --resource-group $RgName `
            --workspace-name $WorkspaceName `
            --name $tableName `
            --retention-time $interactiveRetentionTableTime `
            --total-retention-time $totalRetention *> $null
        Write-Host "[SUCCESS] ✅ Successfully set interactive retention to $interactiveRetentionTableTime days for $tableName." -ForegroundColor Green
    }

    Write-Host "[SUCCESS] ✅ Successfully set retention for ALL tables." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] ❌ Failed to set retention for tables: $_" -ForegroundColor Red
}
