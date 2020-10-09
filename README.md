# PIMTools

PIMTools is a PowerShell module with commands for working with Azure AD Privileged Identity Management.


# Getting started

1. **Start Windows PowerShell (on Windows 7 - 10)**

Simply press the Start button and search for "PowerShell". You will likely get two hits:
"Windows PowerShell" and "Windows PowerShell ISE". For more modern console and editor feature you may also want to check out [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) and [Visual Studio Code](https://code.visualstudio.com/).

2. **Allow PowerShell scripts to be executed**

PowerShell has a feature called "execution policy" which by default is set to "Restricted",
meaning that no scripts is allowed to run. In the context of this article, I will recommend
to set the execution policy to "RemoteSigned". This means that you can run scripts locally
without having to sign it with a digital signature.

Run the following command to configure the execution policy:
*Set-ExecutionPolicy RemoteSigned*

Make sure you start PowerShell with "Run As Administrator" before running the command. Alternatively, run the following if you do not have Administrator privileges:
*Set-ExecutionPolicy RemoteSigned -Scope CurrentUser*

3. **Install the PIMTools module**

The module is available from the PowerShell Gallery, meaning we can install it by simply running the following:
```powershell
Install-Module -Name PIMTools
```

If this is the first time you run this command, you will be prompted to install NuGet which is being
 used under the hood to interact with the PowerShell Gallery. Answer Yes when prompted to install
this prerequisite. Next, you will be warned that the PowerShell Gallery by default is configured
as an untrusted source. Answer Yes to acknowledge this and install the module.

Now the module is installed and is ready to be used.

4. **Example usage**

```powershell
# Elevate an eligble Azure AD role
New-AzureADPIMRequest -RoleName 'Global Administrator'

# Elevate an eligble Azure role
New-AzurePIMRequest -RoleName Owner -ResourceName IT -ResourceType ManagementGroup

New-AzurePIMRequest -RoleName Contributor -ResourceName MySubscription -ResourceType Subscription
```

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Branches

### master

[![Build Status](https://dev.azure.com/janegilring/PIMTools/_apis/build/status/janegilring.PIMTools?branchName=master)](https://dev.azure.com/janegilring/PIMTools/_build/latest?definitionId=3?branchName=master)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PIMTools.svg)](https://www.powershellgallery.com/packages/PIMTools)

This is the branch containing the latest release -
no contributions should be made directly to this branch.

### dev

[![Build Status](https://dev.azure.com/janegilring/PIMTools/_apis/build/status/janegilring.PIMTools?branchName=dev)](https://dev.azure.com/janegilring/PIMTools/_build/latest?definitionId=3?branchName=dev)

This is the development branch
to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## How to Contribute

If you would like to contribute to this repository, please read the [contributing guidelines](https://github.com/janegilring/PIMTools/blob/master/CONTRIBUTING.md).
