# Takes the username requested when running the component
$Username = "$env:AdminUsername"
# Stores which UDF to use for the password
$UDFSelection = $env:UDFSelection

# Password to be generated
function New-RandomPassword {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Length,
        [string]$Characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%?'
    )
     
    $password = -join (1..$length | ForEach-Object { Get-Random -InputObject $characters.ToCharArray() })
    return $password
}

# Populates the variable so RMM can write to custom-10
$Password = New-RandomPassword -Length 16 -Characters "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%?"

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Check if the user exists
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    # User exists, reset the password
    Set-LocalUser -Name $Username -Password $securePassword
    Write-Host "Password for user $Username has been reset."
    Write-Host "Password changed to $password"
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom10 /t REG_SZ /d $Password /f
} else {
    # User does not exist, create the new local user account
    New-LocalUser -Name $Username -Password $securePassword -FullName "NTX Administrator" -Description "NTX Administrator Account"
    # Add the new user to the Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $Username
    Write-Host "User $Username has been created and added to the Administrators group."
    Write-Host "Password set to $password"
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom10 /t REG_SZ /d $Password /f
}

# Reset log
Remove-Item -Path "C:\Program Files (x86)\CentraStage\log.txt" -Force
