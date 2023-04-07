# frozen_string_literal: true

module AppInfo
  # Full Format
  module Format
    # Apple

    INFOPLIST = :infoplist
    MOBILEPROVISION = :mobileprovision
    DSYM = :dsym

    # macOS

    MACOS = :macos

    # iOS

    IPA = :ipa

    # Android

    APK = :apk
    AAB = :aab
    PROGUARD = :proguard

    # Windows

    PE = :pe

    UNKNOWN = :unknown
  end

  # Manufacturer
  module Manufacturer
    APPLE = :apple
    GOOGLE = :google
    MICROSOFT = :microsoft
  end

  # Platform
  module Platform
    MACOS = :macos
    IOS = :ios
    ANDROID = :android
    WINDOWS = :windows
  end

  # Apple Device Type
  module Device
    # macOS
    MACOS = :macos

    # Apple iPhone
    IPHONE = :iphone
    # Apple iPad
    IPAD = :ipad
    # Apple Watch
    IWATCH = :iwatch # not implemented yet
    # Apple Universal (iPhone and iPad)
    UNIVERSAL = :universal

    # Android Phone
    PHONE = :phone
    # Android Tablet (not implemented yet)
    TABLET = :tablet
    # Android Watch
    WATCH = :watch
    # Android TV
    TELEVISION = :television
    # Android Car Automotive
    AUTOMOTIVE = :automotive

    # Windows
    WINDOWS = :windows
  end
end
