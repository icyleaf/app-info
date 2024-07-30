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
    APPLETV = :appletv
    WINDOWS = :windows
  end

  # Device Type
  module Device
    module Apple
      # macOS
      MACOS = :macos

      # Apple iPhone
      IPHONE = :iphone
      # Apple iPad
      IPAD = :ipad
      # Apple Universal (iPhone and iPad)
      UNIVERSAL = :universal
      # Apple TV
      APPLETV = :appletv
      # Apple Watch (TODO: not implemented yet)
      IWATCH = :iwatch
    end

    module Google
      # Android Phone
      PHONE = :phone
      # Android Tablet (TODO: not implemented yet)
      TABLET = :tablet
      # Android Watch
      WATCH = :watch
      # Android TV
      TELEVISION = :television
      # Android Car Automotive
      AUTOMOTIVE = :automotive
    end

    module Microsoft
      # Windows
      WINDOWS = :windows
    end
  end
end
