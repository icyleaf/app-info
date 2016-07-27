require 'cfpropertylist'

module AppInfo
  module Parser
    # iOS Info.plist parser
    class InfoPlist
      def initialize(app_path)
        @app_path = app_path
      end

      def build_version
        info.try(:[], 'CFBundleVersion')
      end

      def release_version
        info.try(:[], 'CFBundleShortVersionString')
      end

      def identifier
        info.try(:[], 'CFBundleIdentifier')
      end

      def name
        display_name || bundle_name
      end

      def display_name
        info.try(:[], 'CFBundleDisplayName')
      end

      def bundle_name
        info.try(:[], 'CFBundleName')
      end

      def icons
        return @icons if @icons

        @icons = []
        icons_root_path.each do |name|
          icon_array = info.try(:[], name)
                           .try(:[], 'CFBundlePrimaryIcon')
                           .try(:[], 'CFBundleIconFiles')

          next if icon_array.nil? || icon_array.count == 0

          icon_array.each do |items|
            Dir.glob(File.join(@app_path, "#{items}*")).find_all.each do |file|
              dict = {
                name: File.basename(file),
                file: file,
                dimensions: Pngdefry.dimensions(file)
              }

              @icons.push(dict)
            end
          end
        end

        @icons
      end

      def device_type
        device_family = info.try(:[], 'UIDeviceFamily')
        if device_family.length == 1
          case device_family
          when [1]
            'iPhone'
          when [2]
            'iPad'
          end
        elsif device_family.length == 2 && device_family == [1, 2]
          'Universal'
        end
      end

      def iphone?
        device_type == 'iPhone'
      end

      def ipad?
        device_type == 'iPad'
      end

      def universal?
        device_type == 'Universal'
      end

      def release_type
        if stored?
          'Store'
        else
          build_type
        end
      end

      def info
        @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: info_path).value)
      end

      def info_path
        File.join(@app_path, 'Info.plist')
      end

      alias bundle_id identifier

      private

      def icons_root_path
        iphone = 'CFBundleIcons'.freeze
        ipad = 'CFBundleIcons~ipad'.freeze

        case device_type
        when 'iPhone'
          [iphone]
        when 'iPad'
          [ipad]
        when 'Universal'
          [iphone, ipad]
        end
      end
    end
  end
end
