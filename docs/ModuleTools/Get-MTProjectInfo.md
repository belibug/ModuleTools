---
document type: cmdlet
external help file: ModuleTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: ModuleTools
ms.date: 03/19/2026
PlatyPS schema version: 2024-05-01
title: Get-MTProjectInfo
---

# Get-MTProjectInfo

## SYNOPSIS

Retrieves information about a project by reading data from a project.json file in ModuleTools project folder.

## SYNTAX

### __AllParameterSets

```
Get-MTProjectInfo [[-Path] <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

The Get-MTProjectInfo function retrieves information about a project by reading data from a project.json file located in the current directory.
Ensure you navigate to a module directory which has project.json in root directory.
Most variables are already defined in output of this command which can be used in pester tests and other configs.

## EXAMPLES

### EXAMPLE 1

Get-MTProjectInfo
Retrieves project information from the project.json file in the current directory. Useful for debuggin and writing pester tests.

## PARAMETERS

### -Path

Provide path to root folder of the ModuleTool based project

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

## INPUTS

## OUTPUTS

### hastable with all project data.

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

