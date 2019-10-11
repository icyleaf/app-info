describe AppInfo::APK do
  describe '#PhoneOrTablet' do
    let(:file) { File.dirname(__FILE__) + '/../fixtures/apps/android.apk' }
    subject { AppInfo::APK.new(file) }

    it { expect(subject.size).to eq(3070618) }
    it { expect(subject.size(humanable: true)).to eq('2.93 MB') }
    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be false }
    it { expect(subject.os).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
    it { expect(subject.build_version).to eq('5') }
    it { expect(subject.release_version).to eq('1.2.3') }
    it { expect(subject.name).to eq('AppInfoDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfodemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfodemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 14 }
    it { expect(subject.target_sdk_version).to eq 29 }
    it { expect(subject.certificates.first).to be_kind_of(AppInfo::APK::Certificate) }
    it { expect(subject.certificates.first.path).to eq('META-INF/CERT.RSA') }
    it { expect(subject.certificates.first.certificate).to be_kind_of(OpenSSL::X509::Certificate) }
    it { expect(subject.signs.first).to be_kind_of(AppInfo::APK::Sign) }
    it { expect(subject.signs.first.path).to eq('META-INF/CERT.RSA') }
    it { expect(subject.signs.first.sign).to be_kind_of(OpenSSL::PKCS7) }
    it { expect(subject.activities.size).to eq(1) }
    it { expect(subject.services.size).to eq(0) }
    it { expect(subject.components.size).to eq(1) }
    it { expect(subject.use_permissions.first).to eq('android.permission.BLUETOOTH') }
    it { expect(subject.manifest).to be_kind_of Android::Manifest }
    it { expect(subject.manifest.use_permissions).to eq(subject.use_permissions) }
  end

  describe '#Wear' do
    let(:file) { File.dirname(__FILE__) + '/../fixtures/apps/wear.apk' }
    subject { AppInfo::APK.new(file) }

    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be true }
    it { expect(subject.tv?).to be false }
    it { expect(subject.os).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('AppInfoWearDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfoweardemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfoweardemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 21 }
    it { expect(subject.target_sdk_version).to eq 23 }
  end

  describe '#TV' do
    let(:file) { File.dirname(__FILE__) + '/../fixtures/apps/tv.apk' }
    subject { AppInfo::APK.new(file) }

    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be true }
    it { expect(subject.os).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('AppInfoTVDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfotvdemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfotvdemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 23 }
    it { expect(subject.target_sdk_version).to eq 23 }
  end
end
