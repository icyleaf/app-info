describe AppInfo::APK do
  describe '#PhoneOrTablet' do
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    context 'with Android min SDK under 24' do
      let(:file) { fixture_path('apps/android.apk') }

      it { expect(subject.file).to eq file }
      it { expect(subject.size).to eq(4000563) }
      it { expect(subject.size(human_size: true)).to eq('3.82 MB') }
      it { expect(subject.format).to eq(AppInfo::Format::APK) }
      it { expect(subject.format).to eq(:apk) }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
      it { expect(subject.manufacturer).to eq(:google) }
      it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
      it { expect(subject.platform).to eq(:android) }
      it { expect(subject.device).to eq(AppInfo::Device::Google::PHONE) }
      it { expect(subject.device).to eq(:phone) }
      it { expect(subject).not_to be_tablet }
      it { expect(subject).not_to be_watch }
      it { expect(subject).not_to be_television }
      it { expect(subject).not_to be_automotive }
      it { expect(subject.apk).to be_a Android::Apk }
      it { expect(subject.release_version).to eq('2.1.0') }
      it { expect(subject.build_version).to eq('10') }
      it { expect(subject.name).to eq('AppInfoDemo') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.appinfodemo') }
      it { expect(subject.identifier).to eq('com.icyleaf.appinfodemo') }
      it { expect(subject.min_sdk_version).to eq 14 }
      it { expect(subject.target_sdk_version).to eq 31 }
      it { expect(subject.activities.size).to eq(2) }
      it { expect(subject.services.size).to eq(0) }
      it { expect(subject.components.size).to eq(2) }
      it { expect(subject.use_permissions.first).to eq('android.permission.ACCESS_NETWORK_STATE') }
      it { expect(subject.use_features.first).to eq('android.hardware.bluetooth') }
      it { expect(subject.manifest).to be_kind_of Android::Manifest }
      it { expect(subject.manifest.use_permissions).to eq(subject.use_permissions) }
      it { expect(subject.deep_links).to eq(['icyleaf.com']) }
      it { expect(subject.schemes).to eq(['appinfo']) }

      # TODO: it will remove soon.
      it { expect(subject.certificates).to be_kind_of(Array) }
      it { expect(subject.certificates[0]).to be_kind_of(AppInfo::Certificate) }
      it { expect(subject.signs).to be_kind_of(Hash) }
      it { expect(subject.signs).to have_key('META-INF/CERT.RSA') }
      it { expect(subject.signs['META-INF/CERT.RSA']).to be_kind_of(OpenSSL::PKCS7) }

      it { expect(subject.icons.size).to eq(6) }
      it 'should return non xml(symbol) icons' do
        icons = subject.icons(exclude: :xml)
        expect(icons.size).to eq(5)

        icons.each do |icon|
          expect(File.extname(icon[:name])).not_to eq('.xml')
        end
      end

      it 'should return non webp(string) icons' do
        icons = subject.icons(exclude: 'webp')
        expect(icons.size).to eq(1)

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

  describe '#Wear' do
    let(:file) { fixture_path('apps/wear.apk') }
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
    it { expect(subject.format).to eq(AppInfo::Format::APK) }
    it { expect(subject.format).to eq(:apk) }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
    it { expect(subject.manufacturer).to eq(:google) }
    it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
    it { expect(subject.platform).to eq(:android) }
    it { expect(subject.device).to eq(AppInfo::Device::Google::WATCH) }
    it { expect(subject.device).to eq(:watch) }
    it { expect(subject).not_to be_tablet }
    it { expect(subject).to be_watch }
    it { expect(subject).not_to be_television }
    it { expect(subject).not_to be_automotive }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.name).to eq('AppInfoWearDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfoweardemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfoweardemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 21 }
    it { expect(subject.target_sdk_version).to eq 23 }
  end

  describe '#TV' do
    let(:file) { fixture_path('apps/tv.apk') }
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
    it { expect(subject.format).to eq(AppInfo::Format::APK) }
    it { expect(subject.format).to eq(:apk) }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
    it { expect(subject.manufacturer).to eq(:google) }
    it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
    it { expect(subject.platform).to eq(:android) }
    it { expect(subject.device).to eq(AppInfo::Device::Google::TELEVISION) }
    it { expect(subject.device).to eq(:television) }
    it { expect(subject).not_to be_tablet }
    it { expect(subject).not_to be_watch }
    it { expect(subject).to be_television }
    it { expect(subject).not_to be_automotive }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('AppInfoTVDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfotvdemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfotvdemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 23 }
    it { expect(subject.target_sdk_version).to eq 23 }
  end

  describe '#Automotive' do
    let(:file) { fixture_path('apps/automotive.apk') }
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
    it { expect(subject.format).to eq(AppInfo::Format::APK) }
    it { expect(subject.format).to eq(:apk) }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
    it { expect(subject.manufacturer).to eq(:google) }
    it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
    it { expect(subject.platform).to eq(:android) }
    it { expect(subject.device).to eq(AppInfo::Device::Google::AUTOMOTIVE) }
    it { expect(subject.device).to eq(:automotive) }
    it { expect(subject).not_to be_tablet }
    it { expect(subject).not_to be_watch }
    it { expect(subject).not_to be_television }
    it { expect(subject).to be_automotive }
    it { expect(subject.build_version).to eq('3') }
    it { expect(subject.release_version).to eq('2.0') }
    it { expect(subject.name).to eq('AutoMotive') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfo.automotive') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfo.automotive') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 29 }
    it { expect(subject.target_sdk_version).to eq 31 }
  end
end
