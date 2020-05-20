[Back to table of contents](README.md)

[Join DASH-IF on Slack!](https://join.slack.com/t/dashif/shared_invite/zt-egme869x-JH~UPUuLoKJB26fw7wj3Gg)

# Editor Guide

Editors are the people tasked with the responsibility of reviewing contributions and merging them into the document. This page describes the basic principles of how this is done with a GitHub workflow.

# Accepting contributions

Contributors will create pull requests to submit their contributions for review. Ensure that each pull request gets reviewed when initially submitted and when a round of updates is submitted.

GitHub has two main features available for reviews:

* You can simply add comments into the pull request discussion, essentially equivalent to using e-mails.
* You can use GitHub [pull request reviews](https://help.github.com/articles/about-pull-request-reviews/), which allow comments and replies to be added to individual lines in the contribution, allowing for more fine-grained context to be associated with each comment.

Feel free to use both mechanisms concurrently if you wish. **The process you follow as an editor is largely up to your own free choice. GitHub pull requests are simply communication tools for you to use as you see fit.**

Once a contribution has reached a state where you are comfortable accepting it into the document, use the "Squash and Merge" button in GitHub to merge it.

# Merge conflicts

If GitHub reports that a pull request has merge conflicts, ask the contributor to resolve them. Merge conflicts block merges and automated builds.

# Making editorial changes

You can make editorial changes in the document without having to go through the fork and pull request workflow used by ordinary contributors.

To make an editorial change, simply commit your change directly in the master branch of the main repository. That's it!

# Obtaining build output

Any commit into the master branch will trigger an automated build of the document, with the outputs published to the web on a successful build.

As there is no pull request associated with master branch changes, the build report with links to outputs will not be posted anywhere on GitHub. You can observe the project's Azure DevOps portal to see the build results.

To obtain the published document URLs, simply use `/master/` where you would normally (in case of pull requests) have `/pull/123/`.