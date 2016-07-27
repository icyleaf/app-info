require 'securerandom'

describe AppInfo do
  let(:apk_file) { File.dirname(__FILE__) + '/fixtures/apps/android.apk' }
  let(:ipa_file) { File.dirname(__FILE__) + '/fixtures/apps/iphone.ipa' }

  it 'should parse when file extion is .ipa' do
    file = AppInfo.parse(ipa_file)
    expect(file.class).to eq(AppInfo::Parser::IPA)
  end

  it 'should dump when file extion is .apk' do
    file = AppInfo.dump(ipa_file)
    expect(file.class).to eq(AppInfo::Parser::IPA)
  end

  it 'should throwa an exception when file is not exist' do
    file = 'path/to/your/file'
    expect do
      AppInfo.parse(file)
    end.to raise_error(AppInfo::NotFoundError)
  end

  %w(txt pdf app zip rar).each do |ext|
    it "should throwa an exception when file is .#{ext}" do
      filename = "#{SecureRandom.uuid}.#{ext}"
      file = Tempfile.new(filename)

      expect do
        AppInfo.parse(file.path)
      end.to raise_error(AppInfo::NotAppError)
    end
  end
end
