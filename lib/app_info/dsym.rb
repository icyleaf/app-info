# frozen_string_literal: true

require 'app_info/dsym/debug_info'

module AppInfo
  # DSYM parser
  class DSYM < File
    include Helper::Archive

    # @return [Symbol] {Manufacturer}
    def manufacturer
      Manufacturer::APPLE
    end

    # @return [nil]
    def each_file(&block)
      files.each { |file| block.call(file) }
    end
    alias each_objects each_file

    # @return [Array<DebugInfo>] dsym_files files by alphabetical order
    def files
      @files ||= Dir.children(contents).sort.each_with_object([]) do |file, obj|
        obj << DebugInfo.new(::File.join(contents, file))
      end
    end
    alias objects files

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @files = nil
    end

    # @return [String] contents path of dsym
    def contents
      @contents ||= lambda {
        return @file if ::File.directory?(@file)

        dsym_filenames = []
        unarchive(@file, prefix: 'dsym') do |base_path, zip_file|
          zip_file.each do |entry|
            file_path = entry.name
            next unless file_path.downcase.include?('.dsym/contents/')
            next if ::File.basename(file_path).start_with?('.')

            dsym_filename = file_path.split('/').select { |f| f.downcase.end_with?('.dsym') }.last
            dsym_filenames << dsym_filename unless dsym_filenames.include?(dsym_filename)

            unless file_path.start_with?(dsym_filename)
              file_path = file_path.split('/')[1..-1].join('/')
            end

            dest_path = ::File.join(base_path, file_path)
            FileUtils.mkdir_p(::File.dirname(dest_path))
            entry.extract(dest_path) unless ::File.exist?(dest_path)
          end
        end
      }.call
    end
  end
end
