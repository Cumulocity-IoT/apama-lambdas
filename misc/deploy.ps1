param (
   [string]$sagInstallDir = (& "$PSScriptRoot\getSagInstallDir"),
   [string]$output = "$PSScriptRoot\output\Lambdas"
)

$temp = Read-Host "Where is your SoftwareAG install folder? (blank=$sagInstallDir)"

if (-not $temp) {} else {
	$sagInstallDir = $temp;
}

$apamaInstallDir = "$sagInstallDir\Apama"
if (-not (Test-Path $apamaInstallDir)) {
	Throw "Could not find Apama Installation"
}

$steFile = cat "$PSScriptRoot\template.ste"
$steFile = $steFile | %{$_ -replace "<%LAMBDAS_HOME%>",(Resolve-Path "$PSScriptRoot\..")}

$steFile | Out-File -encoding utf8 "$sagInstallDir/Designer/extensions/lambdas.ste"

Read-Host -Prompt "Done! Please restart designer. Press Return to exit..."