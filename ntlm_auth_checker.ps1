# Get all Domain Controllers
$DCs = Get-ADDomainController -Filter *

# Prepare output
$results = @()

foreach ($dc in $DCs) {
    try {
        $settings = Invoke-Command -ComputerName $dc.HostName -ScriptBlock {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
            $restrictPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

            $ntlmMinClientSec = Get-ItemPropertyValue -Path $regPath -Name "NTLMMinClientSec" -ErrorAction SilentlyContinue
            $restrictSendingNTLMTraffic = Get-ItemPropertyValue -Path $restrictPath -Name "RestrictSendingNTLMTraffic" -ErrorAction SilentlyContinue
            $restrictReceivingNTLMTraffic = Get-ItemPropertyValue -Path $restrictPath -Name "RestrictReceivingNTLMTraffic" -ErrorAction SilentlyContinue

            return [PSCustomObject]@{
                DC                          = $env:COMPUTERNAME
                NTLMMinClientSec            = $ntlmMinClientSec
                RestrictSendingNTLMTraffic  = $restrictSendingNTLMTraffic
                RestrictReceivingNTLMTraffic= $restrictReceivingNTLMTraffic
            }
        }

        $results += $settings
    } catch {
        Write-Warning "Failed to connect to $($dc.HostName): $_"
    }
}

# Display results
$results | Format-Table -AutoSize
