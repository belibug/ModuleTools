---
document type: cmdlet
external help file: ModuleTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: ModuleTools
ms.date: 03/19/2026
PlatyPS schema version: 2024-05-01
title: Update-MTModuleVersion
---

# Update-MTModuleVersion

## SYNOPSIS

Updates the version number of a module in project.json file. Uses [semver] object type.

## SYNTAX

### __AllParameterSets

```
Update-MTModuleVersion [[-Label] <string>] [-PreviewRelease] [-StableRelease] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This script updates the version number of a PowerShell module by modifying the project.json file, which gets written into module manifest file (.psd1).
[semver] is supported only powershell 7 and above.
It increments the version number based on the specified version part (Major, Minor, Patch).
Can also attach preview/stable release to Release property

## EXAMPLES

### EXAMPLE 1

Update-MTModuleVersion -Label Major
Updates the Major version part of the module. Version 2.1.3 will become 3.0.0.

### EXAMPLE 2

Update-MTModuleVersion
Updates the Patch version part of the module. Version 2.1.3 will become 2.1.4

### EXAMPLE 3

Update-MTModuleVersion -PreviewRelease
Updates the Patch version part of the module. Version 2.1.6 will become 2.1.7-preview

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Label

The part of the version number to increment (Major, Minor, Patch).
Default is patch.

```yaml
Type: System.String
DefaultValue: Patch
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

### -PreviewRelease

Use this to use semantic version and attach release name as 'preview' which is supported by PowerShell gallery, to remove it use stable release parameter

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -StableRelease

Use this to use semantic version and removes 'preview' release name converting it to stable release

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
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

Ensure you are in project directory when you run this command.


## RELATED LINKS

{{ Fill in the related links here }}

