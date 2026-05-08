# NetTCPIP.Linux.psm1
# Dot-source all function files (excluding Pester test files)

Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter '*.ps1' |
    Where-Object { $_.Name -notlike '*.Tests.ps1' } |
    ForEach-Object { . $_.FullName }
