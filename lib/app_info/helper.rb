# frozen_string_literal: true

module AppInfo
  # App Platform
  module Platform
    MACOS = 'macOS'
    IOS = 'iOS'
    ANDROID = 'Android'
    DSYM = 'dSYM'
    PROGUARD = 'Proguard'
  end

  # Device Type
  module Device
    MACOS = 'macOS'
    IPHONE = 'iPhone'
    IPAD = 'iPad'
    UNIVERSAL = 'Universal'
  end

  # Icon Key
  ICON_KEYS = {
    AppInfo::Device::IPHONE => ['CFBundleIcons'],
    AppInfo::Device::IPAD => ['CFBundleIcons~ipad'],
    AppInfo::Device::UNIVERSAL => ['CFBundleIcons', 'CFBundleIcons~ipad'],
    AppInfo::Device::MACOS => %w[CFBundleIconFile CFBundleIconName]
  }.freeze

  module Helper
    module HumanFileSize
      def file_size(file, human_size: )
        file_size = File.size(file)
        human_size ? number_to_human_size(file_size) : file_size
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

      def tempdir(file, prefix:)
        dest_path ||= File.join(File.dirname(file), prefix)
        dest_file = File.join(dest_path, File.basename(file))

        Dir.mkdir(dest_path, 0_700) unless Dir.exist?(dest_path)

        dest_file
      end

    end

    module DefineMethod
      def define_instance_method(key, value)
        instance_variable_set("@#{key}", value)
        self.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{key}                      # def package
            return @#{key} if @#{key}     #   return @package if @package
                                          #
            @#{key} ||= value             #   @package ||= value
          end                             # end
        RUBY
      end
    end
  end
end
