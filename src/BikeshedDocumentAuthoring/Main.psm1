$ErrorActionPreference = "Stop"

# Entry point of the module. Functions listed here can be exported to the user if declared in manifest.

function Invoke-DocumentCompiler() {
    [CmdletBinding()]
    param(
        # Path to the Bikeshed file to build. If null, will look for a single file in current directory.
        # The file extension must match $defaultFileExtension for auto-detection of input to work.
        [Parameter()]
        [string]$path,

        # If provided, will ignore Bikeshed syntax errors and output whatever HTML it can.
        # This is useful for troubleshooting because Bikeshed errors can sometimes be rather vague.
        [Parameter()]
        [switch]$force
    )

    $externals = PrepareExternals

    $inputFile = ResolveInputFile $path
    Write-Host "Building Bikeshed document: $($inputFile.FullName)"

    $workspaceRootPath = Split-Path -Parent $inputFile.FullName
    $basename = DetermineBasename $inputFile.FullName

    # Output goes into "Output/" directory relative to input file.
    $outputPath = Join-Path $workspaceRootPath "Output"
    Write-Verbose "Will generate output in $outputPath."

    # Images come from "Images/" directory relative to input file.
    $imagesPath = Join-Path $workspaceRootPath "Images"
    Write-Verbose "Expending to find images in $imagesPath."

    PrepareOutputDirectory $outputPath
    CopyImages $outputPath $imagesPath

    # We will build all diagrams that exist in a Diagrams folder relative to the input document.
    $diagramsPath = Join-Path $workspaceRootPath "Diagrams"

    BuildDiagrams $outputPath $diagramsPath $externals

    $htmlFilePath = BuildBikeshedDocument $outputPath $inputFile $basename $force
    $pdfFilePath = BuildPdf $outputPath $htmlFilePath $basename $externals
    $zipFilePath = BuildZip $outputPath $basename

    Write-Host "Build completed."

    return @{
        htmlFilePath = $htmlFilePath
        pdfFilePath  = $pdfFilePath
        zipFilePath  = $zipFilePath
    }
}

### Below this line is internal logic not exported to user. ###

# To preserve syntax coloring, we use ".md" final extension.
# To specifically point out Bikeshed, we also put .bs there.
# We process any files, this is just the default we search for during input auto-detection.
$defaultFileExtension = ".bs.md"

# This will setup all the external tools that we use (if not already done so)
# and return a structure with paths to all of them, for easy reference later.
function PrepareExternals() {
    # Ensure that prerequisites exist.
    if (!(Get-Command -Name "java" -ErrorAction SilentlyContinue)) {
        Write-Error "To use this command you must first install Java. You can verify installation using 'java -version'."
    }

    $externalsPath = Join-Path $PSScriptRoot "Externals" -Resolve

    $plantuml = Join-Path $externalsPath "plantuml.jar" -Resolve

    # On Linux we rely on user-installed binaries for the following externals:
    # graphviz
    # wkhtmltopdf

    if ($IsLinux) {
        $dot = Get-Command "dot" -ErrorAction SilentlyContinue
        $wk = Get-Command "wkhtmltopdf" -ErrorAction SilentlyContinue

        if (!$dot) {
            Write-Error "To use this command on Linux you must first install graphviz. You can verify installation using 'dot -V'."
        }

        if (!$wk) {
            Write-Error "To use this command on Linux you must first install wkhtmltopdf. You can verify installation using 'wkhtmltopdf --version'."
        }

        # We want just the path, not the command itself.
        $graphvizdot = $dot.Path
        $wkPath = $wk.Path
    }
    else {
        # Unpack Graphviz. It is in a zip for easy packaging - all we need to do is unpack it.
        $graphvizSource = Join-Path $externalsPath "graphviz-win64.zip" -Resolve
        $graphvizDestination = Join-Path $externalsPath "graphviz"

        if (!(Test-Path $graphvizDestination)) {
            # Got to extract graphviz (only on first run).
            # On upgrade we get a clean directory (there is never an old graphviz there).
            Expand-Archive -Path $graphvizSource -DestinationPath $graphvizDestination
        }

        $graphvizdot = Join-Path $graphvizDestination "dot.exe" -Resolve
        $wkPath = Join-Path $externalsPath "wkhtmltopdf.exe" -Resolve
    }

    # Validate that PlantUML can use the installed Graphviz dot.exe without issues.
    $stdout = java -jar "$plantuml" -graphvizdot "$graphvizdot" -testdot

    if ($stdout -match "Error: *") {
        $stdout | Out-Host
        Write-Error "Graphviz setup failed - PlantUML was unable to execute Graphviz!"
    }

    return @{
        wkhtmltopdf = $wkPath
        plantuml    = $plantuml
        dot         = $graphvizdot
    }
}

function ResolveInputFile($path) {
    if ($path) {
        # If there is a path, it must be a single Bikeshed file.
        # We will accept any filename/extension as long as the file exists.
        if (!(Test-Path $path)) {
            Write-Error "Input file not found."
        }

        $file = Get-Item $path

        if ($file.Count -ne 1) {
            Write-Error "Input path resolved to multiple files. You can only build one document at a time."
        }

        if ($file -isnot [SYstem.IO.FileInfo]) {
            Write-Error "Input path did not point to a file."
        }

        return $file
    }
    else {
        # If there is no path, we expect a single file in whatever the current directory is.
        $candidates = Get-ChildItem -File -Path "*$defaultFileExtension"

        if ($candidates.Count -eq 0) {
            Write-Error "Did not find any $defaultFileExtension file in current directory to use as input."
        }
        elseif ($candidates.Count -ne 1) {
            $candidateNames = [string]::Join(", ", ($candidates | % { $_.Name }))

            Write-Error "Expected to find exactly 1 $defaultFileExtension file in current directory to use as input. Instead found $($candidates.Count): $candidateNames"
        }

        return $candidates
    }
}

