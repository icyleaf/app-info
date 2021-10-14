# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

> List all changes before release a new version.

## [2.7.0.beta3] (2021-10-14)

### Fixed

- Renamed methods of inflector (Conflicts with similar external methods, such like ActiveSupport Core Extensions)

## [2.7.0.beta2] (2021-09-29)

### Fixed

- Fix allocator undefined data class [#38](https://github.com/icyleaf/app_info/pull/38)

## [2.7.0.beta1] (2021-09-27)

### Added

- Android App Bundle a.k.a `aab` file parts support [#36](https://github.com/icyleaf/app_info/pull/36)

## [2.6.5] (2021-09-17)

### Added

- Add ability to retrieve manifest metadata (depend on playtestcloud/ruby_apk forked one)

## [2.6.4] (2021-09-10)

### Fixed

- Error on extract dSYM zipped file occasionally

## [2.6.3] (2021-08-27)

### Fixed

- Force write all icon data with `ASCII-8BIT`
- Force convert developer cert name to `UTF-8`
## [2.6.1] (2021-08-26)

### Fixed

- Force write macOS icon data with `ASCII-8BIT`

## [2.6.0] (2021-08-24)

### Changed

- [breaking changes] Dropped Ruby 2.3, 2.4
- [breaking changes] get all parser size with human reable changes to keyword arguments
- Rewrite InfoPlist parser
- iOS framework and plugin array sortted by ASC
- Move CI to Github Action

### Added

- macOS App parser support [#34](https://github.com/icyleaf/app_info/pull/34)
- CLI shell mode support

### Fixed

- Ruby 3.0 support

## [2.5.4] (2021-07-08)

### Fixed

- Make `ruby-macho` version match a range between 1.4 and 3.

## [2.5.3] (2021-06-16)

### Fixed

- Fix decompress png error (mostly because of it is a normal png file) [#32](https://github.com/icyleaf/app_info/pull/32) thanks @[莫小七](https://github.com/mxq0923)

## [2.5.2] (2021-04-15)

### Fixed

- Fix handle get Android application name from manifest first [#29](https://github.com/icyleaf/app_info/issues/29) thanks @[DreamPWJ](https://github.com/DreamPWJ)

## [2.5.1] (2021-04-14)

### Add

- Restore `dimensions` key from icons method and icon pnguncrush back.

## [2.4.3] (2021-04-12)

### Fixed

- Fix throws an exception 'IHDR not in place for PNG' during parse ipa file.

### Changed

- Temporary remove `dimensions` key from icons method (Only ipa file)

## [2.4.2] (2021-04-06)

### Changed

- Remove [pngdefry](https://github.com/soffes/pngdefry) gem, install it to decode iOS png file if needs.

## [2.4.1] (2021-03-08)

### Changed

- Rename `cleanup!` to `clear!` method in ipa.

### Added

- Add `clear!` method to ipa,apk, dsym and proguard.
- Make `contents` to be a public method.

## [2.3.0] (2021-01-15)

### Changed

- Change `IPA::ExportType::INHOUSE` to `IPA::ExportType::ENTERPRISE` and change the value. #[24](https://github.com/icyleaf/app-info/pull/24)
### Added

- Add `plugins`, `frameworks` to `AppInfo::IPA`. #[25](https://github.com/icyleaf/app-info/pull/25)

## [2.2.0] (2020-07-21)

### Added

- Add `platforms`, `platform` and `type` to `AppInfo::MobileProvision`.
- Add Enabled Capabilities support for mobileprovision. #[21](https://github.com/icyleaf/app-info/pull/19)

## [2.1.4] (2020-01-21)

### Fixed

- Correct Zipped dSYM filename with directory.

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

[Unreleased]: https://github.com/icyleaf/app-info/compare/v2.7.0.beta2..HEAD
[2.7.0.beta2]: https://github.com/icyleaf/app-info/compare/v2.7.0.beta1...v2.7.0.beta2
[2.7.0.beta1]: https://github.com/icyleaf/app-info/compare/v2.6.5...v2.7.0.beta1
[2.6.5]: https://github.com/icyleaf/app-info/compare/v2.6.4...v2.6.5
[2.6.4]: https://github.com/icyleaf/app-info/compare/v2.6.3...v2.6.4
[2.6.3]: https://github.com/icyleaf/app-info/compare/v2.6.1...v2.6.3
[2.6.1]: https://github.com/icyleaf/app-info/compare/v2.6.0...v2.6.1
[2.6.0]: https://github.com/icyleaf/app-info/compare/v2.5.4...v2.6.0
[2.5.4]: https://github.com/icyleaf/app-info/compare/v2.5.3...v2.5.4
[2.5.3]: https://github.com/icyleaf/app-info/compare/v2.5.2...v2.5.3
[2.5.2]: https://github.com/icyleaf/app-info/compare/v2.5.1...v2.5.2
[2.5.1]: https://github.com/icyleaf/app-info/compare/v2.4.3...v2.5.1
[2.4.3]: https://github.com/icyleaf/app-info/compare/v2.4.2...v2.4.3
[2.4.2]: https://github.com/icyleaf/app-info/compare/v2.4.1...v2.4.2
[2.4.1]: https://github.com/icyleaf/app-info/compare/v2.3.0...v2.4.1
[2.3.0]: https://github.com/icyleaf/app-info/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/icyleaf/app-info/compare/v2.1.4...v2.2.0
[2.1.4]: https://github.com/icyleaf/app-info/compare/v2.1.3...v2.1.4
[2.1.3]: https://github.com/icyleaf/app-info/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/icyleaf/app-info/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/icyleaf/app-info/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/icyleaf/app-info/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/icyleaf/app-info/compare/v1.1.2...v2.0.0
[1.1.2]: https://github.com/icyleaf/app-info/compare/v1.0.5...v1.1.2
[1.1.0]: https://github.com/icyleaf/app-info/compare/v1.0.5...v1.1.0
[1.0.5]: https://github.com/icyleaf/app-info/compare/v0.9.0...v1.0.5

