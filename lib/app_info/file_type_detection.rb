# frozen_string_literal: true

module AppInfo
  module FileTypeDetection
    # Detect file type by reading file header
    #
    # TODO: This can be better solution, if anyone knows, tell me please.
    def file_type(file)
      header_hex = ::File.read(file, 100)
      case header_hex
      when ZIP_RETGEX
        detect_zip_file(file)
      when PE_REGEX
        Format::PE
      when PLIST_REGEX, BPLIST_REGEX
        Format::MOBILEPROVISION
      else
        Format::UNKNOWN
      end
    end

    private

    # Detect file type for zip files
    def detect_zip_file(file)
      Zip.warn_invalid_date = false
      zip_file = Zip::File.open(file)

      return Format::PROGUARD if proguard_clues?(zip_file)
      return Format::APK if apk_clues?(zip_file)
      return Format::AAB if aab_clues?(zip_file)
      return Format::MACOS if macos_clues?(zip_file)
      return Format::PE if pe_clues?(zip_file)
      return Format::HAP if hap_clues?(zip_file)
      return Format::HAPP if happ_clues?(zip_file)
      return Format::UNKNOWN unless clue = other_clues?(zip_file)

      clue
    ensure
      zip_file.close
    end

    # Check for Proguard clues in zip file
    def proguard_clues?(zip_file)
      !zip_file.glob('*mapping*.txt').empty?
    end

    # Check for APK clues in zip file
    def apk_clues?(zip_file)
      !zip_file.find_entry('AndroidManifest.xml').nil? &&
        !zip_file.find_entry('classes.dex').nil?
    end

    # Check for AAB clues in zip file
    def aab_clues?(zip_file)
      !zip_file.find_entry('base/manifest/AndroidManifest.xml').nil? &&
        !zip_file.find_entry('BundleConfig.pb').nil?
    end

    # Check for macOS clues in zip file
    def macos_clues?(zip_file)
      !zip_file.glob('*/Contents/MacOS/*').empty? &&
        !zip_file.glob('*/Contents/Info.plist').empty?
    end

    # Check for PE clues in zip file
    def pe_clues?(zip_file)
      !zip_file.glob('*.exe').empty?
    end

    # Check for HAP clues in zip file
    def hap_clues?(zip_file)
      !zip_file.find_entry('pack.info').nil? && !zip_file.find_entry('module.json').nil?
    end

    # Check for HAPP clues in zip file
    def happ_clues?(zip_file)
      pack_info_count = 0
      hap_count = 0

      zip_file.each do |f|
        path = f.name

        if path == 'pack.info'
          pack_info_count += 1
        elsif path.end_with?('.hap')
          hap_count += 1
        else
          return false
        end
      end

      pack_info_count == 1 && hap_count >= 1
    end

    # Check for other clues in zip file
    def other_clues?(zip_file)
      zip_file.each do |f|
        path = f.name

        return Format::IPA if path.include?('Payload/') && path.end_with?('Info.plist')
        return Format::DSYM if path.include?('Contents/Resources/DWARF/')
      end
    end

    ZIP_RETGEX = /^\x50\x4b\x03\x04/.freeze
    PE_REGEX = /^MZ/.freeze
    PLIST_REGEX = /\x3C\x3F\x78\x6D\x6C/.freeze
    BPLIST_REGEX = /^\x62\x70\x6C\x69\x73\x74/.freeze
  end
end
