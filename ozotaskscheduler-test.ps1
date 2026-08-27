#Requires -Modules OZOTaskScheduler,OZOLogger -RunAsAdministrator

# VARIABLES
[String] $TempDir = (Join-Path -Path $Env:SYSTEMDRIVE -ChildPath "Temp")

# MAIN
# Ensure the temporary directory exists
New-Item -ItemType Directory -Path $TempDir -Force
# Copy the AtLogonTask example files to the temporary directory
Copy-Item -Path ".\Documentation\OZOTaskScheduler-AtLogonTask-Example.json" -Destination $TempDir -Force
Copy-Item -Path ".\Documentation\OZOTaskScheduler-AtLogonTask-Example.ps1" -Destination $TempDir -Force
# Copy the ScheduledTask example files to the temporary directory
Copy-Item -Path ".\Documentation\OZOTaskScheduler-ScheduledTask-Example.json" -Destination $TempDir -Force
Copy-Item -Path ".\Documentation\OZOTaskScheduler-ScheduledTask-Example.ps1" -Destination $TempDir -Force

