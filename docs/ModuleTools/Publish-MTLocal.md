---
document type: cmdlet
external help file: ModuleTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: ModuleTools
ms.date: 03/19/2026
PlatyPS schema version: 2024-05-01
title: Publish-MTLocal
---

# Publish-MTLocal

## SYNOPSIS

Copy built module to local PSModulePath.

## SYNTAX

### __AllParameterSets

```
Publish-MTLocal [[-ModuleDirectoryPath] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Useful quick testing and private modules which don't get hosted in PSGallery or other repository. This command publishes the generated module to local PSModulePath location which gets autoimported when porfile loads.

## EXAMPLES

### Example 1

Publish-MTLocal
Publishes to local $PSModulePath

### Example 2

Publish-MTLocal -ModuleDirectoryPath \\Some\Path
Publishes/Copies to path provided

## PARAMETERS

### -ModuleDirectoryPath

Path to save the built module.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

{{ Fill in the Description }}

## NOTES

{{ Fill in the Notes }}

## RELATED LINKS

{{ Fill in the related links here }}

