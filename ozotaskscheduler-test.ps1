#Requires -Modules OZOLogger -RunAsAdministrator

[CmdletBinding()]
Param ()

Function Assert-Condition {
	Param (
		[Parameter(Mandatory=$true)][Boolean] $Condition,
		[Parameter(Mandatory=$true)][String] $Message
	)
	If ($Condition -eq $false) {
		throw $Message
	}
}

Function Test-TaskExists {
	Param ([Parameter(Mandatory=$true)][String] $TaskName)
	Return $null -ne (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)
}

# VARIABLES
[String] $TempDir = (Join-Path -Path $Env:SYSTEMDRIVE -ChildPath "Temp")
[String] $ModulePath = (Join-Path -Path $PSScriptRoot -ChildPath "OZOTaskScheduler\OZOTaskScheduler.psd1")
[String] $ScheduledTaskName = "OZOTaskScheduler Integration Scheduled"
[String] $AtLogonTaskName = "OZOTaskScheduler Integration AtLogon"
[String] $ScheduledConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-Scheduled.json")
[String] $AtLogonConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-AtLogon.json")
[String] $ExportPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-Export.json")

Try {
	# Ensure the temporary directory exists and stage the example assets
	New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
	Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-AtLogonTask-Example.ps1") -Destination $TempDir -Force
	Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.ps1") -Destination $TempDir -Force

	# Create test-specific configurations that point to the staged script assets
	$ScheduledConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.json") -Raw | ConvertFrom-Json
	$ScheduledConfig.Name = $ScheduledTaskName
	$ScheduledConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-ScheduledTask-Example.ps1")
	$ScheduledConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $ScheduledConfigPath

	$AtLogonConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-AtLogonTask-Example.json") -Raw | ConvertFrom-Json
	$AtLogonConfig.Name = $AtLogonTaskName
	$AtLogonConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-AtLogonTask-Example.ps1")
	$AtLogonConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $AtLogonConfigPath

	# Import the module source under test rather than an installed version
	Import-Module -Name $ModulePath -Force -ErrorAction Stop

	# Remove tasks left by an interrupted prior test run
	ForEach ($TaskName in @($ScheduledTaskName,$AtLogonTaskName)) {
		If (Test-TaskExists -TaskName $TaskName) {
			Remove-OZOScheduledTask -TaskName $TaskName
		}
	}

	# Test New, Get, Enable, Disable, Export, Set, and Remove with a scheduled task
	New-OZOScheduledTask -JsonFile $ScheduledConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $ScheduledTaskName) -Message "New-OZOScheduledTask did not create the scheduled test task."

	$ScheduledTask = Get-OZOScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition ($ScheduledTask.Name -eq $ScheduledTaskName) -Message "Get-OZOScheduledTask did not return the scheduled test task."

	Enable-OZOScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition ((Get-ScheduledTask -TaskName $ScheduledTaskName).Settings.Enabled -eq $true) -Message "Enable-OZOScheduledTask did not enable the scheduled test task."

	Disable-OZOScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition ((Get-ScheduledTask -TaskName $ScheduledTaskName).Settings.Enabled -eq $false) -Message "Disable-OZOScheduledTask did not disable the scheduled test task."

	Export-OZOScheduledTask -TaskName $ScheduledTaskName -OutFile $ExportPath
	Assert-Condition -Condition (Test-Path -Path $ExportPath) -Message "Export-OZOScheduledTask did not create the export file."
	Get-Content -Path $ExportPath -Raw | ConvertFrom-Json -ErrorAction Stop | Out-Null

	Set-OZOScheduledTask -JsonFile $ScheduledConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $ScheduledTaskName) -Message "Set-OZOScheduledTask did not recreate the scheduled test task."

	Remove-OZOScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $ScheduledTaskName)) -Message "Remove-OZOScheduledTask did not remove the scheduled test task."

	# Test New and Remove with a pure AtLogon task
	New-OZOScheduledTask -JsonFile $AtLogonConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $AtLogonTaskName) -Message "New-OZOScheduledTask did not create the AtLogon test task."
	Remove-OZOScheduledTask -TaskName $AtLogonTaskName
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $AtLogonTaskName)) -Message "Remove-OZOScheduledTask did not remove the AtLogon test task."

	Write-Host "OZOTaskScheduler integration tests passed."
} Finally {
	ForEach ($TaskName in @($ScheduledTaskName,$AtLogonTaskName)) {
		If (Test-TaskExists -TaskName $TaskName) {
			Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
		}
	}
}

