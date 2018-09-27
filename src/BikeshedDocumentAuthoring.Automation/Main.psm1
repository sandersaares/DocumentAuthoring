$ErrorActionPreference = "Stop"

# Entry point of the module. Functions listed here can be exported to the user if declared in manifest.

# Adds a comment to a GitHub pull request that contains links to the published output ready for review.
# If a comment that looks like a build report already exists, it is edited instead.
function New-SucceedingGitHubBuildReport() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$organization,

        [Parameter(Mandatory = $true)]
        [string]$repository,

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

        # URL to the ZIP with all the output.
        [Parameter(Mandatory = $true)]
        [string]$zipUrl,

        [Parameter(Mandatory = $true)]
        [string]$authorizationToken,

        # The username of the bot is used to look for an existing build report to edit (instead of posting a new one).
        [Parameter(Mandatory = $true)]
        [string]$botUsername
    )

    $url = "https://api.github.com/repos/$organization/$repository/issues/$issueNumber/comments"

    $encodedHtmlUrl = [Uri]::EscapeDataString($htmlUrl)
    $encodedOldHtmlUrl = [Uri]::EscapeDataString($oldHtmlUrl)
    $diffUrl = "https://services.w3.org/htmldiff?doc1=$encodedOldHtmlUrl&doc2=$encodedHtmlUrl"

    $body = $buildReportTag + "`r`n`r`n"
    $body += "Build was successful. Outputs:`r`n`r`n"
    $body += "* [PDF document]($pdfUrl)`r`n"
    $body += "* [HTML document]($htmlUrl)`r`n"
    $body += "* [HTML diff with target branch]($diffUrl)`r`n`r`n"
    $body += "* [Download PDF + HTML as archive]($zipUrl)`r`n`r`n"
    $body += "This comment will be updated after each build."

    $requestBody = @{
        body = $body
    } | ConvertTo-Json

    $requestHeaders = @{
        Authorization = "token $authorizationToken"
    }

    $existingBuildReportId = FindBuildReportCommentId -organization $organization -repository $repository -issueNumber $issueNumber -authorizationToken $authorizationToken -botUsername $botUsername

    if ($existingBuildReportId) {
        $url += "/$existingBuildReportId"

        Invoke-WebRequest -Uri $url -UseBasicParsing -Method Patch -Body $requestBody -ContentType "application/json" -Headers $requestHeaders
    }
    else {
        Invoke-WebRequest -Uri $url -UseBasicParsing -Method Post -Body $requestBody -ContentType "application/json" -Headers $requestHeaders
    }
}

# Adds a comment to a GitHub pull request that informs the user of a failed build.
# If a comment that looks like a build report already exists, it is edited instead.
function New-FailingGitHubBuildReport() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$organization,

        [Parameter(Mandatory = $true)]
        [string]$repository,

        [Parameter(Mandatory = $true)]
        [int]$issueNumber,

        [Parameter(Mandatory = $true)]
        [string]$authorizationToken,

        # The username of the bot is used to look for an existing build report to edit (instead of posting a new one).
        [Parameter(Mandatory = $true)]
        [string]$botUsername
    )

    $body = $buildReportTag + "`r`n`r`n"
    $body += "Build failed. Outputs are not available if the build fails.`r`n`r`n"

    if ($env:BIKESHEDERROR) {
        # If there was a Bikeshed error, we embed it right in the comment.
        $body += $env:BIKESHEDERROR
        $body += "`r`n`r`n"
    }
    else {
        # Otherwise, we leave info to check the link for details and dig in logs.
        $body += "To see the details of the failure, explore the logs shown when you click on the details link near the bottom or on the red X next to the most recent commit ID.`r`n`r`n"
    }

    $body += "This comment will be updated after each build."

    $requestBody = @{
        body = $body
    } | ConvertTo-Json

    $requestHeaders = @{
        Authorization = "token $authorizationToken"
    }

    $existingBuildReportId = FindBuildReportCommentId -organization $organization -repository $repository -issueNumber $issueNumber -authorizationToken $authorizationToken -botUsername $botUsername

    if ($existingBuildReportId) {
        $url = "https://api.github.com/repos/$organization/$repository/issues/comments/$existingBuildReportId"

        Invoke-WebRequest -Uri $url -UseBasicParsing -Method Patch -Body $requestBody -ContentType "application/json" -Headers $requestHeaders
    }
    else {
        $url = "https://api.github.com/repos/$organization/$repository/issues/$issueNumber/comments"

        Invoke-WebRequest -Uri $url -UseBasicParsing -Method Post -Body $requestBody -ContentType "application/json" -Headers $requestHeaders
    }
}

# Determines the correct publishing directory to name for the outputs from this build, based on
# the current branch and whether this is a PR. This only works if called form a VSTS build process.
function Get-OutputPublishDirectoryName() {
    if ($env:BUILD_REASON -eq "PullRequest") {
        return "pull/$env:SYSTEM_PULLREQUEST_PULLREQUESTNUMBER"
    }
    else {
        return $env:BUILD_SOURCEBRANCHNAME
    }
}

### Below this line is internal logic not exported to user. ###

# PowerShell defaults to TLS 1.0 which is not really accepted these days.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# A post by the bot user that starts with this string is considered a build report.
$buildReportTag = "# Automated build report"

function FindBuildReportCommentId() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$organization,

        [Parameter(Mandatory = $true)]
        [string]$repository,

        [Parameter(Mandatory = $true)]
        [int]$issueNumber,

        [Parameter(Mandatory = $true)]
        [string]$authorizationToken,

        # The username of the bot is used to look for an existing build report to edit (instead of posting a new one).
        [Parameter(Mandatory = $true)]
        [string]$botUsername
    )

    # We only look on the first page (however many GitHub returns to us) for simplicity.
    # The assumption is that the first build should have made a comment pretty quickly,
    # so any existing build report should always be among the first comments.
    $url = "https://api.github.com/repos/$organization/$repository/issues/$issueNumber/comments"

    $requestHeaders = @{
        Authorization = "token $authorizationToken"
    }

    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Headers $requestHeaders
    $comments = $response.Content | ConvertFrom-Json

    $buildReport = $comments | ? { $_.user.login -eq $botUsername -and $_.body -like "$buildReportTag*" } | Select-Object -First 1

    if ($buildReport) {
        return $buildReport.id
    }
    else {
        return $null
    }
}