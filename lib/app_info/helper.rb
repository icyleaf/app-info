# frozen_string_literal: true

require 'tmpdir'

module AppInfo
  # App format
  module Format
    # iOS
    IPA = :ipa
    INFOPLIST = :infoplist
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
        number = ::File.size(file)
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
      def unarchive(file, prefix:, dest_path: '/tmp')
        base_path = Dir.mktmpdir("appinfo-#{prefix}", dest_path)
        Zip::File.open(file) do |zip_file|
          if block_given?
            yield base_path, zip_file
          else
            zip_file.each do |f|
              f_path = ::File.join(base_path, f.name)
              FileUtils.mkdir_p(::File.dirname(f_path))
              zip_file.extract(f, f_path) unless ::File.exist?(f_path)
            end
          end
        end

        base_path
      end

      def tempdir(file, prefix:, system: false)
        base_path = system ? '/tmp' : ::File.dirname(file)
        full_prefix = "appinfo-#{prefix}-#{::File.basename(file, '.*')}"
        dest_path = Dir.mktmpdir(full_prefix, base_path)
        ::File.join(dest_path, ::File.basename(file))
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

    module SignatureBlock
      def length_prefix_block(io, size: Android::Signature::UINT32_SIZE, raw: false)
        offset = io.size - io.pos
        if offset < Android::Signature::UINT32_SIZE
          raise SecurityError,
                'Remaining buffer too short to contain length of length-prefixed field.'
        end

        size = io.read(size).unpack1('I')
        raise SecurityError, 'Negative length' if size.negative?

        if size > io.size
          message = "Underflow while reading length-prefixed value. #{size} > #{io.size}"
          raise SecurityError, message
        end

        raw_data = io.read(size)
        raw ? raw_data : StringIO.new(raw_data)
      end

      # Only use for uint32 length-prefixed block
      def loop_length_prefix_io(io, name:, max_bytes: nil, raw: false, logger: nil, &block)
        index = 0
        until io.eof?
          logger&.debug "#{name} count ##{index}"
          buffer = length_prefix_block(io, raw: raw)
          left_bytes_check(buffer, max_bytes) do |left_bytes|
            "#{name} too short: #{left_bytes} < #{max_bytes}"
          end

          block.call(buffer)
          index += 1
        end
      end

      # Signature certificate identifiers
      SIG_RSA_PSS_WITH_SHA256 = [0x01, 0x01, 0x00, 0x00].freeze                # 0x0101
      SIG_RSA_PSS_WITH_SHA512 = [0x02, 0x01, 0x00, 0x00].freeze                # 0x0102
      SIG_RSA_PKCS1_V1_5_WITH_SHA256 = [0x03, 0x01, 0x00, 0x00].freeze         # 0x0103
      SIG_RSA_PKCS1_V1_5_WITH_SHA512 = [0x04, 0x01, 0x00, 0x00].freeze         # 0x0104
      SIG_ECDSA_WITH_SHA256 = [0x01, 0x02, 0x00, 0x00].freeze                  # 0x0201
      SIG_ECDSA_WITH_SHA512 = [0x02, 0x02, 0x00, 0x00].freeze                  # 0x0202
      SIG_DSA_WITH_SHA256 = [0x01, 0x03, 0x00, 0x00].freeze                    # 0x0301
      SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256 = [0x21, 0x04, 0x00, 0x00].freeze  # 0x0421
      SIG_VERITY_ECDSA_WITH_SHA256 = [0x23, 0x04, 0x00, 0x00].freeze           # 0x0423
      SIG_VERITY_DSA_WITH_SHA256 = [0x25, 0x04, 0x00, 0x00].freeze             # 0x0425

      SIG_STRIPPING_PROTECTION_ATTR_ID = [0x0d, 0xf0, 0xef, 0xbe].freeze       # 0xbeeff00d

      def compare_algorithem(source, target)
        case algorithem_priority(source) <=> algorithem_priority(target)
        when -1
          target
        else
          source
        end
      end

      def algorithem_priority(algorithm)
        case algorithm
        when SIG_RSA_PSS_WITH_SHA256,
          SIG_RSA_PKCS1_V1_5_WITH_SHA256,
          SIG_ECDSA_WITH_SHA256,
          SIG_DSA_WITH_SHA256
          1
        when SIG_RSA_PSS_WITH_SHA512,
          SIG_RSA_PKCS1_V1_5_WITH_SHA512,
          SIG_ECDSA_WITH_SHA512
          2
        when SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256,
          SIG_VERITY_ECDSA_WITH_SHA256,
          SIG_VERITY_DSA_WITH_SHA256
          3
        end
      end

      def algorithm_method(algorithm)
        case algorithm
        when SIG_RSA_PSS_WITH_SHA256, SIG_RSA_PSS_WITH_SHA512,
          SIG_RSA_PKCS1_V1_5_WITH_SHA256, SIG_RSA_PKCS1_V1_5_WITH_SHA512,
          SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256
          :rsa
        when SIG_ECDSA_WITH_SHA256, SIG_ECDSA_WITH_SHA512, SIG_VERITY_ECDSA_WITH_SHA256
          :ec
        when SIG_DSA_WITH_SHA256, SIG_VERITY_DSA_WITH_SHA256
          :dsa
        end
      end

      def algorithm_match(algorithm)
        case algorithm
        when SIG_RSA_PSS_WITH_SHA256, SIG_RSA_PKCS1_V1_5_WITH_SHA256,
          SIG_ECDSA_WITH_SHA256, SIG_DSA_WITH_SHA256,
          SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256, SIG_VERITY_ECDSA_WITH_SHA256,
          SIG_VERITY_DSA_WITH_SHA256
          'SHA256'
        when SIG_RSA_PSS_WITH_SHA512, SIG_RSA_PKCS1_V1_5_WITH_SHA512, SIG_ECDSA_WITH_SHA512
          'SHA512'
        end
      end

      def left_bytes_check(io, max_bytes, message = nil, &block)
        return if max_bytes.nil?

        left_bytes = io.size - io.pos
        return left_bytes if left_bytes.zero?

        message ||= if block_given?
                      block.call(left_bytes)
                    else
                      "IO too short: #{offset} < #{max_bytes}"
                    end

        raise SecurityError, message if left_bytes < max_bytes

        left_bytes
      end
    end
  end
end
