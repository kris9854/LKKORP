function Create-StringEncryption {
    param (
        # Save Path Key
        [Parameter(Mandatory = $false)]
        [string]
        $SavePathKey = "C:\Password\aes-FTPUser.key",
        
        # Save Path Password
        [Parameter(Mandatory = $false)]
        [string]$SavePathPWD = "C:\Password\FTPuserPassword.txt"
    )

    $Key = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | Out-File $SavePathKey
    Write-Host -Object 'Insert the String you need to encrypt: ' -NoNewline -ForegroundColor "$Global:TextColour"
    $PasswordForEncryption = Read-Host -AsSecureString
    $PasswordForEncryption | ConvertFrom-SecureString -Key (Get-Content "$SavePathKey") | Set-Content "$SavePathPWD"
}
