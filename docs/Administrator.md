[Back to table of contents](README.md)

Join **#document-authoring** on Slack: [![Slack Status](https://dashif-slack.azurewebsites.net/badge.svg)](https://dashif-slack.azurewebsites.net)

# Administrator Guide

To set up a new document, follow this guide. You are expected to be casually familiar with GitHub and Azure DevOps.

# Prerequisites

To set up a new document, you need:

* A GitHub repository for the document. This must be owned by an organization (not a personal account).
* A GitHub user with admin rights in the document repository (not your own user account, to limit access to minimum required).
* A GitHub user account with no special rights assigned, for posting automated build reports on pull requests.
* Admin access to an Azure DevOps account to be used for build automation.
* An web server for publishing build output PDF/HTML files and the corresponding FTP/SSH credentials.

All these resources can be reused for multiple documents, except for the repository - each document must be in a separate repository.

# Associate build bot with Azure DevOps

The build bot is the GitHub account with admin rights to the document repository.

You only need to perform this setup once per bot account. If you are reusing an account, simply grant it admin rights to the new repository and skip this section.

Log in to GitHub with this account and add a new Personal Access Token with the following scopes: repo, read:user, user:email, admin:repo_hook.

In Azure DevOps, add a new service connection to the account. Specify GitHub as the type and enter with the token that you just created.

You will need to reference this service connection later, so remember its name.

# Associate comment bot with Azure DevOps

The comment bot is the GitHub account with no special rights assigned.

You only need to perform this setup once per bot account. If you are reusing an account, skip this section.

Log in to GitHub with this account and add a new Personal Access Token with the following scopes: public_repo.

In Azure DevOps, add a new variable group with the following variables:

`GitHubBotUsername` - GitHub username of the account.

`GitHubToken` - the created token. Mark this variable as secret (click the lock icon).

You will need to reference this variable group later, so remember its name.

# Create build definition

Clone an existing document build definition in Azure DevOps and update the following data:

* service connection (in Get Sources task)
* repository name (in Get Sources task)
* comment bot variable group reference (in Variables)
* any other variables listed in the Variables tab

After verifying that all the data is valid for the new document, save the build definition. Automated builds should now be active.

# Assign editors

Give the editors write-level collaborator access to the document repository.