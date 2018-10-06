$Servers = get-content p:\serverslist.txt

foreach($server in $servers)
{
	Get-WmiObject win32_processor -computername $server | select SystemName, LoadPercentage
}

---------------

$Servers = get-content p:\serverslist.txt

foreach($server in $servers)
{
 $LoadPercentage = Get-WmiObject win32_processor -computername $server | select -exp LoadPercentage
 
 $log = New-Object psobject -Property @{
  Server = $server
  LoadPercentage = ($LoadPercentage | measure -Average).Average
 }
 $log
}

#reading log files continuesly
Get-Content -Path C:\Users\Tanmay\Desktop\Dashboard\test\logs.log -Tail 5 –Wait
#for remote system
$hostnames = Get-Content "C:\hostnames.txt"
$searchtext = "imaging completed"

foreach ($hostname in $hostnames)
{
    $file = "\\$hostname\C$\GhostImage.log"

    if (Test-Path $file)
    {
        if (Get-Content $file | Select-String $searchtext -quiet)
        {
            Write-Host "$hostname: Imaging Completed"
        }
        else
        {
            Write-Host "$hostname: Imaging not completed"
        }
    }
    else
    {
        Write-Host "$hostname: canot read file: $file"
    }
}
##################################
#Cpu utilization

  
$users = "receipents@email.com" # Users to be notified 
  
$fromemail = "sender@email.com" # From Email 
  
$server = "smtpservername" #SMTP Server information 
  
$list = "c:/temp/list.txt" # list of servers. i.e. list.txt 
  
$computers = get-content $list #fetches the names of the servers to check from the list.txt file. 
  
# Set free CPU utilizatoin threshold below( percentage) 
  
[decimal]$cputhreshold = 80 
  
  
 #Collect the data from the list of servers and only include it if the percentage free is below the threshold we set above. 
 $tableFragment= Get-WMIObject  -ComputerName $computers win32_processor ` 
| select __Server, @{name="CPUUtilization" ;expression ={“{0:N2}” -f (get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 5 | 
    select -ExpandProperty countersamples | select -ExpandProperty cookedvalue | Measure-Object -Average).average}}` 
| Where-Object {[decimal]$_.CPUUtilization -gt [decimal]$cputhreshold} ` 
| ConvertTo-HTML -fragment  
 
  
# assemble the HTML for our body of the email report. 
  
$HTMLmessage = @" 
 <font color="Red" face="Microsoft Tai le"> 
 <body BGCOLOR="White"> 
<h2>High CPU Utilization Alert</h2> </font> 
  
 <font face="Microsoft Tai le"> 
  
 You are receiving this alert because the server(s) listed below have CPU utlization higher than the alerting threshold of  $cputhreshold %. Your immediate action may be required to clear this alert. 
</font> 
<br> <br> 
<!--mce:0--> 
  
<body BGCOLOR=""white""> 
  
$tableFragment 
<br> <br> <font face="Microsoft Tai le"> <i> ** This Alert was triggered by a monitoring script </i> </font> 
</body> 
  
"@  
 
# Set up a regex search and match to look for any <td> tags in our body.  
  
# We use this regex matching method to determine whether or not we should send the email and report. 
  
$regexsubject = $HTMLmessage 
  
$regex = [regex] '(?im)<td>' 
  
# if there was any row at all, send the email 
  
if ($regex.IsMatch($regexsubject)) { 
  
                        send-mailmessage -from $fromemail -to $users -subject "CPU Utilization Monitoring Alert" -BodyAsHTML -body $HTMLmessage -priority High -smtpServer $server 
  
} 
  
# End of Script

#Generate output in html cpu utilization memory etc...


$ServerListFile = "C:\Users\Tanmay\Desktop\Dashboard\test\servers.txt"  
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue 
$Result = @() 
ForEach($computername in $ServerList) 
{

$AVGProc = Get-WmiObject -computername $computername win32_processor | 
Measure-Object -property LoadPercentage -Average | Select Average
$OS = gwmi -Class win32_operatingsystem -computername $computername |
Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}
$vol = Get-WmiObject -Class win32_Volume -ComputerName $computername -Filter "DriveLetter = 'C:'" |
Select-object @{Name = "C PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } }

$result += [PSCustomObject] @{ 
    ServerName = "$computername"
    CPULoad = "$($AVGProc.Average)%"
    MemLoad = "$($OS.MemoryUsage)%"
    CDrive = "$($vol.'C PercentFree')%"
}
$Outputreport = "<HTML><TITLE> Server Health Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#99000"" face=""Microsoft Tai le"">
                 <H2> Server Health Report </H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>Server Name</B></TD>
                   <TD><B>Avrg.CPU Utilization</B></TD>
                   <TD><B>Memory Utilization</B></TD>
                   <TD><B>Drive C Free Space</B></TD>
                   </TR>"

Foreach($Entry in $Result) 

    { 
      if(($Entry.CpuLoad) -or ($Entry.memload) -ge "80") 
      { 
        $Outputreport += "<TR bgcolor=white>" 
      } 
      else
       {
        $Outputreport += "<TR>" 
      }
      $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.CDrive)</TD></TR>" 
    }
 $Outputreport += "</Table></BODY></HTML>" 
    } 

$Outputreport | out-file "C:\Users\Tanmay\Desktop\Dashboard\test\servers$(Get-Date -Format yyy-mm-dd-hhmm).htm"