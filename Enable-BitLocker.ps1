# Run PowerShell as Administrator before executing this script

# Step 1: Check BitLocker Volume Status
Get-BitLockerVolume

# Step 2: Enable BitLocker with TPM Protector and XtsAes128 Encryption
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes128 -TpmProtector -SkipHardwareTest

# Step 3: Add Recovery Password Protector
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

# Step 4: Retrieve the Recovery Password
$RecoveryPassword = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" } | Select-Object -ExpandProperty RecoveryPassword

# Step 5: Define Network Path for Storing BitLocker Keys
$NetworkPath = "\\servername\folderpath\"
$Username = "domain.com\administrator"
$Password = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

# Step 6: Get Computer Name
$ComputerName = $env:COMPUTERNAME

# Step 7: Define the Key File Path
$KeyFilePath = "$NetworkPath\$ComputerName-C-BitLocker-Key.txt"

# Step 8: Save Recovery Key to File
$RecoveryPassword | Out-File -FilePath $KeyFilePath -Encoding UTF8

# Step 9: Resume BitLocker Protection
Resume-BitLocker -MountPoint "C:"
