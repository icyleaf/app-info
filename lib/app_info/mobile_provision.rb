# frozen_string_literal: true

require 'openssl'
require 'cfpropertylist'

module AppInfo
  # .mobileprovision file parser
  class MobileProvision < File
    def file_type
      Format::MOBILEPROVISION
    end

    def name
      mobileprovision.try(:[], 'Name')
    end

    def app_name
      mobileprovision.try(:[], 'AppIDName')
    end

    def type
      return :development if development?
      return :adhoc if adhoc?
      return :appstore if appstore?
      return :enterprise if enterprise?
    end

    def platforms
      return unless platforms = mobileprovision.try(:[], 'Platform')

      platforms.map do |v|
        v = 'macOS' if v == 'OSX'
        v.downcase.to_sym
      end
    end

    def platform
      platforms[0]
    end

    def devices
      mobileprovision.try(:[], 'ProvisionedDevices')
    end

    def team_identifier
      mobileprovision.try(:[], 'TeamIdentifier')
    end

    def team_name
      mobileprovision.try(:[], 'TeamName')
    end

    def profile_name
      mobileprovision.try(:[], 'Name')
    end

    def created_date
      mobileprovision.try(:[], 'CreationDate')
    end

    def expired_date
      mobileprovision.try(:[], 'ExpirationDate')
    end

    def entitlements
      mobileprovision.try(:[], 'Entitlements')
    end

    # return developer certificates.
    #
    # @deprecated Use {#certificates} instead of this method.
    def developer_certs
      certificates
    end

    # return developer certificates.
    #
    # @return [Array<Certificate>]
    def certificates
      certs = mobileprovision.try(:[], 'DeveloperCertificates')
      return if certs.empty?

      certs.each_with_object([]) do |cert_data, obj|
        obj << Certificate.parse(cert_data)
      end
    end

    # Detect is development type of mobileprovision
    #
    # related link: https://stackoverflow.com/questions/1003066/what-does-get-task-allow-do-in-xcode
    def development?
      case platform.downcase.to_sym
      when :ios
        entitlements['get-task-allow'] == true
      when :macos
        !devices.nil?
      else
        raise Error, "Not implement with platform: #{platform}"
      end
    end

    # Detect app store type
    #
    # related link: https://developer.apple.com/library/archive/qa/qa1830/_index.html
    def appstore?
      case platform.downcase.to_sym
      when :ios
        !development? && entitlements.key?('beta-reports-active')
      when :macos
        !development?
      else
        raise Error, "Not implement with platform: #{platform}"
      end
    end

    def adhoc?
      return false if platform == :macos # macOS no need adhoc

      !development? && !devices.nil?
    end

    def enterprise?
      return false if platform == :macos # macOS no need adhoc

      !development? && !adhoc? && !appstore?
    end
    alias inhouse? enterprise?

    # Enabled Capabilites
    #
    # Related link: https://developer.apple.com/support/app-capabilities/
    def enabled_capabilities
      capabilities = []
      capabilities << 'In-App Purchase' << 'GameKit' if adhoc? || appstore?

      entitlements.each do |key, _|
        case key
        when 'aps-environment'
          capabilities << 'Push Notifications'
        when 'com.apple.developer.applesignin'
          capabilities << 'Sign In with Apple'
        when 'com.apple.developer.siri'
          capabilities << 'SiriKit'
        when 'com.apple.security.application-groups'
          capabilities << 'App Groups'
        when 'com.apple.developer.associated-domains'
          capabilities << 'Associated Domains'
        when 'com.apple.developer.default-data-protection'
          capabilities << 'Data Protection'
        when 'com.apple.developer.networking.networkextension'
          capabilities << 'Network Extensions'
        when 'com.apple.developer.networking.vpn.api'
          capabilities << 'Personal VPN'
        when 'com.apple.developer.healthkit',
            'com.apple.developer.healthkit.access'
          capabilities << 'HealthKit' unless capabilities.include?('HealthKit')
        when 'com.apple.developer.icloud-services',
            'com.apple.developer.icloud-container-identifiers'
          capabilities << 'iCloud' unless capabilities.include?('iCloud')
        when 'com.apple.developer.in-app-payments'
          capabilities << 'Apple Pay'
        when 'com.apple.developer.homekit'
          capabilities << 'HomeKit'
        when 'com.apple.developer.user-fonts'
          capabilities << 'Fonts'
        when 'com.apple.developer.pass-type-identifiers'
          capabilities << 'Wallet'
        when 'inter-app-audio'
          capabilities << 'Inter-App Audio'
        when 'com.apple.developer.networking.multipath'
          capabilities << 'Multipath'
        when 'com.apple.developer.authentication-services.autofill-credential-provider'
          capabilities << 'AutoFill Credential Provider'
        when 'com.apple.developer.networking.wifi-info'
          capabilities << 'Access WiFi Information'
        when 'com.apple.external-accessory.wireless-configuration'
          capabilities << 'Wireless Accessory Configuration'
        when 'com.apple.developer.kernel.extended-virtual-addressing'
          capabilities << 'Extended Virtual Address Space'
        when 'com.apple.developer.nfc.readersession.formats'
          capabilities << 'NFC Tag Reading'
        when 'com.apple.developer.ClassKit-environment'
          capabilities << 'ClassKit'
        when 'com.apple.developer.networking.HotspotConfiguration'
          capabilities << 'Hotspot'
        when 'com.apple.developer.devicecheck.appattest-environment'
          capabilities << 'App Attest'
        when 'com.apple.developer.coremedia.hls.low-latency'
          capabilities << 'Low Latency HLS'
        when 'com.apple.developer.associated-domains.mdm-managed'
          capabilities << 'MDM Managed Associated Domains'
        # macOS Only
        when 'com.apple.developer.maps'
          capabilities << 'Maps'
        when 'com.apple.developer.system-extension.install'
          capabilities << 'System Extension'
        when 'com.apple.developer.networking.custom-protocol'
          capabilities << 'Custom Network Protocol'
        end
      end

      capabilities
    end

    def [](key)
      mobileprovision.try(:[], key.to_s)
    end

    def empty?
      mobileprovision.nil?
    end

    def mobileprovision
      return @mobileprovision = nil unless ::File.exist?(@file)

      data = ::File.read(@file)
      data = strip_plist_wrapper(data) unless bplist?(data)
      list = CFPropertyList::List.new(data: data).value
      @mobileprovision = CFPropertyList.native_types(list)
    rescue CFFormatError
      @mobileprovision = nil
    end

    def method_missing(method_name, *args, &block)
      mobileprovision.try(:[], method_name.to_s.ai_camelcase) ||
        mobileprovision.send(method_name) ||
        super
    end

    def respond_to_missing?(method_name, *args)
      mobileprovision.key?(method_name.to_s.ai_camelcase) ||
        mobileprovision.respond_to?(method_name) ||
        super
    end

    private

    def bplist?(raw)
      raw[0..5] == 'bplist'
    end

    def strip_plist_wrapper(raw)
      end_tag = '</plist>'
      start_point = raw.index('<?xml version=')
      end_point = raw.index(end_tag) + end_tag.size - 1
      raw[start_point..end_point]
    end
  end
end
