---
document type: cmdlet
external help file: ModuleTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: ModuleTools
ms.date: 03/19/2026
PlatyPS schema version: 2024-05-01
title: Invoke-MTTest
---

# Invoke-MTTest

## SYNOPSIS

Runs Pester tests using settings from project.json

## SYNTAX

### __AllParameterSets

```
Invoke-MTTest [[-TagFilter] <string[]>] [[-ExcludeTagFilter] <string[]>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Run Pester tests using the specified configuration and settings as defined in project.json. When `BuildRecursiveFolders` is `false`, only top-level `tests/*.Tests.ps1` files are run, following Pester's normal test-file convention. When `BuildRecursiveFolders` is `true`, test files in nested folders under `tests` are also discovered and run.

## EXAMPLES

### EXAMPLE 1

Invoke-MTTest
Runs the Pester tests for the project.

### EXAMPLE 2

Invoke-MTTest -TagFilter "unit","integrate"
Runs the Pester tests for the project, that has tag unit or integrate

### EXAMPLE 3

Invoke-MTTest -ExcludeTagFilter "unit"
Runs the Pester tests for the project, excludes any test with tag unit

## PARAMETERS

### -ExcludeTagFilter

Array of tags to exclude, Provide the tag Pester should exclude

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TagFilter

Array of tags to run, Provide the tag Pester should run

```yaml
Type: System.String[]
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

