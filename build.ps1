Push-Location $PSScriptRoot

# Prepare
$csc = "$PSScriptRoot\packages\Microsoft.Net.Compilers\tools\csc.exe"
$build = "$PSScriptRoot\build"
$dist = "$PSScriptRoot\dist"
$src = "$PSScriptRoot\src"
New-Item -Path $build, $dist -ItemType 'Directory' -ErrorAction 'SilentlyContinue' | Out-Null
Remove-Item "$build\*", "$dist\*" -Recurse -Force

if ((Get-ChildItem "$PSScriptRoot\packages" -Recurse).Count -eq 0) {
    Write-Host 'Dependencies are missing. Run ''install.ps1''' -ForegroundColor 'DarkRed'
    exit 258
}

# Build
Write-Output 'Compiling shim.cs ...'
$shimCS = @(
    '/deterministic'
    '/optimize'
    '/nologo'
    '/platform:anycpu'
    '/target:exe'
    "/out:""$dist\shim.exe"""
    "$src\shim.cs"

)
& $csc @shimCS

# Checksums
Write-Output 'Computing checksums ...'
Get-ChildItem "$dist\*" -Include '*.exe' -Recurse | ForEach-Object {
    $checksum = (Get-FileHash -Path $_.FullName -Algorithm 'SHA256').Hash.ToLower()
    "$checksum *$($_.Name)" | Tee-Object -FilePath "$dist\$($_.Name).sha256" -Append
}

Pop-Location
