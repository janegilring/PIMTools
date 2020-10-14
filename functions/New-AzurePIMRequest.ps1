function New-AzurePIMRequest {
    [CmdletBinding()]
    param (
        [int]$DurationInHours = 8,
        $RoleName = 'Contributor',
        $ResourceType = 'ManagementGroup',
        $ResourceName = 'IT',
        $Reason = "Daily PIM elevation"
    )


    if (-not (Get-Module -ListAvailable -Name AzureADPreview)) {

        Write-Host 'Azure AD Preview module required, installing' -ForegroundColor Yellow

        Install-Module -Name AzureADPreview -Scope CurrentUser

        if (Get-Module -Name AzureAD) {

            Remove-Module -Name AzureAD
            Import-Module -Name AzureADPreview

        } else {

            Import-Module -Name AzureADPreview

        }

    } else {

        if (Get-Module -Name AzureAD) {

            Remove-Module -Name AzureAD
            Import-Module -Name AzureADPreview

        } else {

            Import-Module -Name AzureADPreview

        }


    }

    try {

        $AzureADCurrentSessionInfo = AzureADPreview\Get-AzureADCurrentSessionInfo -ErrorAction Stop

    }

    catch {

        Write-Host 'No active Azure AD session, calling Connect-AzureAD (the login window often hides in the backgroud, minimize the PowerShell window to check if you do not see it)' -ForegroundColor Yellow

        AzureADPreview\Connect-AzureAD
        $AzureADCurrentSessionInfo = AzureADPreview\Get-AzureADCurrentSessionInfo

    }

    switch ($ResourceType) {
        'resourcegroup' { $resource = AzureADPreview\Get-AzureADMSPrivilegedResource -ProviderId AzureResources -Filter "Type eq 'resourcegroup'" | Where-Object DisplayName -eq $ResourceName }
        'managementgroup' { $resource = AzureADPreview\Get-AzureADMSPrivilegedResource -ProviderId AzureResources -Filter "Type eq 'managementgroup'" | Where-Object DisplayName -eq $ResourceName }
        'subscription' { $resource = AzureADPreview\Get-AzureADMSPrivilegedResource -Provider azureResources -Filter "Type eq 'subscription'" | Where-Object DisplayName -eq $ResourceName }
        Default { $resource = AzureADPreview\Get-AzureADMSPrivilegedResource -Provider azureResources | Out-GridView -PassThru }
    }

    switch ($RoleName) {
        'Owner' { $roleDefinition = AzureADPreview\Get-AzureADMSPrivilegedRoleDefinition -ProviderId azureResources -ResourceId $resource.Id -Filter "DisplayName eq 'Owner'" }
        'Contributor' { $roleDefinition = AzureADPreview\Get-AzureADMSPrivilegedRoleDefinition -ProviderId azureResources -ResourceId $resource.Id -Filter "DisplayName eq 'Contributor'" }
        Default { $roleDefinition = AzureADPreview\Get-AzureADMSPrivilegedRoleDefinition -ProviderId azureResources -ResourceId $resource.Id | Out-GridView -PassThru }
    }

    $subject = AzureADPreview\Get-AzureADUser -Filter ("userPrincipalName eq" + "'" + $($AzureADCurrentSessionInfo.Account) + "'")

    $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
    $schedule.Type = "Once"
    $schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $schedule.EndDateTime = (Get-Date).AddHours($DurationInHours).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    $ExistingRoleAssignmentRequest = AzureADPreview\Get-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId azureResources | Where-Object RequestedDateTime -gt (Get-Date).AddHours(-8)

    if ($ExistingRoleAssignmentRequest) {

        Write-Host "User $($AzureADCurrentSessionInfo.Account) is already elevated" -ForegroundColor Yellow

    } else {

        try {

            AzureADPreview\Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId azureResources -Schedule $schedule -ResourceId $resource.Id -RoleDefinitionId $roleDefinition.Id -SubjectId $subject.ObjectId -AssignmentState "Active" -Type "UserAdd" -Reason $Reason

            Write-Host "PIM elevation for user $($AzureADCurrentSessionInfo.Account) succeeded" -ForegroundColor Green

        } catch {

            Write-Host "PIM elevation for user $($AzureADCurrentSessionInfo.Account) failed: $($PSItem.Exception.Message)" -ForegroundColor Red

        }
    }
}