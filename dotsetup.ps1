param ($configFile, $outputPath)

# TODO: remove! this is just for debugging purposes here
Remove-Item -LiteralPath "test" -Recurse -Force
New-Item -Path "." -Name "test" -ItemType "directory"

$config = Get-Content -Path $configFile | ConvertFrom-Json

# install all custom templates
Get-ChildItem -Directory | dotnet new -i "templates/$($_.Name)"

# create solution
dotnet new sln -n $config.name -o $outputPath

# apply templates to solution
foreach ($_ in $config.templates.PSObject.properties) {
	$shortName = $_.Name

	#$params = ""
	#foreach ($p in $_.Value.PSObject.properties) {
	#	$params = "$params--$($p.Name) $($p.Value) "
	#}
	
	#Write-Output $params

	dotnet new $shortName -o $outputPath --title "$($config.name)"
}

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
	foreach ($_ in $project.templates.PSObject.properties) {
		$shortName = $_.Name
		$params = $_.Value
		
		dotnet new $shortName -o $projectPath --title "$projectName"
	}

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