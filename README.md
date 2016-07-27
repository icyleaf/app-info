# app_info

Teardown tool for mobile app(ipa/apk), analysis metedata like version, name, icon etc.

## Support

- Android apk file
- iOS ipa file
  - Info.plist file
  - .mobileprovision file

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'app_info'
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
require 'app_info'

# Automatic detect file extsion and parse
parser = AppInfo.parse('iphone.ipa')
parser = AppInfo.parse('ipad.ipa')
parser = AppInfo.parse('android.ipa')
parser = AppInfo.parse('App/Info.plist')
parser = AppInfo.parse('provisioning_profile/uuid.mobileprovision')
```

### iOS

Teardown suport iPhone/iPad/Universal.

```ruby
ipa = AppInfo.parse('iphone.ipa')

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

# get app icons
profile.devices
# => ['18cf53cddee60c5af9c97b1521e7cbf8342628da']
```

### Android

```ruby
apk = AppInfo.parse('android.apk')

# get app release version
apk.release_version
# => 1.0

# get app package name
apk.package_namebundle_id
# => com.icyleaf.AppInfoDemo

# get app icons
apk.icons
# => [{:name=>"ic_launcher.png", :file=> "/var/folders/mb/8cm0fz4d499968yss9y1j8bc0000gp/T/d20160728-70163-10d47fl/AppInfo-android-cccbf89a889eb592c5c6f342d56b9a49/res/mipmap-mdpi-v4/ic_launcher.png/ic_launcher.png", :dimensions=>[48, 48]}, ...]

# get app support min sdk version
apk.min_sdk_version
# => 13

# detect app type (It's difficult to detect phone or tablet)
ipa.tv?
ipa.wear?
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/app-info. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

