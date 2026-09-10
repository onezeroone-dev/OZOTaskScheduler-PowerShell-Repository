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
[String] $OnceOnlyTaskName = "OZOTaskScheduler Integration OnceOnly"
[String] $InvalidSchedulesTaskName = "OZOTaskScheduler Integration InvalidSchedules"
[String] $NoTriggersTaskName = "OZOTaskScheduler Integration NoTriggers"
[String] $AtLogonWithScheduledTaskName = "OZOTaskScheduler Integration AtLogonWithScheduled"
[String[]] $AllTestTaskNames = @($ScheduledTaskName,$AtLogonTaskName,$OnceOnlyTaskName,$InvalidSchedulesTaskName,$NoTriggersTaskName,$AtLogonWithScheduledTaskName)
[String] $ScheduledConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-Scheduled.json")
[String] $AtLogonConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-AtLogon.json")
[String] $OnceOnlyConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-OnceOnly.json")
[String] $InvalidSchedulesConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-InvalidSchedules.json")
[String] $NoTriggersConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-NoTriggers.json")
[String] $AtLogonWithScheduledConfigPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-AtLogonWithScheduled.json")
[String] $ExportPath = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-Integration-Export.json")
# Compute a OnceDateTime value relative to today so the tests do not go stale as the example fixture's date passes
[String] $FutureDateTime = (Get-Date).AddDays(21).ToString("yyyy-MM-ddTHH:mm:ss")

