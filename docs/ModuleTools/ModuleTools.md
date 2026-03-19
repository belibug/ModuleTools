---
document type: module
Help Version: 1.0.0.0
HelpInfoUri: ''
Locale: en-US
Module Guid: d1595b4a-a79f-4440-94f0-3196f4d29c41
Module Name: ModuleTools
ms.date: 03/19/2026
PlatyPS schema version: 2024-05-01
title: ModuleTools Module
---

# ModuleTools Module

## Description

ModuleTools is a versatile, standalone PowerShell module builder. Create anything from simple to robust modules with ease. Built for CICD and Automation.

## ModuleTools Cmdlets

### [Get-MTProjectInfo](Get-MTProjectInfo.md)

Retrieves information about a project by reading data from a project.json file in ModuleTools project folder.

### [Invoke-MTBuild](Invoke-MTBuild.md)

Build a ModuleTool project to generate ready to import PowerShell Module.

### [Invoke-MTTest](Invoke-MTTest.md)

Runs Pester tests using settings from project.json

### [New-MTModule](New-MTModule.md)

Create module scaffolding along with project.json file to easily build and manage modules in ModuleTools opinionated format

### [Publish-MTLocal](Publish-MTLocal.md)

Copy built module to local PSModulePath.

### [Update-MTModuleVersion](Update-MTModuleVersion.md)

Updates the version number of a module in project.json file. Uses [semver] object type.

