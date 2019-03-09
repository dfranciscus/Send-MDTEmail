# Send-MDTEmail
This script runs continously to monitor MDT deployments and sends email alerts when depoyments finish. This is best used as a Windows service. To create a service easily - try NSSM https://nssm.cc/download 

## To install and use (must be installed on MDT server with monitoring enabled)

Install-Script Send-MDTEmail

./Send-MDTEmail.ps1 -SMTPFrom mdt@domain.com -SMTPTo dan@domain.com -SMTPSubject "MDT Results" -SMPTServer smtp.domain.com -MDTRoot E:\MDTShare  
