﻿
###########################################################################
# Script to restore the volumes back to original using SnapShots
#
# Returns 1 if all volumes are successfully restored, 0 if restore is not successful
#
# Author - Mudassar Shafique
# Version - 1.2
# Last Modified 08/07/2015
#
#############################################################################


#
#	DEVEL
#
#	DEVEL
#
#	DEVEL
#
######################################################

$SqlServerName = ($env:computername).ToLower()
$LogFile = "C:\Windows\Panther\netappStorageScriptsRelease.log"
$PermissionFile = "C:\Windows\Panther\AllowToDisconnectStorage.yes"
$SupervisorIP = Get-Content -Path "c:\Windows\OEM\SuperVisorIP.txt"
$debug="&debug="
$vmName=($env:computername).ToLower()

function czas {$a="$((get-date -Format yyyy-MM-dd_HH:mm:ss).ToString())"; return $a}

#date >> $LogFile
echo "$(czas)  Starting script modRestoreVolume.ps1..." >> $LogFile
	#If (Test-Path C:\Windows\Temp\netappStorage1.loc) {
		echo "$(czas)  Second lock - detected. C:\Windows\Temp\netappStorage1.loc. Running modRestoreVolume.ps1 script" >> $LogFile
		#date >> $LogFile
			echo "$(czas)  File $PermissionFile was detected. Start  Netapp RestoreVolume procedure." >> $LogFile
			switch -wildcard ($SqlServerName) { 
					"*01" {
						$mgmtLIF = "192.168.250.2"
						$server = "server140"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*02" {
						$mgmtLIF = "192.168.250.18"
						$server = "server141"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					} 
					"*03" {
						$mgmtLIF = "192.168.250.34"
						$server = "server142"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*04" {
						$mgmtLIF = "192.168.250.50"
						$server = "server143"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*05" {
						$mgmtLIF = "192.168.250.66"
						$server = "server144"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*06" {
						$mgmtLIF = "192.168.250.82"
						$server = "server145"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*07" {
						$mgmtLIF = "192.168.250.98"
						$server = "server146"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*08" {
						$mgmtLIF = "192.168.250.114"
						$server = "server147"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*09" {
						$mgmtLIF = "192.168.250.130"
						$server = "server148"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					"*10" {
						$mgmtLIF = "192.168.250.146"
						$server = "server149"
						#date >> $LogFile
						echo "$(czas)  Hostname is $SqlServerName, mgmtLIF: $mgmtLIF , dataLIF1: $dataLIF1 , dataLIF2: $dataLIF2" >> $LogFile
					}
					default {echo "$(czas)  ### ERROR can't determine management LIF IP address for VMname: $SqlServerName"  >> $LogFile}
				}

		# Set these variables per each storage virtual machine
		#$mgmtLIF = "192.168.250.34"
		#$server = "server142"
		$secpasswd = ConvertTo-SecureString "Orbitera123!" -AsPlainText -Force
		$svmcreds = New-Object System.Management.Automation.PSCredential ("vsadmin", $secpasswd)	

		$datalun = "/vol/sql_data/data_lun_001"
		$loglun = "/vol/sql_log/log_lun_001"
		$snapinfolun = "/vol/sql_snapinfo/snapinfo_lun_001"


		$verbose = $true #for debugging

		#Function to write logs
		function PostEvent([String]$TextField, [string]$EventType)
			{	# Subroutine to Post Events to Log/Screen/EventLog
				$outfile = "C:\TestDriveSetup\netapp.log"
				$outdir = "C:\TestDriveSetup"
				$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"	
				if (! (test-path $outdir))
				{	
					$suppress = mkdir C:\TestDriveSetup
				}
				
				if (! (test-path HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\application\NetAppTestDrive) )
				{	New-Eventlog -LogName Application -source NetAppTestDrive
					PostEvent "Creating Eventlog\Application\NetAppTestDrive Eventlog Source" "Warning"
				}
				else
				{	switch -wildcard ($Eventtype)
					{	"Info*" 	{ $color="gray" }
						"Warn*"		{ $color="green" }
						"Err*"		{ $color="yellow" }
						"Cri*"		{ $color="red"
									  $EventType="Error" }
						default		{ $color="gray" }
					}
					if (!(!($verbose) -and ($EventType -eq "Information")))
					{	write-host "- "$textfield -foregroundcolor $color
						Write-Eventlog -LogName Application -Source NetAppTestDrive -EventID 1 -Message $TextField -EntryType $EventType -Computername "." -category 0
						$textfieldwithtime = $LogTime +"-" +$textfield
						$textfieldwithtime | out-file -filepath $outfile -append
					}
				}
			}	


		PostEvent "Starting RestoreVolume Script" "Information"



		Import-Module DataOnTap
		connect-nccontroller $mgmtLIF -cred $svmcreds


		try
		{
			 
			 PostEvent "Taking SnapDrive Volumes Offline and Removing" "Information"

			 get-ncvol | where {$_.Name -like "sdw*" } | set-ncvol -Offline
			 get-ncvol | where {$_.Name -like "sdw*" } | remove-ncvol -confirm:$false

			 $lastModified = read-ncdirectory -path /vol/sql_data | where-object {$_.Name -eq "data_lun_001"} | Select-Object Modified

			 restore-ncsnapshotvolume sql_data baseline -PreserveLunIds -Confirm:$false

			 $NewModified = read-ncdirectory -path /vol/sql_data | where-object {$_.Name -eq "data_lun_001"} | Select-Object Modified

			 if ($lastModified.Modified -eq $NewModified.Modified)
			 {
					PostEvent "Problem restoring sql_data volume" "Error"
					exit 0 
			 }

			 $lastModified = read-ncdirectory -path /vol/sql_log | where-object {$_.Name -eq "log_lun_001"} | Select-Object Modified

			 restore-ncsnapshotvolume sql_log baseline -PreserveLunIds -Confirm:$false

			 $NewModified = read-ncdirectory -path /vol/sql_log | where-object {$_.Name -eq "log_lun_001"} | Select-Object Modified

			 if ($lastModified.Modified -eq $NewModified.Modified)
			 {
					PostEvent "Problem restoring sql_log volume" "Error"
					exit 0 
			 }
			 
			 
			 $lastModified = read-ncdirectory -path /vol/sql_snapinfo | where-object {$_.Name -eq "snapinfo_lun_001"} | Select-Object Modified
			 
			 restore-ncsnapshotvolume sql_snapinfo baseline -PreserveLunIds -Confirm:$false

			 $NewModified = read-ncdirectory -path /vol/sql_snapinfo | where-object {$_.Name -eq "snapinfo_lun_001"} | Select-Object Modified

			 if ($lastModified.Modified -eq $NewModified.Modified)
			 {
					PostEvent "Problem restoring sql_snapinfo volume" "Error"
					exit 0 
			 }

			 PostEvent "All volumes successfully restored" "Information"

			 
			 #Remove Lun Maps

			 get-nclunmap | remove-nclunmap -Confirm:$false

			

			 PostEvent "Removed Lun Mapping" "Information"
				$releasevent=""
				$releasevent=(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/releasevnet.php?name='+$vmName + $debug)
				$Length = $releasevent.Length
			if ($Length -ge 2) {
				echo "$(czas)  Supervisor releasevnet.php respond string: $releasevent." >> $LogFile
				echo "$(czas)  releasevent length: $($releasevent.Length)" >> $LogFile
			}else{		
				echo "$(czas)  Supervisor releasevnet.php not respond OK but: $releasevent." >> $LogFile
				echo "$(czas)  releasevent length: $($releasevent.Length)" >> $LogFile
			}
				exit 1

			#end try
		}
		catch
		{
			PostEvent $_.exception "Error"
			(new-object net.webclient).DownloadString('http://'+$SupervisorIP+'/BladPodczasRestoreVolume.php?name='+$vmName + $debug)
			exit 0
			#end catch
		}
	#}else{
	#	echo "$(czas)  Cant finf lock file. C:\Windows\Temp\netappStorage1.loc. Skipping modRestoreVolume.ps1 script" >> $LogFile
	#}
echo "$(czas)  End of modRestoreVolume.ps1 script" >> $LogFile
