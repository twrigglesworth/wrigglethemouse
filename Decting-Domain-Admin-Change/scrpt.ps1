$groupName = "Domain Admins"
$previousMembersFile = "C:\ProgramData\RMM_Monitoring\PreviousDomainAdmins.txt"
$folderPath = "C:\ProgramData\RMM_Monitoring\"
$logFile = "C:\ProgramData\RMM_Monitoring\DomainAdminsLog.txt"

# Check log file size and delete if over 50MB
$logFileSize = (Get-Item $logFile).Length / 1MB
if ($logFileSize -gt 50) {
    Remove-Item $logFile
}

# Check if the folder exists, create if it doesn't
if (-Not (Test-Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

# Get current members
try {
    $currentMembers = Get-ADGroupMember -Identity $groupName | Select-Object -ExpandProperty SamAccountName
} catch {
    Write-Host '<-Start Result->'"ERROR: Unable to retrieve current members of $groupName. $_"'<-End Result->'
    exit 1
}

# Check if admin file exists, create and populate if it doesn't
if (-Not (Test-Path $previousMembersFile)) {
    $currentMembers | Out-File $previousMembersFile
    # Set the file attribute to Hidden
    Set-ItemProperty -Path $previousMembersFile -Name Attributes -Value Hidden
    Write-Host '<-Start Result->'"STATUS: List created and populated with current Domain Admins."'<-End Result->'
}

# Load previous members list or initialize if file doesn't exist
if (Test-Path $previousMembersFile) {
    $previousMembers = Get-Content $previousMembersFile
} else {
    Write-Host '<-Start Result->'"ERROR=Previous members file not found. Please ensure the initial list is saved at $previousMembersFile."'<-End Result->'
    exit 1
}

# Compare current and previous members
$addedMembers = $currentMembers | Where-Object { $_ -notin $previousMembers }
$removedMembers = $previousMembers | Where-Object { $_ -notin $currentMembers }

# Trigger alert if there are discrepancies
if ($addedMembers) {
    $addedMembersList = $addedMembers -join ", "
    Write-Host '<-Start Result->'
    Write-Host "ALERT=New members found in Domain Admins group. Added: $addedMembersList"
    Write-Host '<-End Result->'

    write-host '<-Start Diagnostic->'
    write-host "User account added: $addedMembersList"
    write-host ""
    write-host "Current members of group: $currentMembers"
    write-host ""
    write-host "A user entry has been added to Domain Admin. Check the log found C:\ProgramData\RMM_Monitoring\."   
    write-host ""
    write-host "Domain Admins Log shows changes. Previous Domain Admins shows the list that the monitor expects the Domain Admin list to match."
    write-host ""
    write-host "Guide on correcting this issue..."
    write-host ""
    write-host "https://rmm_monitoring-tx-ltd.eu.itglue.com/618693005361331/docs/4036268211454085#version=published&documentMode=view"
    write-host '<-End Diagnostic->'

    Add-Content -Path $logFile -Value "$(Get-Date) - New members found. Added: $addedMembersList"
    # Set the file attribute to Hidden
    Set-ItemProperty -Path $logFile -Name Attributes -Value Hidden
    exit 1

} elseif ($removedMembers) {
    $removedMembersList = $removedMembers -join ", "
    Write-Host '<-Start Result->'
    Write-Host "ALERT=Members removed from Domain Admins group. Removed: $removedMembersList"
    Write-Host '<-End Result->'

    write-host '<-Start Diagnostic->'
    write-host "User account removed: $removedMembersList"
    write-host ""
    write-host "Current members of group: $currentMembers"
    write-host ""
    write-host "A user entry has been removed from Domain Admin. Check the log found C:\ProgramData\RMM_Monitoring\."
    write-host ""
    write-host "Domain Admins Log shows changes. Previous Domain Admins shows the list that the monitor expects the Domain Admin list to match."
    write-host ""
    write-host "Guide on correcting this issue..."
    write-host ""
    write-host "https://rmm_monitoring-tx-ltd.eu.itglue.com/618693005361331/docs/4036268211454085#version=published&documentMode=view"
    write-host '<-End Diagnostic->'

    Add-Content -Path $logFile -Value "$(Get-Date) - Members removed. Removed: $removedMembersList"
    # Set the file attribute to Hidden
    Set-ItemProperty -Path $logFile -Name Attributes -Value Hidden
    exit 1

} else {
    Write-Host '<-Start Result->'
    Write-Host "INFO=No discrepancies found in Domain Admins group"
    Write-Host '<-End Result->'
    exit 0
}
