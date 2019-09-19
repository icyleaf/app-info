# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

> List all changes before release a new version.

### Added

- Added .dSYM.zip format support
- Added parse mobileprovision in Linux

### Changed

- Parse macho-o header to detect file type instead of file extension name. (Maby be not fully support)
- Dropped Ruby 2.2 and below versions support

## [1.1.2] (2019-09-19)

### Fixed

- Fixed fetch key from ipa.info by Hash way. (thanks @[MobilEKG](https://github.com/MobilEKG))

## [1.1.0] (2019-06-17)

### Added

- Added more methods to Android parser.

## [1.0.5] (2019-03-30)

### Changed

- Updated dependency of CFPropertly list be a range between 2.3.4. (thanks @[cschroed](https://github.com/cschroed))

[Unreleased]: https://github.com/icyleaf/app-info/compare/v1.1.0..HEAD
[1.1.0]: https://github.com/icyleaf/app-info/compare/v1.0.5...v1.1.0
[1.0.5]: https://github.com/icyleaf/app-info/compare/v0.9.0...v1.0.5

