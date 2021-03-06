﻿workflow Remove-ClassDnsRecordSets {
  
  [CmdletBinding()] 
  Param(
    [Parameter(Mandatory=$true)]
    [pscredential]$Credentials,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$ZoneName
    
  )
  $username = $credentials.UserName.ToString()
  Write-Output "Logging in as $username"
  if ((Get-AzureRmContext).Account -eq $null) {
    Connect-AzureRmAccount -Credential $Credentials
  }
  $dnsRecordSets = Get-AzureRMDnsRecordSet -ZoneName $zoneName -ResourceGroupName $resourceGroupName
 
  if ($dnsRecordSets.Count -gt 0) {
    forEach -parallel -throttle 15 ($dnsRecordSet in $dnsRecordSets) {
      if ($dnsRecordSet.RecordType -eq "A" -and $dnsRecordSet.Name -notlike "*www*") {
        Connect-AzureRmAccount -Credential $Credentials
        $dnsName = $dnsRecordSet.Name.toString()
        Write-Output "Removing $dnsName"
        Remove-AzureRmDnsRecordSet -Name $dnsRecordSet.Name -RecordType "A" -ZoneName $zoneName -ResourceGroupName $resourceGroupName
      }
    }
  }
  else {
    Write-Output "No DNS RecordSets found"
  }
}