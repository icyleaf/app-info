# frozen_string_literal: true

module AppInfo
  # App format
  module Format
    # iOS
    IPA = :ipa
    INFOPLIST = :infoplist
    MOBILEPROVISION = :mobileprovision
    DSYM = :dsym

    # Android
    APK = :apk
    AAB = :aab
    PROGUARD = :proguard

    # macOS
    MACOS = :macos

    # Windows
    PE = :pe

    UNKNOWN = :unknown
  end

  # App Platform
  module Platform
    WINDOWS = 'Windows'
    MACOS = 'macOS'
    IOS = 'iOS'
    ANDROID = 'Android'
  end

  # Apple Device Type
  module Device
    MACOS = 'macOS'
    IPHONE = 'iPhone'
    IPAD = 'iPad'
    UNIVERSAL = 'Universal'
  end
end
