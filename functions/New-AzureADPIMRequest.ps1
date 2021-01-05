function New-AzureADPIMRequest {
    [CmdletBinding()]
    param (
        [int]$DurationInHours = 8,
        $RoleName = '',
        $Reason = "Daily PIM elevation"
    )


    if (-not (Get-Module -ListAvailable -Name AzureADPreview)) {

        Write-Host 'Azure AD Preview module required, installing' -ForegroundColor Yellow

        Install-Module -Name AzureADPreview -Scope CurrentUser -AllowClobber

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


    switch ($RoleName) {
        'Global Administrator' { $roleDefinition = AzureADPreview\Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $AzureADCurrentSessionInfo.TenantId -Filter "DisplayName eq 'Global Administrator'" }
        '' { $roleDefinition = AzureADPreview\Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $AzureADCurrentSessionInfo.TenantId | Out-GridView -PassThru }
        Default { $roleDefinition = AzureADPreview\Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $AzureADCurrentSessionInfo.TenantId | Where-Object {$_.DisplayName -eq $RoleName} }
    }

    $subject = AzureADPreview\Get-AzureADUser -Filter ("userPrincipalName eq" + "'" + $($AzureADCurrentSessionInfo.Account) + "'")

    $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
    $schedule.Type = "Once"
    $schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $schedule.EndDateTime = (Get-Date).AddHours($DurationInHours).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    $ExistingRoleAssignmentRequest = AzureADPreview\Get-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles | Where-Object RequestedDateTime -gt (Get-Date).AddHours(-8)

    if ($ExistingRoleAssignmentRequest) {

        Write-Host "User $($AzureADCurrentSessionInfo.Account) is already elevated" -ForegroundColor Green

    } else {

        try {

            AzureADPreview\Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -Schedule $schedule -ResourceId $AzureADCurrentSessionInfo.TenantId -RoleDefinitionId $roleDefinition.Id -SubjectId $subject.ObjectId -AssignmentState "Active" -Type "UserAdd" -Reason $Reason

            Write-Host "PIM elevation for user $($AzureADCurrentSessionInfo.Account) succeeded" -ForegroundColor Yellow

        } catch {

            Write-Host "PIM elevation for user $($AzureADCurrentSessionInfo.Account) failed: $($PSItem.Exception.Message)" -ForegroundColor Red

        }
    }
}