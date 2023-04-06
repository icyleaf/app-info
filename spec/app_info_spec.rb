# frozen_string_literal: true

require 'securerandom'

MATCH_FILE_TYPES = {
  'android.apk' => :apk,
  'android-v1-v2-signed.apk' => :apk,
  'android-v1-v2-v3-signed.apk' => :apk,
  'android-v2-signed-only.apk' => :apk,
  'android-v3-signed-only.apk' => :apk,
  'tv.apk' => :apk,
  'wear.apk' => :apk,
  'automotive.apk' => :apk,
  'android.aab' => :aab,
  'android-31.aab' => :aab,
  'ipad.ipa' => :ipa,
  'iphone.ipa' => :ipa,
  'embedded.ipa' => :ipa,
  'iOS-single-dSYM-with-single-macho.zip' => :dsym,
  'iOS-single-dSYM-with-multi-macho.zip' => :dsym,
  'iOS-mutli-dSYMs-wrapped-by-folder.zip' => :dsym,
  'iOS-mutli-dSYMs-directly.zip' => :dsym,
  'bplist.mobileprovision' => :mobileprovision,
  'plist.mobileprovision' => :mobileprovision,
  'profile.mobileprovision' => :mobileprovision,
  'signed_plist.mobileprovision' => :mobileprovision,
  'ios_adhoc.mobileprovision' => :mobileprovision,
  'ios_appstore.mobileprovision' => :mobileprovision,
  'ios_development.mobileprovision' => :mobileprovision,
  'macos_appstore.provisionprofile' => :mobileprovision,
  'macos_development.provisionprofile' => :mobileprovision,
  'single_mapping.zip' => :proguard,
  'full_mapping.zip' => :proguard,
  'macos.zip' => :macos,
  'macos-signed.zip' => :macos,
  'win-TopBar-v0.1.1.zip' => :pe,
  'win-upx.exe' => :pe
}

describe AppInfo do
  Dir.glob(File.expand_path('fixtures/**/*', __dir__)) do |path|
    next if File.directory? path
    next if path.include?('payload')

    filename = File.basename(path)
    file_type = MATCH_FILE_TYPES[filename] || AppInfo::Format::UNKNOWN
    context "file #{filename}" do
      it "should detect file type is #{file_type}" do
        expect(AppInfo.file_type(path)).to eq file_type
      end

      if file_type == AppInfo::Format::UNKNOWN
        it 'should throwa an exception when not matched' do
          expect do
            AppInfo.parse(path)
          end.to raise_error(AppInfo::UnknownFormatError)
        end
      else
        it 'should parse' do
          parse = AppInfo.parse(path)
          case file_type
          when :ipa
            expect(parse).to be_a(AppInfo::IPA)
          when :apk
            expect(parse).to be_a(AppInfo::APK)
          when :dsym
            expect(parse).to be_a(AppInfo::DSYM)
          when :mobileprovision
            expect(parse).to be_a(AppInfo::MobileProvision)
          when :macos
            expect(parse).to be_a(AppInfo::Macos)
          when :pe
            expect(parse).to be_a(AppInfo::PE)
          end
        end
      end
    end
  end

  it 'should throwa an exception when file is not exist' do
    file = 'path/to/your/file'
    expect do
      AppInfo.parse(file)
    end.to raise_error(AppInfo::NotFoundError)
  end

  %w(txt pdf app zip rar).each do |ext|
    it "should throwa an exception when file is #{ext} type" do
      filename = "#{SecureRandom.uuid}.#{ext}"
      file = Tempfile.new(filename)

      expect do
        AppInfo.parse(file.path)
      end.to raise_error(AppInfo::UnknownFormatError)
    end
  end
end
