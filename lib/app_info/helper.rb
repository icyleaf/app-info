# frozen_string_literal: true

require 'tmpdir'

module AppInfo
  # App format
  module Format
    # iOS
    IPA = :ipa
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
    DSYM = 'dSYM'
    PROGUARD = 'Proguard'
  end

  # Apple Device Type
  module Device
    MACOS = 'macOS'
    IPHONE = 'iPhone'
    IPAD = 'iPad'
    UNIVERSAL = 'Universal'
  end

  module AndroidDevice
    PHONE   = 'Phone'
    TABLET  = 'Tablet'
    WATCH   = 'Watch'
    TV      = 'Television'
  end

  # Icon Key
  ICON_KEYS = {
    Device::IPHONE => ['CFBundleIcons'],
    Device::IPAD => ['CFBundleIcons~ipad'],
    Device::UNIVERSAL => ['CFBundleIcons', 'CFBundleIcons~ipad'],
    Device::MACOS => %w[CFBundleIconFile CFBundleIconName]
  }.freeze

  module Helper
    module HumanFileSize
      def file_to_human_size(file, human_size:)
        number = File.size(file)
        human_size ? number_to_human_size(number) : number
      end

      FILE_SIZE_UNITS = %w[B KB MB GB TB].freeze

      def number_to_human_size(number)
        if number.to_i < 1024
          exponent = 0
        else
          max_exp = FILE_SIZE_UNITS.size - 1
          exponent = (Math.log(number) / Math.log(1024)).to_i
          exponent = max_exp if exponent > max_exp
          number = format('%<number>.2f', number: (number / (1024**exponent.to_f)))
        end

        "#{number} #{FILE_SIZE_UNITS[exponent]}"
      end
    end

    module Archive
      require 'zip'
      require 'fileutils'
      require 'securerandom'

      # Unarchive zip file
      #
      # source: https://github.com/soffes/lagunitas/blob/master/lib/lagunitas/ipa.rb
      def unarchive(file, path: nil)
        path = path ? "#{path}-" : ''
        root_path = "#{Dir.mktmpdir}/AppInfo-#{path}#{SecureRandom.hex}"
        Zip::File.open(file) do |zip_file|
          if block_given?
            yield root_path, zip_file
          else
            zip_file.each do |f|
              f_path = File.join(root_path, f.name)
              FileUtils.mkdir_p(File.dirname(f_path))
              zip_file.extract(f, f_path) unless File.exist?(f_path)
            end
          end
        end

        root_path
      end

      def tempdir(file, system: false, prefix:)
        dest_path = system ? Dir.mktmpdir("appinfo-#{prefix}-#{File.basename(file, '.*')}-", '/tmp') : File.join(File.dirname(file), prefix)
        dest_file = File.join(dest_path, File.basename(file))
        FileUtils.mkdir_p(dest_path, mode: 0_700) unless system
        dest_file
      end
    end

    module Defines
      def create_class(klass_name, parent_class, namespace:)
        klass = Class.new(parent_class) do
          yield if block_given?
        end

        name = namespace.to_s.empty? ? klass_name : "#{namespace}::#{klass_name}"
        if Object.const_get(namespace).const_defined?(klass_name)
          Object.const_get(namespace).const_get(klass_name)
        elsif Object.const_defined?(name)
          Object.const_get(name)
        else
          Object.const_get(namespace).const_set(klass_name, klass)
        end
      end

      def define_instance_method(key, value)
        instance_variable_set("@#{key}", value)
        self.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{key}
            @#{key}
          end
        RUBY
      end
    end

    module ReferenceParser
      def reference_segments(value)
        new_value = value.is_a?(Aapt::Pb::Reference) ? value.name : value
        return new_value.split('/', 2) if new_value.include?('/')

        [nil, new_value]
      end
    end
  end
end
