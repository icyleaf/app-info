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

    # legacy consts

    # macOS
    # @deprecated Use {Device::Apple#MACOS} instead, this method will remove in 3.3.0.
    MACOS = :macos

    # Apple iPhone
    # @deprecated Use {Device::Apple#IPHONE} instead, this method will remove in 3.3.0.
    IPHONE = :iphone

    # Apple iPad
    # @deprecated Use {Device::Apple#IPAD} instead, this method will remove in 3.3.0.
    IPAD = :ipad

    # Apple Universal (iPhone and iPad)
    # @deprecated Use {Device::Apple#UNIVERSAL} instead, this method will remove in 3.3.0.
    UNIVERSAL = :universal

    # Apple TV
    # @deprecated Use {Device::Apple#APPLETV} instead, this method will remove in 3.3.0.
    APPLETV = :appletv

    # Apple Watch (TODO: not implemented yet)
    # @deprecated Use {Device::Apple#IWATCH} instead, this method will remove in 3.3.0.
    IWATCH = :iwatch

    # Android Phone
    # @deprecated Use {Device::Google#PHONE} instead, this method will remove in 3.3.0.
    PHONE = :phone

    # Android Tablet (TODO: not implemented yet)
    # @deprecated Use {Device::Google#TABLET} instead, this method will remove in 3.3.0.
    TABLET = :tablet

    # Android Watch
    # @deprecated Use {Device::Google#WATCH} instead, this method will remove in 3.3.0.
    WATCH = :watch

    # Android TV
    # @deprecated Use {Device::Google#TELEVISION} instead, this method will remove in 3.3.0.
    TELEVISION = :television

    # Android Car Automotive
    # @deprecated Use {Device::Google#AUTOMOTIVE} instead, this method will remove in 3.3.0.
    AUTOMOTIVE = :automotive

    # Windows
    # @deprecated Use {Device::Microsoft#WINDOWS} instead, this method will remove in 3.3.0.
    WINDOWS = :windows
  end
end
