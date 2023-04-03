# frozen_string_literal: true

require 'zip'
require 'tmpdir'
require 'fileutils'
require 'securerandom'

module AppInfo::Helper
  module Archive
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
end
