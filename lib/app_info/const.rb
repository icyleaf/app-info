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

    # HarmonyOS

    HAP = :hap
    HAPP = :app

    # Windows

    PE = :pe

    UNKNOWN = :unknown
  end

  # Manufacturer
  module Manufacturer
    APPLE = :apple
    GOOGLE = :google
    MICROSOFT = :microsoft
    HUAWEI = :huawei
  end

  # Platform
  module Platform
    MACOS = :macos
    IOS = :ios
    ANDROID = :android
    APPLETV = :appletv
    WINDOWS = :windows
    HARMONYOS = :harmonyos
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

    module Huawei
      # HarmonyOS Default
      DEFAULT = :default
      # HarmonyOS Phone
      PHONE = :phone
      # HarmonyOS Tablet
      TABLET = :tablet
      # HarmonyOS TV
      TV = :tv
      # HarmonyOS wearable
      WEARABLE = :wearable
      # HarmonyOS Car
      CAR = :car
      # HarmonyOS 2-in-1 tablet and laptop
      TWO_IN_ONE = :two_in_one
    end

    module Microsoft
      # Windows
      WINDOWS = :windows
    end
  end
end
