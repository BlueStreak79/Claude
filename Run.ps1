<#
.SYNOPSIS
    Toolkit entry point. Loads lib\, modules\ and custom\ and shows a menu.

.EXAMPLE
    .\Run.ps1                      # interactive menu
    .\Run.ps1 -List                # list task keys
    .\Run.ps1 -Task full-setup     # run one task and exit
#>
[CmdletBinding()]
param(
    [string]$Task,
    [switch]$List,
    [switch]$NoElevate
)

$root = $PSScriptRoot
. (Join-Path $root 'lib\Common.ps1')

if (-not $NoElevate -and -not (Test-IsAdmin)) {
    $extra = @()
    if ($Task) { $extra += @('-Task', $Task) }
    if ($List) { $extra += '-List' }
    Invoke-SelfElevate -ScriptPath $PSCommandPath -ArgList $extra
    return
}

# Built-in modules first (numeric prefix = menu order), then your own custom\ files.
foreach ($f in (Get-ChildItem -Path (Join-Path $root 'modules') -Filter '*.ps1' | Sort-Object Name)) { . $f.FullName }
$customDir = Join-Path $root 'custom'
if (Test-Path $customDir) {
    foreach ($f in (Get-ChildItem -Path $customDir -Filter '*.ps1' | Sort-Object Name)) {
        try { . $f.FullName }
        catch { Write-Log ("custom\{0} failed to load: {1}" -f $f.Name, $_.Exception.Message) 'ERROR' }
    }
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host '==================================' -ForegroundColor Cyan
        Write-Host '          BLUE TOOLKIT            ' -ForegroundColor Cyan
        Write-Host '==================================' -ForegroundColor Cyan
        $i = 0
        $map = @{}
        foreach ($t in $script:Tasks.Values) {
            $i++
            $map["$i"] = $t
            Write-Host ("{0,3}  {1}" -f $i, $t.Name)
        }
        Write-Host '  0  Exit'
        $c = Read-Host 'Select'
        if ($c -eq '0') { return }
        if ($map.ContainsKey($c)) {
            Invoke-ToolkitTask -Key $map[$c].Key
            Show-Summary
        } else {
            Write-Log 'Invalid selection' 'WARN'
        }
        Read-Host 'Press ENTER to return to the menu' | Out-Null
    }
}

if ($List) {
    $script:Tasks.Values | ForEach-Object { "{0,-18} {1}" -f $_.Key, $_.Name }
}
elseif ($Task) {
    Invoke-ToolkitTask -Key $Task
    Show-Summary
    Read-Host 'Press ENTER to close' | Out-Null
}
else {
    Show-MainMenu
}
