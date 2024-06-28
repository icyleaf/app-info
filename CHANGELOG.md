# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

> List all changes before release a new version.

## [3.1.4] (2024-06-27)

### Added

- Android(apk): Add fetch locales support.
- Android(apk): Add architectures support.
- Android(apk): Add detect universal apk.

### Fixed

- Android(apk): Fix Unknown chunk type 0x0203. #[icyleaf/android_parser#6](https://github.com/icyleaf/android_parser/issues/6)
- Android(apk): Fix 3bits of lang and country in locales.

## [3.1.2] (2024-06-25)

### Fixed

- Detect tvos for mobile provision.

## [3.1.0] (2024-06-24)

Dropped Ruby 2.5 ~ 3.0 support (no changes required.).

### Added

- Add Apple TV parser support.
- Add `.url_schemes`, `.query_schemes` and `.background_modes` to ipa and info_plist parser.
- Upgrade Android AAPT2 to 2.19.

## [3.0.0] (2023-04-18)

### Added

- New Windows PE format parser. [#47](https://github.com/icyleaf/app_info/pull/47)
- Android parser add v2, v3 scheme signature support. [#55](https://github.com/icyleaf/app_info/pull/55]
- dSYM parer accept multi dSYM target in a zip file. [#56](https://github.com/icyleaf/app_info/pull/56)
- Better document for yardoc.
- Android parser `.icons` method add exclude param to filter icons.
- Add `.files` method to proguard parser.

### Changed

- Add `AppInfo::File` base class for all parsers.
- Add `AppInfo::Certifiate` X509 certificate wrapped and apply in Android/MobileProvision.
- Re-organize categories `.platform`  to `.manufacturer`, `.platform` and `.device` for all parsers.
- Remove `.sign_version` method in Android parser.
- Rename `.file_type` to `.format` method in all parers and return a `AppInfo::Format` type.
- Remove duplice `AppInfo::AndroidDevice` class.
- Remove `AppInfo::MobileProvision::DeveloperCertificate` class, use `AppInfo::Certifiate` instead.
- Deprecate `.signs` and `.certifiates` methods in Android parser, use `.signatures` instead.
- Deprecate `.developer_certs` method in MobileProvision parser, use `.certificates` instead.
- Change ExportType values type to symbol both IPA and macOS parsers. [#58](https://github.com/icyleaf/app_info/pull/58)

## [3.0.0.beta4] (2023-04-11)

### Added

- Add `.files` method to proguard parser.

### Fixed

- Fail to extract dsym contents.

## [3.0.0.beta3] (2023-04-05)

### Added

- Android parser `.icons` method add exclude param to filter icons.

### Changed

- Rename `.platform` to `.manufacturer`, rename `.opera_sytem` to `.platform` for all parsers.

### Fixed

- Minor fixes.

## [3.0.0.beta2] (2023-04-04)

### Changed

- Re-organize categories `.platform`, `.opera_sytem` and `.device` for all parsers. [#58](https://github.com/icyleaf/app_info/pull/58)
- Change ExportType values type to symbol both IPA and macOS parsers. [#58](https://github.com/icyleaf/app_info/pull/58)

## [3.0.0.beta1] (2023-04-04)

### Added

- New Windows PE format parser. [#47](https://github.com/icyleaf/app_info/pull/47)
- Android parser add v2, v3 scheme signature support. [#55](https://github.com/icyleaf/app_info/pull/55]
- dSYM parer accept multi dSYM target in a zip file. [#56](https://github.com/icyleaf/app_info/pull/56)
- Better document for yardoc.

### Changed

- Add `AppInfo::File` base class for all parsers.
- Add `AppInfo::Certifiate` X509 certificate wrapped and apply in Android/MobileProvision.
- Remove `.sign_version` method in Android parser.
- Rename `.file_type` to `.format` method in all parers and return a `AppInfo::Format` type.
- Remove duplice `AppInfo::AndroidDevice` class.
- Remove `AppInfo::MobileProvision::DeveloperCertificate` class, use `AppInfo::Certifiate` instead.
- Deprecate `.signs` and `.certifiates` methods in Android parser, use `.signatures` instead.
- Deprecate `.developer_certs` method in MobileProvision parser, use `.certificates` instead.

### Fixed

- Fixed minor typo.

## [2.8.5] (2023-03-16)

### Fixed

- Sync the latest appt2 proto files to parse Android SDK 31+ for aab parser. [#51](https://github.com/icyleaf/app_info/issues/51) (thanks @[UpBra](https://github.com/UpBra))

## [2.8.4] (2023-03-09)

### Fixed

- Force android device return as boolean for aab parser.
- Handle string resources referencing other resources for apk parser.

## [2.8.3] (2022-06-27)

### Fixed

- Fix properties in `AndroidManifest.xml` of aab file with null state prediction.

## [2.8.2] (2022-02-13)

### Fixed

- Fix Arm-based M1 macOS.

## [2.8.1] (2021-12-20)

### Fixed

- Fix no found intent filter in manifest error.

## [2.8.0] (2021-12-16)

### Added

- New methods added to `apk` and `aab` [3adfa223](https://github.com/icyleaf/app_info/tree/3adfa223479caa672fce5d3a119b6db098463699) [939a6506](https://github.com/icyleaf/app_info/tree/939a6506f3ac1cb7ad1ed46128df41de6ee3b0d0)

## [2.7.0] (2021-10-15)

### Added

- Android App Bundle (a.k.a) aab support!!! parts support [#36](https://github.com/icyleaf/app_info/pull/36)

## [2.7.0.beta5] (2021-10-14)

### Fixed

- Renamed methods of inflector (Conflicts with similar external methods, such like ActiveSupport Core Extensions)
- Keep same behavior methods between apk and aab

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

[Unreleased]: https://github.com/icyleaf/app-info/compare/v3.1.4..HEAD
[3.1.4]: https://github.com/icyleaf/app-info/compare/v3.1.2...v3.1.4
[3.1.2]: https://github.com/icyleaf/app-info/compare/v3.1.0...v3.1.2
[3.1.0]: https://github.com/icyleaf/app-info/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/icyleaf/app-info/compare/v2.8.5...v3.0.0
[3.0.0.beta4]: https://github.com/icyleaf/app-info/compare/v3.0.0.beta3...v3.0.0.beta4
[3.0.0.beta3]: https://github.com/icyleaf/app-info/compare/v3.0.0.beta2...v3.0.0.beta3
[3.0.0.beta2]: https://github.com/icyleaf/app-info/compare/v3.0.0.beta1...v3.0.0.beta2
[3.0.0.beta1]: https://github.com/icyleaf/app-info/compare/v2.8.5...v3.0.0.beta1
[2.8.5]: https://github.com/icyleaf/app-info/compare/v2.8.4...v2.8.5
[2.8.4]: https://github.com/icyleaf/app-info/compare/v2.8.3...v2.8.4
[2.8.3]: https://github.com/icyleaf/app-info/compare/v2.8.2...v2.8.3
[2.8.2]: https://github.com/icyleaf/app-info/compare/v2.8.1...v2.8.2
[2.8.1]: https://github.com/icyleaf/app-info/compare/v2.8.0...v2.8.1
[2.8.0]: https://github.com/icyleaf/app-info/compare/v2.7.0...v2.8.0
[2.7.0]: https://github.com/icyleaf/app-info/compare/v2.6.5...v2.7.0
[2.7.0.beta5]: https://github.com/icyleaf/app-info/compare/v2.7.0.beta2...v2.7.0.beta5
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

