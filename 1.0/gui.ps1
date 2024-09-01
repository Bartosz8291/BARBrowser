Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the path to the icon file and local HTML file
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$iconPath = Join-Path -Path $scriptDir -ChildPath "guiicon.ico"
$homeHtmlPath = Join-Path -Path $scriptDir -ChildPath "home/index.html"

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "BARBrowser"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"

# Load the custom icon
$form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap $iconPath).GetHicon())

# Create a WebBrowser control
$webBrowser = New-Object System.Windows.Forms.WebBrowser
$webBrowser.Dock = [System.Windows.Forms.DockStyle]::Fill
$webBrowser.ScriptErrorsSuppressed = $true

# Navigate to the default URL (home page)
$webBrowser.Navigate("file:///$homeHtmlPath")

# Create a TextBox for URL input
$urlBox = New-Object System.Windows.Forms.TextBox
$urlBox.Dock = [System.Windows.Forms.DockStyle]::Top
$urlBox.Text = "barbrowser://home"  # Set default URL

# Create a Button to navigate
$goButton = New-Object System.Windows.Forms.Button
$goButton.Dock = [System.Windows.Forms.DockStyle]::Top
$goButton.Text = "Go"

# Add event handler to the button
$goButton.Add_Click({
    $url = $urlBox.Text
    if ($url -match "^barbrowser://") {
        # Handle custom URL scheme
        $path = $url -replace "^barbrowser://", ""
        if ($path -eq "home") {
            $fullPath = "file:///$homeHtmlPath"
        } else {
            $fullPath = $url  # For other custom paths, use the URL as-is
        }
    } elseif ($url -match "^(http|https|file)://") {
        # Handle HTTP, HTTPS, and file URLs
        $fullPath = $url
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid URL starting with http://, https://, or barbrowser://", "Invalid URL", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Navigate and update URL box with custom scheme
    $webBrowser.Navigate($fullPath)
    $urlBox.Text = If ($path -eq "home") { "barbrowser://home" } else { $url }
})

# Create a Panel to hold the URL box and Go button
$topPanel = New-Object System.Windows.Forms.Panel
$topPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$topPanel.Height = 40
$topPanel.Controls.Add($urlBox)
$topPanel.Controls.Add($goButton)

# Add controls to the form
$form.Controls.Add($webBrowser)
$form.Controls.Add($topPanel)

# Event handler for navigating links
$webBrowser.Add_Navigated({
    param ($sender, $e)
    # Update URL box to reflect current URL
    $currentUrl = $webBrowser.Url.AbsoluteUri
    if ($currentUrl -eq "file:///$homeHtmlPath") {
        $urlBox.Text = "barbrowser://home"
    } else {
        $urlBox.Text = $currentUrl
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
