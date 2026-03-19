---
document type: cmdlet
external help file: ModuleTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: ModuleTools
ms.date: 03/19/2026
PlatyPS schema version: 2024-05-01
title: Invoke-MTBuild
---

# Invoke-MTBuild

## SYNOPSIS

Build a ModuleTool project to generate ready to import PowerShell Module.

## SYNTAX

### __AllParameterSets

```
Invoke-MTBuild [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function is used to build a module, dist folder is cleaned up and whole module is build from scracth.
copies all necessary resource files.

## EXAMPLES

### EXAMPLE 1: Builds module from the project files.

Invoke-MTBuild

### EXAMPLE 2: Builds module and outputs verbose details during entire workflow.

Invoke-MTBuild -Verbose

## PARAMETERS

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