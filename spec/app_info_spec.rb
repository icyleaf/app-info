# frozen_string_literal: true

require 'securerandom'

MATCH_FILE_TYPES = {
  'android.apk' => :apk,
  'tv.apk' => :apk,
  'wear.apk' => :apk,
  'ipad.ipa' => :ipa,
  'iphone.ipa' => :ipa,
  'embedded.ipa' => :ipa,
  'multi_ios.dSYM.zip' => :dsym,
  'single_ios.dSYM.zip' => :dsym,
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
}

describe AppInfo do
  Dir.glob(File.expand_path('fixtures/**/*', __dir__)) do |path|
    next if File.directory? path
    next if path.include?('payload')

    filename = File.basename(path)
    file_type = MATCH_FILE_TYPES[filename] || :unkown
    context "file #{filename}" do
      it "should detect file type is #{file_type}" do
        expect(AppInfo.file_type(path)).to eq file_type
      end

      if file_type == :unkown
        it 'should throwa an exception when not matched' do
          expect do
            AppInfo.parse(path)
          end.to raise_error(AppInfo::UnkownFileTypeError)
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
      end.to raise_error(AppInfo::UnkownFileTypeError)
    end
  end
end
