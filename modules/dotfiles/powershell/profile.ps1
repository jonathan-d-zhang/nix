# Import up front instead of letting PowerShell autoload them on first use.
# Autoload goes through command discovery, which scans every $PATH entry, which
# can be slow when inheriting Windows paths in WSL.
Import-Module Microsoft.PowerShell.Management, Microsoft.PowerShell.Utility, PSReadLine

# Local user bin
$env:PATH = "$env:HOME/.local/bin:$env:PATH"

# Shared library path. Guarded: interpolating an unset LD_LIBRARY_PATH leaves a
# trailing colon, and an empty entry means "search the current directory".
$env:LD_LIBRARY_PATH = if ($env:LD_LIBRARY_PATH) { "/usr/local/lib:$env:LD_LIBRARY_PATH" } else { "/usr/local/lib" }

# Set editor to vim...
$env:EDITOR = "vim"

# ...but make vim point to nvim
Set-Alias vim nvim

$PSReadLineOptions = @{
    # Suggestions are rendered in a drop-down list.
    # Disabled for now because it makes ssh connections hang (?)
    # PredictionViewStyle = "ListView"

    # Enable predictive Intellisense.
    PredictionSource = "HistoryAndPlugin"

    # Remember everything
    MaximumHistoryCount = 1000000

    # Key bindings emulate Vi
    EditMode = "Vi"
}
Set-PSReadLineOption @PSReadLineOptions

# Show me the Information stream by default
$InformationActionPreference = "Continue"

# Use starship prompt.
# Invoke-Expression (& starship init powershell)

# jj completions
if (Get-Command jj -ErrorAction Ignore) {
    $env:COMPLETE = "powershell"
    jj | Out-String | Invoke-Expression
    $env:COMPLETE = $null
}

# Keep the native process cwd in sync with PowerShell's location so tmux's
# #{pane_current_path} (read from /proc/<pid>/cwd) reflects the directory we cd'd to.
$ExecutionContext.InvokeCommand.LocationChangedAction = {
    [System.IO.Directory]::SetCurrentDirectory($PWD.ProviderPath)
}

# Define these in a submodule to only expose the prompt
New-Module -Name ProfileHelpers -ScriptBlock {

# `& <cmd>` on a missing binary raises CommandNotFoundException, which 2>$null
# does not suppress -- and every miss re-scans $PATH (~1.5s here, never cached),
# which the prompt would pay on each render. Probe once instead: ~3ms if present.
$hasJj = [bool](Get-Command jj -ErrorAction Ignore)
$hasGit = [bool](Get-Command git -ErrorAction Ignore)

# Pull "<n> insertion"/"<n> deletion" out of a --stat summary line. Both
# clauses are omitted entirely when their count is zero.
function num($line, $word) {
    if ($line -match "(\d+) $word") { [int]$Matches[1] } else { 0 }
}

function vcsStat($nameStatusLines, $summaryLine) {
    $deleted = $false
    $added = $false
    foreach ($line in $nameStatusLines) {
        switch ($line.Substring(0, 1)) {
            "D" {$deleted = $true}
            "A" {$added = $true}
        }
        if ($deleted -and $added) {
            break
        }
    }

    $status = ""
    if ($deleted) {
        $status += "X"
    }
    if ($added) {
        $status += "+"
    }

    $additions = num $summaryLine "insertion"
    $deletions = num $summaryLine "deletion"

    if ($additions -eq 0 -and $deletions -eq 0) {
        $addDel = ""
    } elseif ($additions -eq 0) {
        $addDel = "[-$deletions]"
    } elseif ($deletions -eq 0) {
        $addDel = "[+$additions]"
    } else {
        $addDel = "[+$additions -$deletions]"
    }

    $segments = @()
    if (-not [string]::IsNullOrEmpty($addDel)) {
        $segments += $addDel
    }
    if (-not [string]::IsNullOrEmpty($status)) {
        $segments += "[$status]"
    }
    return $segments -join " "
}

function jjInfo {
    $nameStatus = jj diff -r "tracked_remote_bookmarks()..@" -s
    $hist = jj diff -r "tracked_remote_bookmarks()..@" --stat
    # Select-Object, not [-1]: --stat prints nothing at all when there is no
    # diff, and indexing into $null throws.
    return vcsStat $nameStatus ($hist | Select-Object -Last 1)
}

function gitInfo {
    # Diff against HEAD, not the index, so staged changes still show up --
    # matches jjInfo, which diffs everything against the remote bookmark.
    $nameStatus = git diff HEAD --name-status
    $hist = git diff HEAD --stat
    $stat = vcsStat $nameStatus ($hist | Select-Object -Last 1)
    return (@(" $(git branch --show-current)", $stat) | Where-Object { $_ }) -join " "
}

function vcsInfo {
    # Check for .jj or .git in this or parent dirs and return status info if
    # found

    if ($hasJj) {
        $root = & jj root 2>$null
        if ($?) {
            return @{
                RepoRoot = $root
                VcsInfo = jjInfo
            }
        }
    }

    if ($hasGit) {
        $root = & git rev-parse --show-toplevel 2>$null
        if ($?) {
            return @{
                RepoRoot = $root
                VcsInfo = gitInfo
            }
        }
    }

    return $null
}

function prompt {
    <#
    Segments: pwd, VCS info

    pwd:
        relative path from repository root, determined by existence of .git or .jj
        if no repo root, show up to 3 path segments
        can be shortened if terminal width is an issue
        replace $env:HOME with "~"
    VCS info:
        jj prioritized over git
        if jj: show lines added/deleted, status
        if git: show branch, lines added/deleted, status
    #>

    $terminalWidth = $Host.UI.RawUI.WindowSize.Width

    $segments = @()

    $vcs = vcsInfo

    $cwd = (Get-Location).Path
    if ($null -ne $vcs) {
        $repoRoot = $vcs["RepoRoot"]

        $cwd = Resolve-Path $cwd -Relative -RelativeBasePath (Join-Path $repoRoot "..")

        $segments += $cwd
        $segments += $vcs["VcsInfo"]
    } else {
        if ($cwd.StartsWith($env:HOME)) {
            $cwd = "~$($cwd.Remove(0, $env:HOME.Length))"
        }
        $segments += $cwd
    }

    $segments += "> "

    return "$([System.Environment]::NewLine)$(($segments | Where-Object { $_ }) -join " ")"
}

Export-ModuleMember -Function prompt

} | Import-Module -Global
