# frozen_string_literal: true

require 'app_info/util'

module AppInfo
  # Proguard parser
  class Proguard
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def file_type
      AppInfo::Platform::PROGUARD
    end

    def mapping?
      File.exist?(mapping_path)
    end

    def mainfest?
      File.exist?(mainfest_path)
    end

    def symbol?
      File.exist?(symbol_path)
    end
    alias resource? symbol?

    private

    def mapping_path
      @mapping_path ||= Dir.glob(File.join(contents, '*mapping*.txt')).first
    end

    def mainfest_path
      @mainfest_path ||= File.join(contents, 'AndroidManifest.xml')
    end

    def symbol_path
      @symbol_path ||= File.join(contents, 'R.txt')
    end
    alias resource_path symbol_path

    def contents
      @contents ||= Util.unarchive(@file, path: 'proguard')
    end
  end
end
