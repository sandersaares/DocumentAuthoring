[Back to table of contents](README.md)

# Contributor Guide

This guide walks you through the steps needed to contribute new content or changes to a document.

GitHub is used as the service that organizes and synchronizes work by multiple contributors and editors. You will need to familiarize yourself with GitHub and Git working processes.

This guide only presents a high level overview. You are expected to explore [GitHub Help](https://help.github.com/) to learn the details of any Git operations that are unfamiliar to you.

# Initial state

There exists a GitHub repository in the document owner's GitHub account. The master branch of this repository contains all the files used to generate the document.

![](Diagrams/GitHubConcepts1-Original.png)

Your contribution will become a part of the document when it is present in this master branch. The workflow described on this page is designed to make that happen.

# Your contribution goes into a fork

A fork is a personal copy of a repository. Create a fork on GitHub to start the contributing process.

![](Diagrams/GitHubConcepts2-Changes.png)

Change the contents of the master branch of your fork to reflect your contribution and commit the changes into the downstream repository.

# You can work either online or offline

The GitHub website enables you to perform basic editing online, without the need for any software installation or manual Git operation. The downside is that the editor functionality is very limited.

While various GUIs for working with Git exist, none of them can be said to be intuitive or particularly user-friendly. If you are not comfortable using Git commands from the command line, you are recommended to use the online editor where possible.

To work offline you must clone your fork onto your workstation. This creates a copy that must later be explicitly synchronized with the copy in GitHub using Git commands.

![](Diagrams/GitHubConcepts3-Offline.png)

After cloning, perform any desired edits, commit the changes and perform a Git push to copy the committed changes to the online repository. A Git pull is a related operation - perform a pull to copy any online changes to the offline clone.

Tip: [GitHub Desktop](https://desktop.github.com/) is an app that simplifies many common Git operations when working with an offline clone. You can freely mix GitHub Desktop and command-line Git operations, only using the latter when the former does not support your use case.

# Submit a pull request when ready

Once you have adjusted the contents of your fork to include your contribution, [submit a Pull Request](https://help.github.com/articles/creating-a-pull-request-from-a-fork/) in the document owner's repository. In the pull request, reference the upstream repository as "base" and the downstream repository as "head".

![](Diagrams/GitHubConcepts4-PR.png)

A pull request is a request for the editors of the document to review your contribution and merge it into the upstream repository. You will likely receive comments and requests for changes. Any changes you make in your fork are immediately reflected in the pull request - there is no need for any action to submit updates. However, a comment in the pull request is customary after any updates in order to notify editors that the contribution is ready for the next review round.

Submitting a pull request triggers an automated build of the document. Once the build has completed, links to generated output files will be posted in the pull request comments.

# How to see the output before the contribution is ready?

The repository only contains the source code of the document and not the final PDF and HTML output. For any non-trivial changes, you will want to verify that the formatting looks good and that there are no broken links.

There are two methods for seeing the output of your contribution during authoring:

1. Install the document compiler on your workstation and invoke the build process. Refer to the [Content Guide](Content.md) for details on invoking the compiler.
1. Create a pull request even before your contribution is ready. Upon pull request creation or update, an automated build process will generate the outputs and post links in the pull request comments. **Mark the pull request as work in progress in the pull request description**, so it does not get prematurely reviewed or rejected!

# What if the upstream repository changes?

Your fork does not automatically receive updates made to the upstream repository.

If your contribution provides only non-conflicting changes, it can be merged by an editor immediately after review even if your fork lacks the latest updates.

If your contribution conflicts with new changes made to the upstream repository then you will need to [merge changes from upstream](https://help.github.com/articles/merging-an-upstream-repository-into-your-fork/) and create a new commit that [resolves any merge conflicts](https://help.github.com/articles/addressing-merge-conflicts/) before the contribution can be accepted.

# Advanced Git usage

This guide provides a simple workflow designed to make the process easy for contributors that are not very familiar with Git workflows. If you are an experienced Git user then feel free to deviate from the above instructions and use advanced Git features not mentioned here (e.g. multiple branches).