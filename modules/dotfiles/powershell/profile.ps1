# Local user bin
$env:PATH = "$env:HOME/.local/bin:$env:PATH"

# Shared library path
$env:LD_LIBRARY_PATH = "/usr/local/lib:$env:LD_LIBRARY_PATH"

# Set editor to vim...
$env:EDITOR = "vim"

# ...but make vim point to nvim
Set-Alias vim nvim

# Suggestions are rendered in a drop-down list.
# Disabled for now because it makes ssh connections hang (?)
# Set-PSReadLineOption -PredictionViewStyle ListView

# Enable predictive Intellisense.
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# Show me the Information stream by default
$InformationActionPreference = "Continue"

# Use starship prompt.
Invoke-Expression (& starship init powershell)

# Keep the native process cwd in sync with PowerShell's location so tmux's
# #{pane_current_path} (read from /proc/<pid>/cwd) reflects the directory we cd'd to.
$ExecutionContext.InvokeCommand.LocationChangedAction = {
    [System.IO.Directory]::SetCurrentDirectory($PWD.ProviderPath)
}
