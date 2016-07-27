describe AppInfo::Parser::APK do
  describe '#PhoneOrTablet' do
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/android.apk' }
    subject { AppInfo::Parser::APK.new(file) }

    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be false }
    it { expect(subject.os).to eq AppInfo::Parser::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk.class).to eq Android::Apk }
    it { expect(subject.build_version).to eq('5') }
    it { expect(subject.release_version).to eq('1.2.3') }
    it { expect(subject.name).to eq('AppInfoDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.appinfodemo') }
    it { expect(subject.identifier).to eq('com.icyleaf.appinfodemo') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.min_sdk_version).to eq 14 }
    it { expect(subject.target_sdk_version).to eq 23 }
    it { expect(subject.manifest).to be_kind_of Android::Manifest }
    it { expect(subject.manifest.use_permissions.first).to eq('android.permission.INTERNET') }
  end

  describe '#Wear' do
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/wear.apk' }
    subject { AppInfo::Parser::APK.new(file) }

    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be true }
    it { expect(subject.tv?).to be false }
    it { expect(subject.os).to eq AppInfo::Parser::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk.class).to eq Android::Apk }
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
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/tv.apk' }
    subject { AppInfo::Parser::APK.new(file) }

    it { expect(subject.os).to eq 'Android' }
    it { expect(subject.wear?).to be false }
    it { expect(subject.tv?).to be true }
    it { expect(subject.os).to eq AppInfo::Parser::Platform::ANDROID }
    it { expect(subject.file).to eq file }
    it { expect(subject.apk.class).to eq Android::Apk }
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
