# frozen_string_literal: true

require 'zip'
require 'fileutils'
require 'securerandom'

module AppInfo
  class Error < StandardError; end

  class NotFoundError < Error; end

  class UnkownFileTypeError < Error; end

  # Icon Key
  ICON_KEYS = {
    AppInfo::Device::IPHONE => ['CFBundleIcons'],
    AppInfo::Device::IPAD => ['CFBundleIcons~ipad'],
    AppInfo::Device::UNIVERSAL => ['CFBundleIcons', 'CFBundleIcons~ipad'],
    AppInfo::Device::MACOS => %w[CFBundleIconFile CFBundleIconName]
  }.freeze

  FILE_SIZE_UNITS = %w[B KB MB GB TB].freeze

  # AppInfo Util
  module Util
    def self.format_key(key)
      key = key.to_s
      return key unless key.include?('_')

      key.split('_').map(&:capitalize).join
    end

    def self.file_size(file, human_size)
      file_size = File.size(file)
      human_size ? size_to_human_size(file_size) : file_size
    end

    def self.size_to_human_size(number)
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

    # Unarchive zip file
    #
    # source: https://github.com/soffes/lagunitas/blob/master/lib/lagunitas/ipa.rb
    def self.unarchive(file, path: nil)
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

    def self.tempdir(file, prefix:)
      dest_path ||= File.join(File.dirname(file), prefix)
      dest_file = File.join(dest_path, File.basename(file))

      Dir.mkdir(dest_path, 0_700) unless Dir.exist?(dest_path)

      dest_file
    end
  end
end
