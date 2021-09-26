describe AppInfo::Protobuf::Manifest do
  let(:app) { AppInfo::AAB.new(fixture_path('apps/android.aab')) }
  subject { app.manifest }

  ATTRIBUTES = %w(
    package version_code version_name
    compile_sdk_version platform_build_version_code
    compile_sdk_version_codename platform_build_version_name
  ).freeze

  CHILDREN = %w(uses_sdk uses_permission uses_feature application).freeze

  it { expect(subject).to be_kind_of AppInfo::Protobuf::Manifest }
  it { expect(subject).to be_kind_of AppInfo::Protobuf::Node }
  it { expect(subject.attributes.keys).to eq(ATTRIBUTES) }
  it { expect(subject.children.keys).to eq(CHILDREN) }

  ATTRIBUTES.each do |attr_name|
    context ".#{attr_name}" do
      it { expect(subject.respond_to?(attr_name.to_sym)).to be_truthy }
      it { expect(subject.send(attr_name.to_sym)).not_to be_kind_of AppInfo::Protobuf::Attribute }

      it 'should got value' do
        value = subject.send(attr_name.to_sym)
        case attr_name
        when 'package'
          expect(value).to eq('com.icyleaf.appinfo.aabdemo')
        when 'version_code'
          expect(value).to eq(1)
        when 'version_name'
          expect(value).to eq('1.0')
        when 'compile_sdk_version'
          expect(value).to eq(31)
        when 'platform_build_version_code'
          expect(value).to eq(31)
        when 'compile_sdk_version_codename'
          expect(value).to eq('12')
        end
      end
    end
  end

  CHILDREN.each do |child_name|
    context ".#{child_name}" do
      it { expect(subject.respond_to?(child_name.to_sym)).to be_truthy }
    end
  end

  it { expect(subject.label).to eq('AABDemo') }
  it { expect(subject.label(locale: 'zh-CN')).to eq('AAB演示') }
end
