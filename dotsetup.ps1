param ($configFile, $outputPath)

# TODO: remove! this is just for debugging purposes here
Remove-Item -LiteralPath "test" -Recurse -Force
New-Item -Path "." -Name "test" -ItemType "directory"

$config = Get-Content -Path $configFile | ConvertFrom-Json

# create solution
dotnet new sln -n $config.name -o $outputPath
"# $($config.name)" | Out-File -FilePath "$outputPath/README.md"

# setup basic file structure
New-Item -Path $outputPath -Name "pipelines" -ItemType "directory"
New-Item -Path $outputPath -Name "kubernetes" -ItemType "directory"

# apply templates to solution


foreach ($project in $config.projects) {
	
	$solutionFolder = "src";
	if ($project.type -eq "xunit") {
		$solutionFolder = "tests"
	}

	$projectName = "$($config.name).$($project.name)"
	$projectPath = "$outputPath/$solutionFolder/$projectName"

	# create project
	dotnet new $project.type -n $projectName -o $projectPath -lang "C#" --no-restore

	# apply templates to project
	# ...

	$projectFilePath = "$projectPath/$projectName.csproj";

	# add nuget packages
	foreach ($_ in $project.nuget.PSObject.properties) {
		$package = $_.Name
		$version = $_.Value

		dotnet add $projectFilePath package $package -f $project.framework -v $version --no-restore
	}

	# add project references 
	foreach ($reference in $project.references) {
		$referenceName = "$($config.name).$reference"
		dotnet add $projectFilePath reference "$outputPath/src/$referenceName/$referenceName.csproj"
	}

	dotnet sln "$outputPath/$($config.name).sln" add $projectFilePath
}