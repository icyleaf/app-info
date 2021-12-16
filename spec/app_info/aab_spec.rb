describe AppInfo::APK do
  describe '#PhoneOrTablet' do
    let(:file) { fixture_path('apps/android.aab') }
    subject { AppInfo::AAB.new(file) }

    after { subject.clear! }

    it { expect(subject.size).to eq(3618865) }
    it { expect(subject.size(human_size: true)).to eq('3.45 MB') }
    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be false }
    it { expect(subject.automotive?).to be false }
    it { expect(subject.os).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.release_version).to eq('2.1.0') }
    it { expect(subject.build_version).to eq('10') }
    it { expect(subject.name).to eq('AppInfoDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfodemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfodemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 14 }
    it { expect(subject.target_sdk_version).to eq 31 }
    it { expect(subject.deep_links).to eq(['icyleaf.com']) }
    it { expect(subject.schemes).to eq(['appinfo']) }
    it { expect(subject.certificates.first).to be_kind_of(AppInfo::APK::Certificate) }
    it { expect(subject.certificates.first.path).to eq('META-INF/KEY0.RSA') }
    it { expect(subject.certificates.first.certificate).to be_kind_of(OpenSSL::X509::Certificate) }
    it { expect(subject.signs.first).to be_kind_of(AppInfo::APK::Sign) }
    it { expect(subject.signs.first.path).to eq('META-INF/KEY0.RSA') }
    it { expect(subject.signs.first.sign).to be_kind_of(OpenSSL::PKCS7) }
    it { expect(subject.activities.size).to eq(2) }
    it { expect(subject.services.size).to eq(0) }
    it { expect(subject.components.size).to eq(1) }
    it { expect(subject.use_permissions).to eq(%w[android.permission.ACCESS_NETWORK_STATE]) }
    it { expect(subject.use_features).to eq(%w[android.hardware.bluetooth]) }
    it { expect(subject.manifest).to be_kind_of AppInfo::Protobuf::Manifest }
  end
end
