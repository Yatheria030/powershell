<#
.SYNOPSIS
    Updates a custom field with the link speeds of network adapters.
.DESCRIPTION
    Updates a custom field with the link speeds of network adapters.
.EXAMPLE
    No parameter needed
    
    Network Adapters and Link Speeds: Ethernet: 1 Gbps, Ethernet 2: 100 Mbps
    Attempting to set Custom Field: linkSpeed

.PARAMETER: -CustomField "ReplaceWithAnyTextCustomField"    
    Updates the custom field you specified (defaults to "linkSpeed"). The Custom Field needs to be writable by scripts (otherwise the script will report it as not found).
.OUTPUTS
    None
.NOTES
    Minimum OS Architecture Supported: Windows 7, Windows Server 2008
#>

[CmdletBinding()]
param (
    [Parameter()]
    [String]$CustomField = "linkSpeed"
)

begin {
    if ($env:customFieldName -and $env:customFieldName -notlike "null") { $CustomField = $env:customFieldName }
    $CheckNinjaCommand = "Ninja-Property-Set"
}

process {
    # Get all physical network adapters except WiFi and virtual adapters
    $networkAdapters = Get-NetAdapter | Where-Object {
        $_.PhysicalMediaType -notin @('802.11', 'Native 802.11', 'Native Wi-Fi') -and
        $_.Virtual -eq $false -and
        $_.Status -eq 'Up'
    }

    # Format the name and link speed of each filtered adapter
    $adapterInfo = $networkAdapters | ForEach-Object {
        "$($_.LinkSpeed) "
    }

    $adapterInfoString = $adapterInfo -join ', '

    Write-Host "Network Adapters and Link Speeds: $adapterInfoString"

    if ($(Get-Command $CheckNinjaCommand -ErrorAction SilentlyContinue).Name -like $CheckNinjaCommand) {
        Write-Host "Attempting to set Custom Field: $CustomField"
        Ninja-Property-Set -Name $CustomField -Value $adapterInfoString
    }
    else {
        Write-Warning "Unable to set custom field either due to legacy OS or this script is not running as an elevated user."
    }
}

end {
}
