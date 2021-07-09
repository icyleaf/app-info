# frozen_string_literal: true

require 'zip'
require 'fileutils'
require 'securerandom'

module AppInfo
  # AppInfo Util
  module Util
    FILE_SIZE_UNITS = %w[B KB MB GB TB]

    def self.format_key(key)
      key = key.to_s
      return key unless key.include?('_')

      key.split('_').map(&:capitalize).join('')
    end

    def self.file_size(file, humanable)
      file_size = File.size(file)
      humanable ? size_to_humanable(file_size) : file_size
    end

    def self.size_to_humanable(number)
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
  end
end
