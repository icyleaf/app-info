require 'cfpropertylist'

module AppInfo
  module Parser
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
          method_name.to_s.split('_').map {|k| k.capitalize }.join('')
        else
          method_name.to_s
        end

        mobileprovision.try(:[], key)
      end

      def empty?
        mobileprovision.nil?
      end

      def mobileprovision
        return @mobileprovision = nil if @path.nil? or @path.empty? or !File.exist?(@path)

        data = `security cms -D -i "#{@path}" 2> /dev/null`
        @mobileprovision = CFPropertyList.native_types(CFPropertyList::List.new(data: data).value)
      rescue CFFormatError
        @mobileprovision = nil
      end
    end
  end
end
