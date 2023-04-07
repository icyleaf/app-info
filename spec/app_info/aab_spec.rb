describe AppInfo::APK do
  describe '#PhoneOrTablet' do
    subject { AppInfo::AAB.new(file) }
    after { subject.clear! }

    context 'with Android target SDK under 31' do
      let(:file) { fixture_path('apps/android.aab') }

      it { expect(subject.file).to eq file }
      it { expect(subject.size).to eq(3618865) }
      it { expect(subject.size(human_size: true)).to eq('3.45 MB') }
      it { expect(subject.format).to eq(AppInfo::Format::AAB) }
      it { expect(subject.format).to eq(:aab) }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
      it { expect(subject.manufacturer).to eq(:google) }
      it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
      it { expect(subject.platform).to eq(:android) }
      it { expect(subject.device).to eq(AppInfo::Device::PHONE) }
      it { expect(subject.device).to eq(:phone) }
      it { expect(subject).not_to be_tablet }
      it { expect(subject).not_to be_watch }
      it { expect(subject).not_to be_television }
      it { expect(subject).not_to be_automotive }
      it { expect(subject.release_version).to eq('2.1.0') }
      it { expect(subject.build_version).to eq('10') }
      it { expect(subject.name).to eq('AppInfoDemo') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.appinfodemo') }
      it { expect(subject.icons.length).not_to be_nil }
      it { expect(subject.min_sdk_version).to eq 14 }
      it { expect(subject.target_sdk_version).to eq 31 }
      it { expect(subject.deep_links).to eq(['icyleaf.com']) }
      it { expect(subject.schemes).to eq(['appinfo']) }
      it { expect(subject.activities.size).to eq(2) }
      it { expect(subject.services.size).to eq(0) }
      it { expect(subject.components.size).to eq(1) }
      it { expect(subject.use_permissions).to eq(%w[android.permission.ACCESS_NETWORK_STATE]) }
      it { expect(subject.use_features).to eq(%w[android.hardware.bluetooth]) }
      it { expect(subject.manifest).to be_kind_of AppInfo::Protobuf::Manifest }
      it { expect(subject.manifest.label).to eq('AppInfoDemo') }
      it { expect(subject.manifest.label(locale: 'en')).to eq('AppInfoDemo') }
      it { expect(subject.manifest.label(locale: 'zh-CN')).to eq('AppInfo演示') }

      it { expect(subject.signs).to be_kind_of(Hash) }
      it { expect(subject.signs).to have_key('META-INF/KEY0.RSA') }
      it { expect(subject.signs['META-INF/KEY0.RSA']).to be_kind_of(OpenSSL::PKCS7) }
      it { expect(subject.certificates).to be_kind_of(Array) }
      it { expect(subject.certificates[0]).to be_kind_of(AppInfo::Certificate) }
    end

    context 'with Android target SDK above 31' do
      let(:file) { fixture_path('apps/android-31.aab') }

      it { expect(subject.file).to eq file }
      it { expect(subject.size).to eq(7448532) }
      it { expect(subject.size(human_size: true)).to eq('7.10 MB') }
      it { expect(subject.format).to eq(AppInfo::Format::AAB) }
      it { expect(subject.format).to eq(:aab) }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
      it { expect(subject.manufacturer).to eq(:google) }
      it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
      it { expect(subject.platform).to eq(:android) }
      it { expect(subject.device).to eq(AppInfo::Device::PHONE) }
      it { expect(subject.device).to eq(:phone) }
      it { expect(subject).not_to be_tablet }
      it { expect(subject).not_to be_watch }
      it { expect(subject).not_to be_television }
      it { expect(subject).not_to be_automotive }
      it { expect(subject.release_version).to eq('1.0') }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.name).to eq('My Application') }
      it { expect(subject.bundle_id).to eq('com.example.myapplication') }
      it { expect(subject.min_sdk_version).to eq 24 }
      it { expect(subject.target_sdk_version).to eq 33 }
      it { expect(subject.deep_links).to eq([]) }
      it { expect(subject.schemes).to eq([]) }
      it { expect(subject.activities.size).to eq(3) }
      it { expect(subject.services.size).to eq(0) }
      it { expect(subject.components.size).to eq(3) }
      it { expect(subject.use_permissions).to eq(%w[com.example.myapplication.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION]) }
      it { expect(subject.use_features).to be_nil }
      it { expect(subject.manifest).to be_kind_of AppInfo::Protobuf::Manifest }
      it { expect(subject.manifest.label).to eq('My Application') }
      it { expect(subject.manifest.label(locale: 'en')).to eq('My Application') }
      it { expect(subject.manifest.label(locale: 'zh-CN')).to eq('My Application') }
      it { expect(subject.certificates).to be_empty }
      it { expect(subject.signs).to be_empty }

      it { expect(subject.icons.size).to eq(7) }
      it 'should return non xml(symbol) icons' do
        icons = subject.icons(exclude: :xml)
        expect(icons.size).to eq(5)

        icons.each do |icon|
          expect(File.extname(icon[:name])).not_to eq('.xml')
        end
      end

      it 'should return non webp(string) icons' do
        icons = subject.icons(exclude: 'webp')
        expect(icons.size).to eq(2)

        icons.each do |icon|
          expect(File.extname(icon[:name])).not_to eq('.webp')
        end
      end

      it 'should return empty(array<string, symbol>) icons' do
        icons = subject.icons(exclude: [:xml, 'webp'])
        expect(icons.size).to eq(0)
      end
    end
  end
end
