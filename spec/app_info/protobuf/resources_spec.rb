describe AppInfo::Protobuf::Resources do
  PACKAGE_NAME = 'com.icyleaf.appinfodemo'
  TYPES = %w[
    anim animator attr bool color dimen drawable id integer interpolator
    layout mipmap navigation plurals string style styleable xml
  ].freeze


  let(:app) { AppInfo::AAB.new(fixture_path('apps/android.aab')) }
  subject { app.resource }

  it { expect(subject).to be_kind_of AppInfo::Protobuf::Resources }
  it { expect(subject.packages.size).to eq(1) }

  it { expect(subject.packages.has_key?(PACKAGE_NAME)).to be_truthy }

  it { expect(subject.packages[PACKAGE_NAME]).to be_kind_of AppInfo::Protobuf::Resources::Package }

  context '.tool_fingerprint' do
    let(:tool_fingerprint) { subject.tool_fingerprint[0] }
    it { expect(tool_fingerprint).to be_kind_of Aapt::Pb::ToolFingerprint }
    it { expect(tool_fingerprint.version).to eq '2.19-7396180' }
    it { expect(tool_fingerprint.tool).to eq 'Android Asset Packaging Tool (aapt)' }
  end

  context '.find' do
    it { expect(subject.find('string/app_name').value).to eq('AppInfoDemo') }
    it { expect(subject.find('string/app_name', locale: 'zh-CN').value).to eq('AppInfo演示') }
    it { expect(subject.find('android:color/white').value).to eq('#FFFFFFFF') }
    it { expect(subject.find('android:color/white', locale: 'foobar').value).to eq('#FFFFFFFF') } # default_value

    it { expect(subject.find('unkown')).to be_nil }
    it { expect(subject.find('unkown/404')).to be_nil }
  end

  context '.packages' do
    let(:package) { subject.packages[PACKAGE_NAME] }

    it { expect(package.name).to eq(PACKAGE_NAME) }
    it { expect(package.name).to eq(PACKAGE_NAME) }
    it { expect(package.types).to eq(TYPES) }

    TYPES.each do |type|
      it "should has #{type} method" do
        expect(package.respond_to?(type.to_sym)).to be_truthy
        expect(package.entries(type)).not_to be_nil
      end
    end
  end
end
