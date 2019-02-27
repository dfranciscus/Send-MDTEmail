
<#PSScriptInfo

.VERSION 0.0.4

.GUID 6686d92f-6c89-4c54-a2e3-b525d0d8ed89

.AUTHOR Dan Franciscus

.COMPANYNAME CNJ Computing LLC

.COPYRIGHT 

.TAGS MDT

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES Removed Body parameter


.PRIVATEDATA 

#>

<# 

.DESCRIPTION 
  This script runs continously to monitor MDT deployments and sends email alerts when depoyments finish. This is best used as a Windows service. To create a service easily - try NSSM https://nssm.cc/download 
.EXAMPLE
.\Send-MDTEmail.ps1 -MDTRoot 'E:\MDT' -SMTPTo 'admin@domain.com' -SMTPFrom 'MDTalert@domain.com' -SMTPSubject 'MDT deployment done' -SMTPServer 'smtp.domain.com'
#> 
Param
(
    [Parameter(Mandatory=$True)]
    [string]$SMTPFrom,
    [Parameter(Mandatory=$True)]
    [string]$SMTPTo,
    [Parameter(Mandatory=$True)]
    [string]$SMTPSubject,
    [Parameter(Mandatory=$True)]
    [string]$SMTPServer,
    [Parameter(Mandatory=$True)]
    [string]$MDTRoot
)
Try 
{
    Add-PSSnapin Microsoft.BDD.PSSnapIn -ErrorAction Stop
    New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root $MDTRoot -ErrorAction Stop 
    While ($True)
    {
        $Date = Get-Date
        Start-Sleep -Seconds 60
        $CheckData = Get-MDTMonitorData -Path DS001: | Where-Object {$_.EndTime -gt $Date.ToUniversalTime() }
        if (!$CheckData)
        {
            Continue
        }
        $Data = Get-MDTMonitorData -Path DS001: | Where-Object {$_.EndTime -gt $Date.ToUniversalTime()} | Select-Object Name,Errors,Starttime,Endtime | Format-Table -Property @{Expression={$_.StartTime.ToLocalTime()};Label="StartTime"},@{Expression={$_.EndTime.ToLocalTime()};Label="EndTime"},Name,Errors -AutoSize 
        if ($Data)
        {
            $Data = Out-String -InputObject $Data
            Send-MailMessage -Body $$Data -To $SMTPTo -From $SMTPFrom -SmtpServer $SMTPServer -Subject $SMTPSubject -ErrorAction Stop
        }
    }
}
catch 
{
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
    Break
}

