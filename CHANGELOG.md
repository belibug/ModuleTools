# Changelog

All notable changes to this project will be documented in this file.

## [1.1.3] - 2025-09-14

### Added
- Now supports preview tag in Update-MTModuleVersion
- Now supports semver naming in both project.json and modulemanifest
- Module build supports `preview` or `prerelease` tag
- Preview version looks like `1.2.3-preview` 

## [1.1.0] - 2025-08-28

## Added

- Now Module manifest includes `AliasesToExport`. This helps loading aliases without explicitly importing modules to session. 
- thanks to @djs-zmtc for suggesting the feature

## [1.0.0] - 2025-03-11

### Added

- New optional project setting `copyResourcesToModuleRoot`. Setting to true places resource files in the root directory of module. Default is `false` to provide backward compatibility. Thanks to @[BrooksV](https://github.com/BrooksV)

### Fixed

- **BREAKING CHANGE**: Typo corrected: ProjecUri to ProjectUri. Existing projects require manual update.

## [0.0.9] - 2024-07-17

### Fixed

- Fixed #7, Invoke build should not through for empty tags

## [0.0.7] - 2024-07-17

### Added

- Now "Manifest" section of project JSON supports all Manifest parameters, use exact name of parameter (from New-ModuleManifest) as key in JSON

## Fixed

- Corrected typo in ProjectUri from `ProjecUri` to correct spelling.

## [0.0.6] - 2024-07-08

### Added

- `Invoke-MTTest` now supports including and excluding tags

### Fixed

- Code cleanup

## [0.0.5] - 2024-07-05

### Added

- More verbose info during MTModule creation

### Fixed

- Issue #2 : Git initialization implemented
- Issue #1 : Doesn't create empty `tests` folder when user chooses `no` to tests

## [0.0.4] - 2024-06-25

### Added
- First release to `psgallery`
- All basic functionality of Module is ready
