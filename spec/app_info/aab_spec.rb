describe AppInfo::APK do
  describe '#PhoneOrTablet' do
    let(:file) { fixture_path('apps/android.aab') }
    subject { AppInfo::AAB.new(file) }

    after { subject.clear! }

    it { expect(subject.size).to eq(3066304) }
    it { expect(subject.size(human_size: true)).to eq('2.92 MB') }
    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be false }
    it { expect(subject.os).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.name).to eq('AABDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfo.aabdemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfo.aabdemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 21 }
    it { expect(subject.target_sdk_version).to eq 31 }
    it { expect(subject.certificates.first).to be_kind_of(AppInfo::APK::Certificate) }
    it { expect(subject.certificates.first.path).to eq('META-INF/DEFAULT_.RSA') }
    it { expect(subject.certificates.first.certificate).to be_kind_of(OpenSSL::X509::Certificate) }
    it { expect(subject.signs.first).to be_kind_of(AppInfo::APK::Sign) }
    it { expect(subject.signs.first.path).to eq('META-INF/DEFAULT_.RSA') }
    it { expect(subject.signs.first.sign).to be_kind_of(OpenSSL::PKCS7) }
    it { expect(subject.activities.size).to eq(1) }
    it { expect(subject.services.size).to eq(1) }
    it { expect(subject.components.size).to eq(3) }
    it { expect(subject.use_permissions.map(&:name)).to eq(%w[android.permission.ACCESS_FINE_LOCATION android.permission.ACCESS_NETWORK_STATE]) }
    it { expect(subject.use_features.map(&:name)).to eq(%w[android.hardware.bluetooth android.hardware.camera]) }
    it { expect(subject.manifest).to be_kind_of AppInfo::Protobuf::Manifest }
  end
end
