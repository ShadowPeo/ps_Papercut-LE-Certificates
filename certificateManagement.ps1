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
    New-PACertificate $certNames -AcceptTOS -Plugin Cloudflare -PluginArgs $pArgs
    
    #Pull newly retrieved certificate
    $retrievedCert = Get-PACertificate -MainDomain $certNames[0]
}
elseif (((New-TimeSpan -Start (Get-Date) -End ($retrievedCert.NotAfter)) -le $renewDays))
{
    #Renew cert - add to else if it does exist try renewal
    Submit-Renewal -MainDomain $certNames[0]
}

$mobilityPrintCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 "C:\Program Files (x86)\PaperCut Mobility Print\data\tls.cer"

if ($mobilityPrintCert.NotBefore -lt $retrievedCert.NotBefore)
{
    Copy-Item -Path $retrievedCert.FullChainFile -Destination "C:\Program Files (x86)\PaperCut Mobility Print\data\tls.cer" -Force
    Copy-Item -Path $retrievedCert.KeyFile -Destination "C:\Program Files (x86)\PaperCut Mobility Print\data\tls.pem" -Force
    Restart-Service -Name pc-mobility-print -Force
    Restart-Service -Name pc-print-deploy -Force
}

