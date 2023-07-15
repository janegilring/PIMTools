@{
    # Version number of this module.
    ModuleVersion     = '0.8.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core','Desktop')

    RootModule = 'PIMTools.psm1'

    # ID used to uniquely identify this module.
    GUID       = '0d976e94-59d9-4613-a84f-8fa3caa04ffd'

    # Author of this module
    Author = 'Jan Egil Ring'

    # Company or vendor of this module
    CompanyName = 'PSCommunity'

    # Copyright statement for this module
    Copyright = '(c) 2023 Jan Egil Ring. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'PIMTools is a PowerShell module with commands for working with Azure AD Privileged Identity Management.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion        = '4.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'New-AzureADPIMRequest',
        'New-AzurePIMRequest'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('Azure','AzureAD','PIM')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/janegilring/PIMTools/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/janegilring/PIMTools'

            # ReleaseNotes of this module
            ReleaseNotes = 'Bugfix for New-AzureADPIMRequest - detection of existing role assignments'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}