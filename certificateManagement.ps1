Param 
(
    [Parameter(Mandatory=$true)][string]$cloudFlareKey
)

$certNames = '<<DOMAIN01>>','<<DOMAIN02>>' #Domains (Seperated by comma, wrapped in single quotes)
$email = '<<EMAIL>>' #Lets Encrypt Certificate Manager Email
$renewDays = 14


Import-Module Posh-ACME

$pArgs = @{
    CFToken = (ConvertTo-SecureString $cloudFlareKey -AsPlainText -Force)
}

#Handle getting new cert if does not exist

#Retrieve Existing Cert if exists
$retrievedCert = Get-PACertificate -MainDomain $certNames[0]

if ($null -eq $retrievedCert)
{
    #Request certificate if ite does not exist
    Write-Host "No Certificate Fount Retrieving new Certificate"
    New-PACertificate $certNames -AcceptTOS -Plugin Cloudflare -PluginArgs $pArgs
    
    #Pull newly retrieved certificate
    $retrievedCert = Get-PACertificate -MainDomain $certNames[0]
}
elseif (((New-TimeSpan -Start (Get-Date) -End ($retrievedCert.NotAfter)) -le $renewDays))
{
    #Renew cert - add to else if it does exist try renewal
    Write-Host "Certificate due for renewal, ignoring"
    Submit-Renewal -MainDomain $certNames[0]
}
else
{
    Write-Host "Certificate is current, continuing"
}

$mobilityPrintCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 "C:\Program Files (x86)\PaperCut Mobility Print\data\tls.cer"

if ($mobilityPrintCert.NotBefore -lt $retrievedCert.NotBefore)
{
    Write-Host "Certificate in store newer than one in Mobility Print, proceeding with updating the certificate"
    Copy-Item -Path $retrievedCert.FullChainFile -Destination "C:\Program Files (x86)\PaperCut Mobility Print\data\tls.cer" -Force
    Copy-Item -Path $retrievedCert.KeyFile -Destination "C:\Program Files (x86)\PaperCut Mobility Print\data\tls.pem" -Force
    Restart-Service -Name pc-mobility-print -Force
    Restart-Service -Name pc-print-deploy -Force
    Write-Host "Updating the Papercut Keystore"
    Start-Process 'C:\Program Files\PaperCut MF\server\bin\win\create-ssl-keystore.exe' -ArgumentList " -f -k `"C:\Program Files\PaperCut MF\server\custom\my-ssl-keystore`" -cert $($retrievedCert.FullChainFile) -key $($retrievedCert.KeyFile) -keystoreentry standard" -WorkingDirectory "C:\Program Files\PaperCut MF\server\bin\win\" -Wait -NoNewWindow
    Restart-Service -Name PCAppServer -Force
}
elseif($retrievedCert.NotBefore -lt $mobilityPrintCert.NotBefore)
{
    Write-Host "Certificate in Mobility Print folder is newer than the one in the store, ingnoring one in store"
}
elseif($retrievedCert.Thumbprint -eq $mobilityPrintCert.Thumbprint)
{
    Write-Host "Certificate in Mobility Print folder matches the one in the store, ignoring"
}

