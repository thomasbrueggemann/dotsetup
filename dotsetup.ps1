param ($configFile, $outputPath)

# TODO: remove! this is just for debugging purposes here
Remove-Item -LiteralPath "test" -Recurse -Force
New-Item -Path "." -Name "test" -ItemType "directory"

$config = Get-Content -Path $configFile | ConvertFrom-Json

# create solution
dotnet new sln -n $config.name -o $outputPath
"# $($config.name)" | Out-File -FilePath "$outputPath/README.md"

# setup basic file structure
New-Item -Path $outputPath -Name "src" -ItemType "directory"
New-Item -Path $outputPath -Name "tests" -ItemType "directory"
New-Item -Path $outputPath -Name "pipelines" -ItemType "directory"
New-Item -Path $outputPath -Name "kubernetes" -ItemType "directory"
Copy-Item "assets/.gitignore" -Destination $outputPath

foreach($project in $config.projects) {
	
	# create project
	switch ($project.type) {
		"console" {
			$projectPath = "$outputPath/src/$($project.name)"
			dotnet new $project.type -n $project.name -o $projectPath -lang "C#"
			Break
		}

		"classlib" {
			$projectPath = "$outputPath/src/$($project.name)"
			Break
		}

		"webapi" {
			$projectPath = "$outputPath/src/$($project.name)"
			Break
		}

		"xunit" {
			$projectPath = "$outputPath/tests/$($project.name)"
			Break
		}
	}

	# add nuget packages
	$project.nuget.PSObject.properties | foreach {
		$package = $_.Name
		$version = $_.Value

		dotnet add "$projectPath/$($project.name).csproj" package $package -f $project.framework -v $version --no-restore
	}

	dotnet sln "$outputPath/" add $projectPath -o $projectPath
}