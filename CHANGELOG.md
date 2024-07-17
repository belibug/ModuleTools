# Changelog

All notable changes to this project will be documented in this file.

## [0.0.9] - 2024-07-17

## Fixed

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