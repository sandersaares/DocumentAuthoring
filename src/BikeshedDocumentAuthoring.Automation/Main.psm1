$ErrorActionPreference = "Stop"

# Entry point of the module. Functions listed here can be exported to the user if declared in manifest.

# Adds a comment to a GitHub pull request that contains links to the published output ready for review.
function New-GitHubBuildReport() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$organization,

        [Parameter(Mandatory = $true)]
        [int]$repository,

        [Parameter(Mandatory = $true)]
        [int]$issueNumber,

        # URL to the PDF output.
        [Parameter(Mandatory = $true)]
        [string]$pdfUrl,

        # URL to the HTML output.
        [Parameter(Mandatory = $true)]
        [string]$htmlUrl,

        # URL to the HTML output of the previous version (to compare against).
        [Parameter(Mandatory = $true)]
        [string]$oldHtmlUrl,

        [Parameter(Mandatory = $true)]
        [string]$authorizationToken
    )

    $url = "https://api.github.com/repos/$organization/$repository/issues/$issueNumber/comments"

    $body = ""
    $body += "[PDF output]($pdfUrl)`r`n`r`n"
    $body += "[HTML output]($htmlUrl)"

    $requestBody = @{
        body = $body
    } | ConvertTo-Json

    $requestHeaders = @{
        Authorization = "token $authorizationToken"
    }

    # PowerShell defaults to TLS 1.0 which is not really accepted these days.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Invoke-WebRequest -Uri $url -UseBasicParsing -Method POST -Body $requestBody -ContentType "application/json" -Headers $requestHeaders
}