Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
$running = $true
$Host.UI.RawUI.BackgroundColor = "DarkBlue"


Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
$cpu_threshold = 1
$cpu_interval = 1
$hit = 0
$iloop = 0
While($isRunning -ne $false) 
{
    $cpu = (gwmi -class Win32_Processor).LoadPercentage
    $CPUPercent = @{
        Name = ‘CPUPercent’
        Expression = 
        {
            $TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds
            [Math]::Round( ($_.CPU * 100 / $TotalSec), 2)
        }
    }
	clear-host
	write-host “CPU utilization is currently at $cpu%”
    
     
    If($cpu -ge $cpu_threshold) 
    {
        $hit = $hit+1
    }
	if($iloop -ge 5)
	{
		$hit = 0
        $iloop = 0
	}
    start-sleep $cpu_interval
    if($hit -eq 3) 
    {
        $msgBoxInput =  [System.Windows.MessageBox]::Show("CPU Utilization is more than 4`%”,'CPU is over threshold level','ok','Warning')
        switch  ($msgBoxInput) 
        {

            'ok' 
            {
            
                
            }
           
        }
        
        #Send-MailMessage –From CryptoMonito@mail.com –To 201477488@student.uj.ac.za –Subject “CPU Utilization is more than 85`%” –Body “CPU Utilization is more than $cpu_threshold`%” –SmtpServer smtpserver.domain.com

        $hit = 0
        $loop = 0
    } 
    else
    {
		If($cpu -ge $cpu_threshold) 
		{
			$Host.UI.RawUI.BackgroundColor = "DarkRed"
			Write-Host "Intense Running Processes:"
			Get-Process | Sort-Object -Property CPUPercent -Descending | Select-Object -Property Name, CPU, $CPUPercent, Description -First 20

		}else
		{	
			write-host “CPU utilization is below threshold level”
			$Host.UI.RawUI.BackgroundColor = "DarkBlue"
		}
    }
	$iloop = $iloop + 1
}
