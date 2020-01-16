# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

> List all changes before release a new version.

## [2.1.3] (2020-01-16)

### Fixed

- Store Android icon with BINARY mode AGAIN(correct way).

## [2.1.2] (2020-01-11)

### Fixed

- Correct Android icon temporary path.
- Store Android icon force encoding with BINARY.

## [2.1.1] (2019-12-28)

### Fixed

- Correct get dSYM binary file. #[19](https://github.com/icyleaf/app-info/pull/19)

## [2.1.0] (2019-10-31)

### Added

- Added `.[]` and `missing_method` to find and match in `AppInfo::InfoPlist` and `AppInfo::MobileProvision'.
- Added `AppInfo::MobileProvision.developer_certs`. #[17](https://github.com/icyleaf/app-info/pull/17)

## [2.0.0] (2019-10-29)

### Added

- Added iOS `.dSYM.zip` format support. #[8](https://github.com/icyleaf/app-info/issues/8)
- Added parse mobileprovision in Linux. #[10](https://github.com/icyleaf/app_info/pull/10)
- Added `AppInfo.file_type` to detect file type.
- Added detect and simple parse Android proguard file support. #[15](https://github.com/icyleaf/app_info/pull/15)
- Added `AppInfo::IPA.archs` to return what architecture(s) support. #[16](https://github.com/icyleaf/app_info/pull/16)

### Changed

- Remove `Parser` module to reduce namespace. #[13](https://github.com/icyleaf/app-info/issues/13)
- Use parse Macho-O header and contents to detect file type instead of file extension name.
- Dropped Ruby 2.2 and below versions support.

## [1.1.2] (2019-09-19)

### Fixed

- Fixed fetch key from ipa.info by Hash way. (thanks @[MobilEKG](https://github.com/MobilEKG))

## [1.1.0] (2019-06-17)

### Added

- Added more methods to Android parser.

## [1.0.5] (2019-03-30)

### Changed

- Updated dependency of CFPropertly list be a range between 2.3.4. (thanks @[cschroed](https://github.com/cschroed))

[Unreleased]: https://github.com/icyleaf/app-info/compare/v2.1.3..HEAD
[2.1.2]: https://github.com/icyleaf/app-info/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/icyleaf/app-info/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/icyleaf/app-info/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/icyleaf/app-info/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/icyleaf/app-info/compare/v1.1.2...v2.0.0
[1.1.2]: https://github.com/icyleaf/app-info/compare/v1.0.5...v1.1.2
[1.1.0]: https://github.com/icyleaf/app-info/compare/v1.0.5...v1.1.0
[1.0.5]: https://github.com/icyleaf/app-info/compare/v0.9.0...v1.0.5

