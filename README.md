# app_info

[![Language](https://img.shields.io/badge/ruby-2.5+-701516.svg)](.github/workflows/ci.yml)
[![Build Status](https://img.shields.io/github/actions/workflow/status/icyleaf/app_info/ci.yml)](https://github.com/icyleaf/app_info/actions/workflows/ci.yml)
[![Gem version](https://img.shields.io/gem/v/app-info.svg?style=flat)](https://rubygems.org/gems/app_info)
[![License](https://img.shields.io/badge/license-MIT-red.svg?style=flat)](LICENSE)

Teardown tool for mobile app (ipa, apk and aab file), macOS app and dSYM.zip file, analysis metedata like version, name, icon etc.

## Support

- Android file
  - `.apk`
  - `.aab` (Androld App Bundle)
- iOS file
  - `.ipa`
  - `Info.plist` file
  - `.mobileprovision`/`.provisionprofile` file
- Zipped macOS App file
  - `.app.zip`
- Zipped dSYMs file
  - `.dSYM.zip`
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'app-info'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install app-info
```

## Usage

### Initialize

```ruby
require 'app-info'

# Automatic detect file extsion and parse
parser = AppInfo.parse('iphone.ipa')
parser = AppInfo.parse('ipad.ipa')
parser = AppInfo.parse('android.apk')
parser = AppInfo.parse('android.aab')
parser = AppInfo.parse('u-u-i-d.mobileprovision')
parser = AppInfo.parse('macOS.App.zip')
parser = AppInfo.parse('App.dSYm.zip')

# If detect file type failed, you can parse in other way
parser = AppInfo::IPA.new('iphone.ipa')
parser = AppInfo::APK.new('android.apk')
parser = AppInfo::AAB.new('android.aab')
parser = AppInfo::InfoPlist.new('Info.plist')
parser = AppInfo::MobileProvision.new('uuid.mobileprovision')
parser = AppInfo::Macos.new('App.dSYm.zip')
parser = AppInfo::DSYM.new('App.dSYm.zip')
```

### iOS

Teardown suport iPhone/iPad/Universal.

```ruby
ipa = AppInfo.parse('iphone.ipa')

# get app file size
ipa.size
# => 3093823

# get app file size in human reable.
ipa.size(human_size: true)
# => 29 MB

# get app release version
ipa.release_version
# => 1.0

# get app bundle id
ipa.bundle_id
# => com.icyleaf.AppInfoDemo

# get app icons (uncrushed png by default)
ipa.icons
# => [{:name=>"AppIcon29x29@2x~ipad.png", :file=>"temp/dir/app/AppIcon29x29@2x~ipad.png"}, :dimensions=>[29, 29], :uncrushed_file=>"..." ...]

# get provisioning profile devices
ipa.devices
# => ['18cf53cddee60c5af9c97b1521e7cbf8342628da']

# detect app type
ipa.ipad?
ipa.iphone?
ipa.universal?

# detect app release type
ipa.release_type
# => 'AdHoc'

# detect architecture(s)
ipa.archs
# => [:armv7, :arm64]

# get built-in frameworks
ipa.frameworks
# => [<AppInfo::Framework:520 @name=Masonry.framework>, <AppInfo::Framework:520 @name=libswiftPhotos.dylib>]

# get built-in plugins
ipa.plugins
# => [<AppInfo::Plugin:1680 @name=NotificationService>]

# get more propety in Info.plist
ipa.info[:CFBundleDisplayName]
# => 'AppInfoDemo'
```

More to check [rspec test](spec/app_info).

### Mobile Provision

Extract from IPA parser, it could teardown any .mobileprovision file(Provisioning Profile).
you can download it from Apple Developer Portal.

```ruby
profile = AppInfo.parse('~/Library/MobileDevice/Provisioning\ Profiles/6e374bb8-a801-411f-ab28-96a4baa23814.mobileprovision')

# get app release version
profile.team_id
# => '3J9E73E9XS'

# get app package name
profile.team_name
# => 'Company/Team Name'

# get UDID of devices
profile.devices
# => ['18cf53cddee60c5af9c97b1521e7cbf8342628da']

# detect type
profile.type
# => :development/:adhoc/:appstore/:enterprise

# get enabled capabilities
profile.enabled_capabilities
# => ['Apple Pay', 'iCloud', 'Sign In with Apple', ...]
```

### Android

Accept `.aab` and `.apk` Android file.

```ruby
android = AppInfo.parse('android.apk_or_aab')

# get app file size
android.size
# => 3093823

# get app file size in human reable.
android.size(human_size: true)
# => 29 MB

# get app release version
android.release_version
# => 1.0

# get app package name
android.bundle_id
# => com.icyleaf.AppInfoDemo

# detect app type (It's difficult to detect phone or tablet)
android.tv?
android.wear?
android.automotive?

# get app icons
android.icons
# => [{:name=>"ic_launcher.png", :file=> "/temp/dir/app/ic_launcher.png", :dimensions=>[48, 48]}, ...]

# get app support min sdk version
android.min_sdk_version
# => 13

# get use_permissions list
android.use_permissions
# => [...]

# get activitiy list
android.activities
# => [...]

# get service list
android.services
# => [...]

# get deep links host
android.deep_links
# => ['a.com']

# get schemes without http or https
android.schemes
# => ['appinfo']

# get sign list (only v1 sign)
android.signs
# => [...]

# get certificate list (only v1 sign)
android.certificates
# => [...]
```

### macOS

Only accept zipped macOS file.

```ruby
macos = AppInfo.parse('macos_app.zip')

# get app file size
macos.size
# => 3093823

# get app file size in human reable.
macos.size(human_size: true)
# => 29 MB

# get app release version
macos.release_version
# => 1.0

# get app bundle id
macos.bundle_id
# => com.icyleaf.AppInfoDemo

# Get minimize os version
macos.min_os_version
# => 11.3

# get app icons(convertd icns to png icon sets by default)
macos.icons
# => [{:name=>"AppIcon.icns", :file=>"/temp/dir/app/AppIcon.icns"}, :sets=>[{:name=>"64x64_AppIcon.png", :file=>"/temp/dir/app/64x64_AppIcon.png", :dimensions=>[64, 64]}, ...]

# detect publish on mac app store
macos.stored?
# => true/false

# detect architecture(s)
macos.archs
# => [:x86_64, :arm64]

# get more propety in Info.plist
macos.info[:CFBundleDisplayName]
# => 'AppInfoDemo'
```

### dSYM

```ruby
dsym = AppInfo.parse('ios.dSYM.zip')

# get object name
dsym.object
# => iOS

# get total count of macho
dsym.machos.count
# => 1 or 2

dsym.machos.each do |macho|
  # get cpu type
  macho.cpu_type
  # => :arm

  # get cpu name
  macho.cpu_name
  # => armv7

  # get UUID (debug id)
  macho.uuid
  # => 26dfc15d-bdce-351f-b5de-6ee9f5dd6d85

  # get macho size
  macho.size
  # => 866526

  # get macho size in human reable.
  macho.size(human_size: true)
  # => 862 KB

  # dump data to Hash
  macho.to_h
  # => {uuid:"26dfc15d-bdce-351f-b5de-6ee9f5dd6d85", cpu_type: :arm, cpu_name: :armv7, ...}
end
```

## CLI Shell (Interactive console)

It is possible to use this gem as a command line interface to parse mobile app:

```
> app-info

app-info (2.7.0)> p = AppInfo.parse('/path/to/app')
=> #<AppInfo::APK::......>
app-info (2.7.0)> p.name
=> "AppName"
```

## Best Practice

- [fastlane-plugin-app_info](https://github.com/icyleaf/fastlane-plugin-app_info): fastlane plugin
- [zealot](https://github.com/tryzealot/zealot/): Over The Air Server for deployment of Android and iOS apps

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/icyleaf/app-info. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
