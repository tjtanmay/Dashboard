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
<HEAD>
<style type=""text/css"">
	 .bar {
  fill: red; /* changes the background */
  height: 21px;
  transition: fill .3s ease;
  cursor: pointer;
  font-family: Helvetica, sans-serif;
}
.bar text {
  color: black;
}
.bar:hover,
.bar:focus {
  fill: black;
}
.bar:hover text,
.bar:focus text {
  fill: red;
}
</style></HEAD>
                 <BODY>
                 <font color:black  face=""Microsoft Tai le"">
                                 <H2> Server Name - $(Get-Date -Format g) </H2></font>"


Foreach($Entry in $Result) 
{
  $Outputreport +="$($Entry.Servername)<br>
  <svg class=""chart"" width=""420"" height=""150"" aria-labelledby=""title desc"" role=""img"">
  <title id=""title"">Server Stats</title>
  <desc id=""desc"">CPU Load; Mem Load; Storage</desc>
  <g class=""bar"">
    <rect width=""$($Entry.CPULoad)"" height=""19""></rect>
    <text x=""350"" y=""9.5"" dy="".35em"">$($Entry.CPULoad) CPU Utilization</text>
  </g>
  <g class=""bar"">
    <rect width=""$($Entry.MemLoad)"" height=""19"" y=""20""></rect>
    <text x=""350"" y=""28"" dy="".35em"">$($Entry.MemLoad) Memory Utilization</text>
  </g>
  <g class=""bar"">
    <rect width=""$($Entry.CDrive)"" height=""19"" y=""40""></rect>
    <text x=""350"" y=""48"" dy="".35em"">$($Entry.CDrive) Space available</text>
  </g>

</svg>
</body>
</html>

"
    } 
    }

$Outputreport | out-file "C:\Users\Tanmay\Desktop\Dashboard\test\servers.htm"