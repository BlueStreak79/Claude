# Blue Toolkit

One modular PowerShell toolkit built from the Setup, Setup-v2.0, Winget, Windows-Settings,
Diagnostics, Network-Diagnostics and Test repos.

## Run
Open PowerShell and run (it elevates itself):

    .\Run.ps1                    # menu
    .\Run.ps1 -List              # task keys
    .\Run.ps1 -Task full-setup   # one task, then exit
    .\Run.ps1 -Task oem-report   # show firmware OEM key + license state, change nothing

If scripts are blocked:  `powershell -ExecutionPolicy Bypass -File .\Run.ps1`

## Layout
    Run.ps1            entry point + menu
    config.json        URLs, SHA256 pins, settings, winget list, hosts list, diagnostics tools
    lib\Common.ps1     logging, elevation, verified downloads, step results, task registry
    modules\           00 FullSetup, 10 Winget, 20 Apps, 30 Settings, 40 OemLicense,
                       50 Diagnostics, 60 Network, 70 HostsFile  (numeric prefix = menu order)
    custom\            your own .ps1 files - see custom\README.txt

## Things to fill in (config.json)
- `sha256` on every asset/tool: empty means "download is unverified" (a warning is logged).
- `debloat.url`: the old `git.io/debloat` short link was left out; paste the real script URL + hash.
- `winrar.keyPath`: path to a key file you supply; nothing is bundled.
- `winget.packages`: winget IDs to install after the installers finish.
- `hosts.domains`: domains for the optional hosts-file block.

## Logs
`%TEMP%\Toolkit\logs\toolkit_YYYYMMDD.log`

## Status
Written and statically checked only (balanced syntax, ASCII-only, all calls resolve).
It has NOT been executed on a Windows machine - test on a throwaway VM first.