Try {
	# Ensure the temporary directory exists and stage the example assets
	New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
	Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-AtLogonTask-Example.ps1") -Destination $TempDir -Force
	Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.ps1") -Destination $TempDir -Force

	# Create test-specific configurations that point to the staged script assets
	$ScheduledConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.json") -Raw | ConvertFrom-Json
	$ScheduledConfig.Name = $ScheduledTaskName
	$ScheduledConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-ScheduledTask-Example.ps1")
	$ScheduledConfig.OnceDateTime.DateTime = $FutureDateTime
	$ScheduledConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $ScheduledConfigPath

	$AtLogonConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-AtLogonTask-Example.json") -Raw | ConvertFrom-Json
	$AtLogonConfig.Name = $AtLogonTaskName
	$AtLogonConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-AtLogonTask-Example.ps1")
	$AtLogonConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $AtLogonConfigPath

	# A Once-only configuration with no Scheduled or AtReboot triggers
	$OnceOnlyConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.json") -Raw | ConvertFrom-Json
	$OnceOnlyConfig.Name = $OnceOnlyTaskName
	$OnceOnlyConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-ScheduledTask-Example.ps1")
	$OnceOnlyConfig.OnceDateTime.DateTime = $FutureDateTime
	$OnceOnlyConfig.Scheduled = $false
	$OnceOnlyConfig.Schedules = @()
	$OnceOnlyConfig.AtReboot = $false
	$OnceOnlyConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $OnceOnlyConfigPath

	# An invalid configuration: Scheduled is enabled but no Schedules are defined
	$InvalidSchedulesConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.json") -Raw | ConvertFrom-Json
	$InvalidSchedulesConfig.Name = $InvalidSchedulesTaskName
	$InvalidSchedulesConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-ScheduledTask-Example.ps1")
	$InvalidSchedulesConfig.Schedules = @()
	$InvalidSchedulesConfig.Once = $false
	$InvalidSchedulesConfig.AtReboot = $false
	$InvalidSchedulesConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $InvalidSchedulesConfigPath

	# An invalid configuration: no triggers are enabled at all
	$NoTriggersConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.json") -Raw | ConvertFrom-Json
	$NoTriggersConfig.Name = $NoTriggersTaskName
	$NoTriggersConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-ScheduledTask-Example.ps1")
	$NoTriggersConfig.Scheduled = $false
	$NoTriggersConfig.Schedules = @()
	$NoTriggersConfig.Once = $false
	$NoTriggersConfig.AtReboot = $false
	$NoTriggersConfig.AtLogon = $false
	$NoTriggersConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $NoTriggersConfigPath

	# A configuration combining AtLogon with Scheduled to confirm Scheduled takes precedence
	$AtLogonWithScheduledConfig = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Documentation\OZOTaskScheduler-ScheduledTask-Example.json") -Raw | ConvertFrom-Json
	$AtLogonWithScheduledConfig.Name = $AtLogonWithScheduledTaskName
	$AtLogonWithScheduledConfig.Script = (Join-Path -Path $TempDir -ChildPath "OZOTaskScheduler-ScheduledTask-Example.ps1")
	$AtLogonWithScheduledConfig.AtLogon = $true
	$AtLogonWithScheduledConfig.Once = $false
	$AtLogonWithScheduledConfig.AtReboot = $false
	$AtLogonWithScheduledConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $AtLogonWithScheduledConfigPath

	# Import the module source under test rather than an installed version
	Import-Module -Name $ModulePath -Force -ErrorAction Stop

	# Remove tasks left by an interrupted prior test run
	ForEach ($TaskName in $AllTestTaskNames) {
		If (Test-TaskExists -TaskName $TaskName) {
			Remove-OZOScheduledTask -TaskName $TaskName
		}
	}

	# Test New, Get, Enable, Disable, Export, Set, and Remove with a scheduled task
	New-OZOScheduledTask -JsonFile $ScheduledConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $ScheduledTaskName) -Message "New-OZOScheduledTask did not create the scheduled test task."

	# Verify the Settings configuration was applied to the registered task
	$NativeTask = Get-ScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition ($NativeTask.Settings.Compatibility -eq "Win8") -Message "New-OZOScheduledTask did not apply Settings.Compatibility."
	Assert-Condition -Condition ($NativeTask.Settings.RunOnlyIfNetworkAvailable -eq $false) -Message "New-OZOScheduledTask did not apply Settings.RunOnlyIfNetworkAvailable."
	Assert-Condition -Condition ($NativeTask.Settings.DisallowStartIfOnBatteries -eq $false) -Message "New-OZOScheduledTask did not apply Settings.DisallowStartIfOnBatteries."
	Assert-Condition -Condition ($NativeTask.Settings.StopIfGoingOnBatteries -eq $false) -Message "New-OZOScheduledTask did not apply Settings.DontStopIfGoingOnBatteries."
	Assert-Condition -Condition ($NativeTask.Settings.ExecutionTimeLimit -eq "PT0S") -Message "New-OZOScheduledTask did not apply Settings.ExecutionTimeLimit."
	Assert-Condition -Condition ($NativeTask.Settings.DeleteExpiredTaskAfter -eq "PT0S") -Message "New-OZOScheduledTask did not apply Settings.DeleteExpiredTaskAfter."
	Assert-Condition -Condition ($NativeTask.Settings.IdleSettings.StopOnIdleEnd -eq $false) -Message "New-OZOScheduledTask did not apply Settings.IdleSettings.StopOnIdleEnd."
	Assert-Condition -Condition ($NativeTask.Settings.MultipleInstances -eq "IgnoreNew") -Message "New-OZOScheduledTask did not apply Settings.MultipleInstances."
	Assert-Condition -Condition ($NativeTask.Settings.Priority -eq 7) -Message "New-OZOScheduledTask did not apply Settings.Priority."

	# Verify the weekly Schedules were each created as a separate trigger
	$WeeklyTriggers = $NativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskWeeklyTrigger" }
	Assert-Condition -Condition ($WeeklyTriggers.Count -eq 3) -Message "New-OZOScheduledTask did not create one weekly trigger per Schedules entry."
	Assert-Condition -Condition ((($WeeklyTriggers.DaysOfWeek | Sort-Object) -join ",") -eq "2,8,32") -Message "New-OZOScheduledTask did not create triggers for the expected weekdays."

	# Verify the Once trigger was also created alongside the weekly and boot triggers
	$OnceTrigger = $NativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskTimeTrigger" }
	Assert-Condition -Condition ($null -ne $OnceTrigger) -Message "New-OZOScheduledTask did not create the Once trigger alongside Scheduled and AtReboot."
	Assert-Condition -Condition (($NativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskBootTrigger" }).Count -eq 1) -Message "New-OZOScheduledTask did not create the AtReboot trigger alongside Scheduled and Once."

	$ScheduledTask = Get-OZOScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition ($ScheduledTask.Name -eq $ScheduledTaskName) -Message "Get-OZOScheduledTask did not return the scheduled test task."
	Assert-Condition -Condition ($ScheduledTask.Settings.RunOnlyIfNetworkAvailable -eq $false) -Message "Get-OZOScheduledTask did not populate Settings.RunOnlyIfNetworkAvailable."
	Assert-Condition -Condition ($ScheduledTask.Settings.IdleSettings.StopOnIdleEnd -eq $false) -Message "Get-OZOScheduledTask did not populate Settings.IdleSettings.StopOnIdleEnd."

	# Verify GetExistingTask() round-trips the trigger model, not just Settings
	Assert-Condition -Condition ($ScheduledTask.Scheduled -eq $true) -Message "Get-OZOScheduledTask did not populate Scheduled."
	Assert-Condition -Condition ($ScheduledTask.OZOSchedules.Count -eq 3) -Message "Get-OZOScheduledTask did not populate all three OZOSchedules."
	Assert-Condition -Condition ((($ScheduledTask.OZOSchedules | ForEach-Object { $_.WeekDay } | Sort-Object) -join ",") -eq "Friday,Monday,Wednesday") -Message "Get-OZOScheduledTask populated the wrong weekdays."
	Assert-Condition -Condition ($ScheduledTask.Once -eq $true) -Message "Get-OZOScheduledTask did not populate Once."
	Assert-Condition -Condition ($ScheduledTask.OnceDateTime.Valid -eq $true) -Message "Get-OZOScheduledTask did not populate a valid OnceDateTime."
	Assert-Condition -Condition ($ScheduledTask.AtReboot -eq $true) -Message "Get-OZOScheduledTask did not populate AtReboot."

	$EnabledTask = Enable-OZOScheduledTask -TaskName $ScheduledTaskName -PassThru
	Assert-Condition -Condition ((Get-ScheduledTask -TaskName $ScheduledTaskName).Settings.Enabled -eq $true) -Message "Enable-OZOScheduledTask did not enable the scheduled test task."
	Assert-Condition -Condition ($EnabledTask.Disabled -eq $false) -Message "Enable-OZOScheduledTask -PassThru did not return the enabled task."

	$DisabledTask = Disable-OZOScheduledTask -TaskName $ScheduledTaskName -PassThru
	Assert-Condition -Condition ((Get-ScheduledTask -TaskName $ScheduledTaskName).Settings.Enabled -eq $false) -Message "Disable-OZOScheduledTask did not disable the scheduled test task."
	Assert-Condition -Condition ($DisabledTask.Disabled -eq $true) -Message "Disable-OZOScheduledTask -PassThru did not return the disabled task."

	Export-OZOScheduledTask -TaskName $ScheduledTaskName -OutFile $ExportPath
	Assert-Condition -Condition (Test-Path -Path $ExportPath) -Message "Export-OZOScheduledTask did not create the export file."
	$ExportedConfig = Get-Content -Path $ExportPath -Raw | ConvertFrom-Json -ErrorAction Stop
	Assert-Condition -Condition ($ExportedConfig.Settings.Compatibility -eq "Win8") -Message "Export-OZOScheduledTask did not include Settings.Compatibility."
	Assert-Condition -Condition ($ExportedConfig.Settings.ExecutionTimeLimit -eq "PT0S") -Message "Export-OZOScheduledTask did not include Settings.ExecutionTimeLimit."

	Set-OZOScheduledTask -JsonFile $ScheduledConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $ScheduledTaskName) -Message "Set-OZOScheduledTask did not recreate the scheduled test task."
	$UpdatedTask = Set-OZOScheduledTask -JsonFile $ScheduledConfigPath -PassThru
	Assert-Condition -Condition ($UpdatedTask.Name -eq $ScheduledTaskName) -Message "Set-OZOScheduledTask -PassThru did not return the updated task."

	Remove-OZOScheduledTask -TaskName $ScheduledTaskName
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $ScheduledTaskName)) -Message "Remove-OZOScheduledTask did not remove the scheduled test task."

	# Test New and Remove with a pure AtLogon task
	New-OZOScheduledTask -JsonFile $AtLogonConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $AtLogonTaskName) -Message "New-OZOScheduledTask did not create the AtLogon test task."
	Remove-OZOScheduledTask -TaskName $AtLogonTaskName
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $AtLogonTaskName)) -Message "Remove-OZOScheduledTask did not remove the AtLogon test task."

	# Test that -WhatIf prevents New-OZOScheduledTask from creating a task
	New-OZOScheduledTask -JsonFile $OnceOnlyConfigPath -WhatIf
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $OnceOnlyTaskName)) -Message "New-OZOScheduledTask -WhatIf created a task when it should not have."

	# Test a Once-only configuration (no Scheduled or AtReboot triggers) and verify -PassThru
	$OnceOnlyTask = New-OZOScheduledTask -JsonFile $OnceOnlyConfigPath -PassThru
	Assert-Condition -Condition (Test-TaskExists -TaskName $OnceOnlyTaskName) -Message "New-OZOScheduledTask did not create the Once-only test task."
	Assert-Condition -Condition ($OnceOnlyTask.Name -eq $OnceOnlyTaskName) -Message "New-OZOScheduledTask -PassThru did not return the created task."
	$OnceOnlyNativeTask = Get-ScheduledTask -TaskName $OnceOnlyTaskName
	$OnceOnlyTriggers = $OnceOnlyNativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskTimeTrigger" }
	Assert-Condition -Condition ($OnceOnlyTriggers.Count -eq 1) -Message "New-OZOScheduledTask did not create exactly one Once trigger."
	Assert-Condition -Condition (([DateTime]$OnceOnlyTriggers[0].StartBoundary) -eq ([DateTime]$FutureDateTime)) -Message "New-OZOScheduledTask did not apply the expected OnceDateTime."
	Assert-Condition -Condition (($OnceOnlyNativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskWeeklyTrigger" }).Count -eq 0) -Message "New-OZOScheduledTask created weekly triggers for a Once-only configuration."
	Assert-Condition -Condition (($OnceOnlyNativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskBootTrigger" }).Count -eq 0) -Message "New-OZOScheduledTask created a boot trigger for a Once-only configuration."

	# Test that -WhatIf prevents Remove-OZOScheduledTask from removing a task
	Remove-OZOScheduledTask -TaskName $OnceOnlyTaskName -WhatIf
	Assert-Condition -Condition (Test-TaskExists -TaskName $OnceOnlyTaskName) -Message "Remove-OZOScheduledTask -WhatIf removed a task when it should not have."
	Remove-OZOScheduledTask -TaskName $OnceOnlyTaskName
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $OnceOnlyTaskName)) -Message "Remove-OZOScheduledTask did not remove the Once-only test task."

	# Test that invalid configurations are rejected rather than silently creating a task
	New-OZOScheduledTask -JsonFile $InvalidSchedulesConfigPath
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $InvalidSchedulesTaskName)) -Message "New-OZOScheduledTask created a task from an invalid Scheduled configuration with no Schedules."

	New-OZOScheduledTask -JsonFile $NoTriggersConfigPath
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $NoTriggersTaskName)) -Message "New-OZOScheduledTask created a task with no triggers enabled."

	# Test that Scheduled takes precedence over AtLogon and no logon trigger is created
	New-OZOScheduledTask -JsonFile $AtLogonWithScheduledConfigPath
	Assert-Condition -Condition (Test-TaskExists -TaskName $AtLogonWithScheduledTaskName) -Message "New-OZOScheduledTask did not create the AtLogon+Scheduled test task."
	$AtLogonWithScheduledNativeTask = Get-ScheduledTask -TaskName $AtLogonWithScheduledTaskName
	Assert-Condition -Condition (($AtLogonWithScheduledNativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskLogonTrigger" }).Count -eq 0) -Message "AtLogon trigger was created even though Scheduled was also enabled."
	Assert-Condition -Condition (($AtLogonWithScheduledNativeTask.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskWeeklyTrigger" }).Count -eq 3) -Message "Scheduled triggers were not created when combined with AtLogon."
	Remove-OZOScheduledTask -TaskName $AtLogonWithScheduledTaskName
	Assert-Condition -Condition (-Not (Test-TaskExists -TaskName $AtLogonWithScheduledTaskName)) -Message "Remove-OZOScheduledTask did not remove the AtLogon+Scheduled test task."

	Write-Host "OZOTaskScheduler integration tests passed."
} Finally {
	ForEach ($TaskName in $AllTestTaskNames) {
		If (Test-TaskExists -TaskName $TaskName) {
			Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
		}
	}
}

