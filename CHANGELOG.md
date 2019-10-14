# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

> List all changes before release a new version.

### Changed

- Remove `Parser` module to reduce namespace. #[13](https://github.com/icyleaf/app-info/issues/13)
- Use parse Macho-O header and contents to detect file type instead of file extension name.
- Dropped Ruby 2.2 and below versions support.

### Added

- Added iOS .dSYM.zip format support. #[8](https://github.com/icyleaf/app-info/issues/8)
- Added parse mobileprovision in Linux. #[10](https://github.com/icyleaf/app_info/pull/10)
- Added `AppInfo.file_type` to detect file type.
- Added detect and simple parse Android proguard file support. #[15](https://github.com/icyleaf/app_info/pull/15)

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

