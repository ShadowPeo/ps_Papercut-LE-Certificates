# ps_Papercut-LE-Certificates
Powershell script to automatically pull a certificate from Lets-Encrypt and install it into Papercut (MF/NG) and Papercut Mobility Print servers

This utilises and requires the Posh-ACME module, and is configured to use cloudflare DNS for the challenge
    Install-Module -Name Posh-ACME -Scope AllUsers

You will need a scheduled task set up to run this at a given period, A service account with the log on as batch job and local admin rights is how I normally achieve this.

In Addition to the licence conditions spelled out in the attached licence, the Victorian Department of Education is prohibited from utilising this resource in any way to support SCL or SID initiatives, permanently for the former, and until there is full public disclosure including the PIA to all staff with no reservations or NDA's on the later, this is not to say that individual schools cannot use the resource, they are most welcome to, DET themselves, however, cannot.
