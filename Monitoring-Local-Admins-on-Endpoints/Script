# Get the local computer name
$computerName = $env:COMPUTERNAME

# Define users to exclude (both static and dynamic)
$excludedUsers = @(
    'DOMAIN.LOCAL\tomw.admin',
    '$computerName\administrator',
    "$computerName\NTXAdmin"
)

# Get the local Administrators group
$adminGroup = [ADSI]"WinNT://./Administrators,group"

# Get the members of the Administrators group
$members = @($adminGroup.psbase.Invoke("Members") | ForEach-Object { 
    $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) 
})

# Convert SIDs to display names
$displayNames = @()
foreach ($member in $members) {
    try {
        $sid = New-Object System.Security.Principal.SecurityIdentifier($member)
        $account = $sid.Translate([System.Security.Principal.NTAccount])
        $displayNames += $account.Value
    } catch {
        # If the member is not a SID, use the original name
        $displayNames += $member
    }
}

# Filter out display names that contain 'S-1-12-1-' and any in the exclusion list
$filteredDisplayNames = $displayNames | Where-Object {
    $_ -notmatch 'S-1-12-1-' -and ($excludedUsers -notcontains $_)
}

# Write the members of the Administrators group to the specified UDF
$UDFSelection = $env:UDFSelection
$UDFOutput = $filteredDisplayNames -join ", "

# Write to RMM 
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom11 /t REG_SZ /d $UDFOutput /f

# Confirm output
Write-Output "Members of the Administrators group have been written to $env:UDFSelection"