# Determine the base filename to use for the document.
# This will be the original name, without any extension(s).
# This pattern may change in the future, so do not rely on it.
function DetermineBasename($inputFilePath) {
    # We start with whatever comes before the first dot in the filename.
    $basename = [IO.Path]::GetFileName($inputFilePath).Split(".", [StringSplitOptions]::RemoveEmptyEntries)[0]

    Write-Host "Output filenames will start with '$basename'"

    if ($env:TF_BUILD) {
        # If operating under VSTS, publish the basename for task automation.
        Write-Host "##vso[task.setvariable variable=documentBasename;]$basename"
    }

    return $basename
}

function PrepareOutputDirectory($outputPath) {
    Write-Verbose "Cleaning output directory."

    if (Test-Path $outputPath) {
        # Do not delete the directory itself, just contents.
        # This avoids some file locking issues.
        Get-ChildItem -Path $outputPath | Remove-Item -Force -Recurse
    }

    [IO.Directory]::CreateDirectory($outputPath) | Out-Null
}

function CopyImages($outputPath, $imagesPath) {
    if (!(Test-Path $imagesPath) -or (Get-Item $imagesPath) -isnot [IO.DirectoryInfo]) {
        Write-Verbose "No Images directory was found next to the input file. Will not copy any images."
    }
    else {
        Write-Host "Copying Images directory."

        # Recursively copy the entire directory (preserving the directory).
        Copy-Item $imagesPath $outputPath -Recurse | Out-Null
    }
}

function BuildDiagrams($outputPath, $diagramsPath, $externals) {
    if (!(Test-Path $diagramsPath) -or (Get-Item $diagramsPath) -isnot [IO.DirectoryInfo]) {
        Write-Verbose "No Diagrams directory was found next to the input file. Will not generate images from any PlantUML diagrams."
    }
    else {
        Write-Host "Generating images from PlantUML diagrams in $diagramsPath."

        # We want to preserve original filesystem structure, so just copy everything, run
        # PlantUML to generate outputs and then delete all the inputs. It gets the job done.
        Copy-Item $diagramsPath $outputPath -Recurse
        $diagramsOutputPath = Join-Path $outputPath ([IO.Path]::GetFileName($diagramsPath))

        # -SfixCircleLabelOverlapping=true
        # http://forum.plantuml.net/8442/regression-in-2018-03-2018-11-component-diagram-layout
        #
        # NB! Those extra quotes in the input path are critical due to PlantUML defect.
        # Without it, the ** pattern does not work (no subdirectories will be processed).
        java -jar "$($externals.plantuml)" -graphvizdot "$($externals.dot)" -charset utf-8 -SfixCircleLabelOverlapping=true -timeout 60 "`"$(Join-Path $diagramsOutputPath '**.wsd')`""

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Diagram generation failed! See log above for errors."
        }

        # Delete anything that is not an output of diagram generation.
        Write-Verbose "Deleting diagram generation temporary files."
        Get-ChildItem $diagramsOutputPath -File -Recurse -Exclude "*.png" | Remove-Item -Recurse -Force
    }
}

# Builds the document and returns the path to the resulting HTML file.
function BuildBikeshedDocument($outputPath, $inputFile, $basename, $force) {
    $outputFilePath = Join-Path $outputPath ($basename + ".html")

    try {
        if ($force) {
            Write-Host "Building Bikeshed document."
            [Bikeshed]::Compile($inputFile.FullName, $true) | Out-File $outputFilePath
        }
        else {
            # First validate, because build only fails on super critical errors.
            Write-Host "Validating Bikeshed document."

            [Bikeshed]::Validate($inputFile.FullName)

            Write-Host "Building Bikeshed document."
            [Bikeshed]::Compile($inputFile.FullName, $false) | Out-File $outputFilePath
        }
    }
    catch {
        if ($env:TF_BUILD) {
            # Save the Bikeshed error as a VSTS variable if we are operating under VSTS.
            # This allows for user-friedly errors in GitHub integration later on.
            # We need to strip any newlines, though, since otherwise they might get lost in transit in some cases.
            $message = $_.Exception.Message.Replace("`r", "").Replace("`n", "")
            Write-Host "##vso[task.setvariable variable=bikeshedError;]$message"
        }

        # Just let it bubble up. There is no way to get good error messages in build summary as far as I can tell.
        # No matter what you do with the error, it will still say "PowerShell exited with code '1'." and force
        # the user to dig into logs to find something useful.
        throw
    }

    return $outputFilePath
}

function BuildPdf($outputPath, $htmlFilePath, $basename, $externals) {
    Write-Host "Generating PDF."

    $outputFilePath = Join-Path $outputPath ($basename + ".pdf")

    # TODO: block access to unrelated files once a related defect is fixed
    # See https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3846
    & $externals.wkhtmltopdf --load-media-error-handling abort $htmlFilePath "$outputFilePath"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Conversion to PDF failed. See above log for errors."
    }

    return $outputFilePath
}

function BuildZip($outputPath, $basename) {
    Write-Host "Generating ZIP archive with all outputs."

    $zipPath = Join-Path $outputPath ($basename + ".zip")

    # We need to use a wildcard because otherwise it puts the directory inside the archive, too.
    Compress-Archive -Path (Join-Path $outputPath "*") -DestinationPath $zipPath

    return $zipPath
}