# 🏗️ dotsetup

Creates .NET solutions and projects based on a JSON config file.

## Installation

- You need the `dotnet` CLI installed on your machine
- Just copy the ./dotsetup.ps1 PowerShell script onto your machine as use as follows:

## Usage

For example use

```bash
./dotsetup example_config.json ./test
```

to read the example_config.json and create the configured items into the folder "test".

## Config Syntax

```json
{
  "name": "TestSolution",
  "projects": [
    {
      "name": "TestLibrary",
      "type": "classlib",
      "framework": "net5.0",
      "nuget": {
        "Newtonsoft.Json": "13.0.1"
      },
      "references": []
    },
    {
      "name": "TestProject",
      "type": "console",
      "framework": "net5.0",
      "nuget": {
        "Newtonsoft.Json": "13.0.1"
      },
      "references": ["TestLibrary"]
    },
    {
      "name": "TestLibraryUnitTests",
      "type": "xunit",
      "framework": "net5.0",
      "nuget": {
        "Newtonsoft.Json": "13.0.1"
      },
      "references": ["TestLibrary"]
    }
  ]
}
```
