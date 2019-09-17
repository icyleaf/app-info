require 'securerandom'

MATCH_FILE_TYPES = {
  'android.apk' => :apk,
  'ipad.ipa' => :ipa,
  'iphone.ipa' => :ipa,
  'tv.apk' => :apk,
  'wear.apk' => :apk,
  'multi_ios.dSYM.zip' => :dsym,
  'single_ios.dSYM.zip' => :dsym
}.freeze

describe AppInfo do
  Dir.glob(File.expand_path('fixtures/**/*', __dir__)) do |path|
    next if File.directory? path

    filename = File.basename(path)
    file_type = MATCH_FILE_TYPES[filename] || :unkown
    context "file #{filename}" do
      it "should detect file type is #{file_type}" do
        expect(AppInfo.detect_file_type(path)).to eq file_type
      end

      if file_type == :unkown
        it 'should throwa an exception when not matched' do
          expect do
            AppInfo.parse(path)
          end.to raise_error(AppInfo::NotAppError)
        end
      else
        it 'should parse' do
          parse = AppInfo.parse(path)
          case file_type
          when :ipa
            expect(parse.class).to eq(AppInfo::Parser::IPA)
          when :apk
            expect(parse.class).to eq(AppInfo::Parser::APK)
          when :dsym
            expect(parse.class).to eq(AppInfo::Parser::DSYM)
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
      end.to raise_error(AppInfo::NotAppError)
    end
  end
end
