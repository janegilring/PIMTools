<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

param ($Configuration = 'Development')

#region use the most strict mode
Set-StrictMode -Version Latest
#endregion

#region Task to Update the PowerShell Module Help Files.
# Pre-requisites: PowerShell Module PlatyPS.
task UpdateHelp {
    Import-Module .\PIMTools.psd1 -Force
    Update-MarkdownHelp .\docs
    New-ExternalHelp -Path .\docs -OutputPath .\en-US -Force
}
#endregion

#region Task to Copy PowerShell Module files to output folder for release as Module
task CopyModuleFiles {

    # Copy Module Files to Output Folder
    if (-not (Test-Path .\output\PIMTools)) {

        $null = New-Item -Path .\output\PIMTools -ItemType Directory

    }

    Copy-Item -Path '.\en-US\' -Filter *.* -Recurse -Destination .\output\PIMTools -Force
    Copy-Item -Path '.\functions\' -Filter *.* -Recurse -Destination .\output\PIMTools -Force

    #Copy Module Manifest files
    Copy-Item -Path @(
        '.\README.md'
        '.\PIMTools.psd1'
    ) -Destination .\output\PIMTools -Force
}
#endregion

#region Task to run all Pester tests in folder .\tests
task Test {
    $Result = Invoke-Pester .\tests -PassThru
    if ($Result.FailedCount -gt 0) {
        throw 'Pester tests failed'
    }

}
#endregion

#region Task to update the Module Manifest file with info from the Changelog in Readme.
task UpdateManifest {
    # Import PlatyPS. Needed for parsing README for Change Log versions
    Import-Module -Name PlatyPS

    # Find Latest Version in README file from Change log.
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$regex = '\d\.\d\.\d'
    $Versions = $regex.Matches($MarkdownObject.ParseString($README).Children.Spans.Text) | foreach-object {$_.value}
    ($Versions | Measure-Object -Maximum).Maximum

    $manifestPath = '.\PIMTools.psd1'

    # Start by importing the manifest to determine the version, then add 1 to the Build
    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, ($version.Build + 1))
    Write-Output -InputObject ('New Module version: {0}' -f $newVersion)

    # Update Manifest file with Release Notes
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    $ReleaseNotes = ((($MarkdownObject.ParseString($README).Children.Spans.Text) -match '\d\.\d\.\d') -split ' - ')[1]

    #Update Module with new version
    Update-ModuleManifest -ModuleVersion $newVersion -Path .\PIMTools.psd1 -ReleaseNotes $ReleaseNotes
}
#endregion

#region Task to Publish Module to PowerShell Gallery
task PublishModule -If ($Configuration -eq 'Production') {

    if (
                $env:Build_SourceBranchName -eq "master" -and
                $env:Build_SourceVersionMessage -match '!deploy'
            ) {

                $params = @{
                    Path        = ('{0}\Output\PIMTools' -f $PSScriptRoot )
                    NuGetApiKey = $env:psgallery
                    ErrorAction = 'Stop'
                }


                    Write-Output "Branch is master and commit message contains !deploy : $($env:Build_SOURCEVERSIONMESSAGE) - publishing module"

                    Publish-Module @params

                    Write-Output -InputObject ('PIMTools module version $newVersion published to the PowerShell Gallery')

            }
            else {
                "Skipping deployment: To deploy, ensure that...`n" +
                "`t* You are committing to the master branch (Current: $env:Build_SourceBranchName) `n" +
                "`t* Your commit message includes !deploy (Current: $env:Build_SourceVersionMessage)" |
                    Write-Host
            }

}
#endregion

#region Task clean up Output folder
task Clean {
    # Clean output folder
    if ((Test-Path .\output)) {

        Remove-Item -Path .\Output -Recurse -Force

    }
}
#endregion

#region Default Task. Runs Clean, Test, CopyModuleFiles Tasks
task . Clean, UpdateHelp, Test, CopyModuleFiles, PublishModule
#endregion
