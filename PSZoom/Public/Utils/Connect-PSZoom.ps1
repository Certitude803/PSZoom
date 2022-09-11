<#

.SYNOPSIS
Use this cmdlet to retrieve a token from Zoom.

.DESCRIPTION
Assigns a token to the variable $PSZoomToken which is used by all cmdlets when making requests to Zoom.

.EXAMPLE
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret'

.EXAMPLE
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret' -Scope Local

#>

function Connect-PSZoom {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0
        )]
        [string]$AccountID,

        [Alias('APIKey')]
        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [string]$ClientID,

        [Alias('APISecret')]
        [Parameter(
            Mandatory = $True, 
            Position = 2
        )]
        [string]$ClientSecret,


        [Parameter(
            Position = 3
        )]
        [ValidateSet('global','script')]
        [string]$Scope = 'global'
    )

    try {
        $token = New-OAuthToken -AccountID $AccountID -ClientID $ClientID -ClientSecret $ClientSecret
        
        if ($Scope -eq 'script') {
            $script:PSZoomToken = $token
        } else {
            $global:PSZoomToken = $token
        }
    } catch {
        if ($_.exception.Response) {
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                $errorStreamReader = [System.IO.StreamReader]::new($_.exception.Response.GetResponseStream())
                $errorDetails = ConvertFrom-Json ($errorStreamReader.ReadToEnd())
            }
            else {
                $errorDetails = ConvertFrom-Json $_.errorDetails -AsHashtable
            }
        }

        Write-Error "Unable to retrieve token for account ID $AccountID. $($errorDetails.reason)"
    }
}