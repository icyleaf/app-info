describe AppInfo::APK do
  describe '#PhoneOrTablet' do
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    context 'with Android min SDK under 24' do
      let(:file) { fixture_path('apps/android.apk') }
      it { expect(subject.size).to eq(4000563) }
      it { expect(subject.size(human_size: true)).to eq('3.82 MB') }
      it { expect(subject.file_type).to eq :apk }
      it { expect(subject.file_type).to eq AppInfo::Format::APK }
      it { expect(subject.platform).to eq 'Android' }
      it { expect(subject.platform).to eq AppInfo::Platform::ANDROID }
      it { expect(subject.wear?).to be false }
      it { expect(subject.tv?).to be false }
      it { expect(subject.automotive?).to be false }
      it { expect(subject.device_type).to eq AppInfo::APK::Device::PHONE }
      it { expect(subject.file).to eq file }
      it { expect(subject.apk).to be_a Android::Apk }
      it { expect(subject.release_version).to eq('2.1.0') }
      it { expect(subject.build_version).to eq('10') }
      it { expect(subject.name).to eq('AppInfoDemo') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.appinfodemo') }
      it { expect(subject.identifier).to eq('com.icyleaf.appinfodemo') }
      it { expect(subject.icons.length).not_to be_nil }
      it { expect(subject.min_sdk_version).to eq 14 }
      it { expect(subject.target_sdk_version).to eq 31 }
      it { expect(subject.sign_version).to eq 'v1' }
      it { expect(subject.activities.size).to eq(2) }
      it { expect(subject.services.size).to eq(0) }
      it { expect(subject.components.size).to eq(2) }
      it { expect(subject.use_permissions.first).to eq('android.permission.ACCESS_NETWORK_STATE') }
      it { expect(subject.use_features.first).to eq('android.hardware.bluetooth') }
      it { expect(subject.manifest).to be_kind_of Android::Manifest }
      it { expect(subject.manifest.use_permissions).to eq(subject.use_permissions) }
      it { expect(subject.deep_links).to eq(['icyleaf.com']) }
      it { expect(subject.schemes).to eq(['appinfo']) }
      it { expect(subject.certificates.first).to be_kind_of(OpenSSL::X509::Certificate) }
      it { expect(subject.signs.first).to be_kind_of(OpenSSL::PKCS7) }
    end

    context 'with Android min SDK 24+' do
      let(:file) { fixture_path('apps/android-24.apk') }
      it { expect(subject.sign_version).to eq 'unknown' }
    end
  end

  describe '#Wear' do
    let(:file) { fixture_path('apps/wear.apk') }
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    it { expect(subject.file_type).to eq :apk }
    it { expect(subject.file_type).to eq AppInfo::Format::APK }
    it { expect(subject.platform).to eq 'Android' }
    it { expect(subject.platform).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.wear?).to be true }
    it { expect(subject.tv?).to be false }
    it { expect(subject.automotive?).to be false }
    it { expect(subject.device_type).to eq AppInfo::APK::Device::WATCH }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
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

    it { expect(subject.file_type).to eq :apk }
    it { expect(subject.file_type).to eq AppInfo::Format::APK }
    it { expect(subject.platform).to eq 'Android' }
    it { expect(subject.platform).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be true }
    it { expect(subject.automotive?).to be false }
    it { expect(subject.device_type).to eq AppInfo::APK::Device::TV }
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

  describe '#Automotive' do
    let(:file) { fixture_path('apps/automotive.apk') }
    subject { AppInfo::APK.new(file) }

    after { subject.clear! }

    it { expect(subject.file_type).to eq :apk }
    it { expect(subject.file_type).to eq AppInfo::Format::APK }
    it { expect(subject.platform).to eq 'Android' }
    it { expect(subject.platform).to eq AppInfo::Platform::ANDROID }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be false }
    it { expect(subject.automotive?).to be true }
    it { expect(subject.device_type).to eq AppInfo::APK::Device::AUTOMOTIVE }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk).to be_a Android::Apk }
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
