# Define the list of users to remove
$UsersToRemove = @(
    "DOMAIN\username1",
    "COMPUTERNAME\username2"
)

# Get the local Administrators group
try {
    $adminGroup = [ADSI]"WinNT://./Administrators,group"
} catch {
    Write-Error "Failed to access the Administrators group."
    exit 1
}

foreach ($user in $UsersToRemove) {
    try {
        # Convert to WinNT format (replace backslash with slash)
        $userPath = "WinNT://" + $user.Replace('\', '/')
        $adminGroup.Remove($userPath)
        Write-Output "Removed $user from the Administrators group."
    } catch {
        Write-Warning "Failed to remove $user. It may not exist or is not a member of the group."
    }
}
