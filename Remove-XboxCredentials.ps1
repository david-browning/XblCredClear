# Removes all stored Windows credentials whose target begins with "Xbl".
# This can help when games fail to connect to Xbox Live or repeatedly forget sign-in state.
# Adjust $Pattern if you want to target a different set of Credential Manager entries.

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string]$Pattern = 'Target:\s*(?:LegacyGeneric:target=)?(Xbl.*)$'
)

$cmdkeyOutput = cmdkey /list
$targets = @(
    $cmdkeyOutput |
        Select-String -Pattern $pattern |
        ForEach-Object {
            $_.Matches.Groups[1].Value.Trim()
        }
)

if ($targets.Count -eq 0) {
    Write-Verbose "No Xbl credentials found."
    return
}

Write-Verbose "Found $($targets.Count) Xbl credential(s)."

foreach ($target in $targets) {
    if ($PSCmdlet.ShouldProcess($target, "Delete credential")) {
        Write-Verbose "Deleting credential: $target"
        cmdkey /delete:$target | Out-Null
    }
}
