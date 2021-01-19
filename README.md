# app_info

[![Language](https://img.shields.io/badge/ruby-2.3+-701516.svg)](.travis.yml)
[![Build Status](https://travis-ci.org/icyleaf/app_info.svg?branch=master)](https://travis-ci.org/icyleaf/app_info)
[![Gem version](https://img.shields.io/gem/v/app-info.svg?style=flat)](https://rubygems.org/gems/app_info)
[![License](https://img.shields.io/badge/license-MIT-red.svg?style=flat)](LICENSE)

Teardown tool for mobile app(ipa/apk) and dSYM.zip file, analysis metedata like version, name, icon etc.

## Support

- Android apk file
- iOS ipa file
  - Info.plist file
  - .mobileprovision/.provisionprofile file
- dSYM(.zip) file

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
parser = AppInfo.parse('u-u-i-d.mobileprovision')
parser = AppInfo.parse('App.dSYm.zip')

# If detect file type failed, you can parse in other way
parser = AppInfo::IPA.new('iphone.ipa')
parser = AppInfo::IPA.new('android.apk')
parser = AppInfo::InfoPlist.new('App/Info.plist')
parser = AppInfo::MobileProvision.new('provisioning_profile/uuid.mobileprovision')
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
ipa.size(true)
# => 29 MB

# get app release version
ipa.release_version
# => 1.0

# get app bundle id
ipa.bundle_id
# => com.icyleaf.AppInfoDemo

# get app icons
ipa.icons
# => [{:name=>"AppIcon29x29@2x~ipad.png", :file=>"/var/folders/mb/8cm0fz4d499968yss9y1j8bc0000gp/T/d20160728-69669-1xnub30/AppInfo-ios-a5369339399e62046d7d59c52254dac6/Payload/bundle.app/AppIcon29x29@2x~ipad.png", :dimensions=>[58, 58]}, ...]

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

### dSYM

```ruby
dsym = AppInfo.parse('ios.dSYM.zip')

# get object name
dsym.object
# => iOS

# get macho size
dsym.machos.size
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
  macho.size(true)
  # => 862 KB

  # dump data to Hash
  macho.to_h
  # => {uuid:"26dfc15d-bdce-351f-b5de-6ee9f5dd6d85", cpu_type: :arm, cpu_name: :armv7, ...}
end
```

### Android

```ruby
apk = AppInfo.parse('android.apk')

# get app file size
apk.size
# => 3093823

# get app file size in human reable.
apk.size(true)
# => 29 MB

# get app release version
apk.release_version
# => 1.0

# get app package name
apk.bundle_id
# => com.icyleaf.AppInfoDemo

# get app icons
apk.icons
# => [{:name=>"ic_launcher.png", :file=> "/var/folders/mb/8cm0fz4d499968yss9y1j8bc0000gp/T/d20160728-70163-10d47fl/AppInfo-android-cccbf89a889eb592c5c6f342d56b9a49/res/mipmap-mdpi-v4/ic_launcher.png/ic_launcher.png", :dimensions=>[48, 48]}, ...]

# get app support min sdk version
apk.min_sdk_version
# => 13

# get use_permissions list
apk.use_permissions
# => [...]

# get activitiy list
apk.activities
# => [...]

# get service list
apk.services
# => [...]

# get certificate list
apk.certificates
# => [...]

# get sign list
apk.signs
# => [...]

# detect app type (It's difficult to detect phone or tablet)
apk.tv?
apk.wear?
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/app-info. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
