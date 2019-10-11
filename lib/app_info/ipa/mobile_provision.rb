# frozen_string_literal: true

require 'cfpropertylist'

module AppInfo
  # .mobileprovision file parser
  class MobileProvision
    def initialize(path)
      @path = path
    end

    def name
      mobileprovision.try(:[], 'Name')
    end

    def app_name
      mobileprovision.try(:[], 'AppIDName')
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

    def method_missing(method_name, *args, &block)
      key = if method_name.to_s.include?('_')
              method_name.to_s
                         .split('_')
                         .map(&:capitalize)
                         .join('')
            else
              method_name.to_s
            end

      mobileprovision.try(:[], key)
    end

    def empty?
      mobileprovision.nil?
    end

    def mobileprovision
      return @mobileprovision = nil unless File.exist?(@path)

      data = File.read(@path)
      data = strip_plist_wrapper(data) unless bplist?(data)
      list = CFPropertyList::List.new(data: data).value
      @mobileprovision = CFPropertyList.native_types(list)
    rescue CFFormatError
      @mobileprovision = nil
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
