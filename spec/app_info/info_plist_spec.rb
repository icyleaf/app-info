describe AppInfo::InfoPlist do
  context 'when iPhone' do
    let(:app) { AppInfo::IPA.new(fixture_path('apps/iphone.ipa')) }
    subject { AppInfo::InfoPlist.new(app.info_path) }

    it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
    it { expect(subject.format).to eq :infoplist }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
    it { expect(subject.manufacturer).to eq(:apple) }
    it { expect(subject.platform).to eq(AppInfo::Platform::IOS) }
    it { expect(subject.platform).to eq(:ios) }
    it { expect(subject.device).to eq(AppInfo::Device::IPHONE) }
    it { expect(subject.device).to eq(:iphone) }
    it { expect(subject).to be_iphone }
    it { expect(subject).not_to be_ipad }
    it { expect(subject).not_to be_universal }
    it { expect(subject).not_to be_macos }
    it { expect(subject.build_version).to eq('5') }
    it { expect(subject.release_version).to eq('1.2.3') }
    it { expect(subject.name).to eq('AppInfoDemo') }
    it { expect(subject.bundle_name).to eq('AppInfoDemo') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.icyleaf.AppInfoDemo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.AppInfoDemo') }
    it { expect(subject.min_sdk_version).to eq('9.3') }
    it { expect(subject.min_os_version).to eq('9.3') }

    it { expect(subject.to_h).to be_a Hash }
    it { expect(subject['CFBundleVersion']).to eq('5') }
    it { expect(subject[:CFBundleShortVersionString]).to eq('1.2.3') }
    it { expect(subject.CFBundleShortVersionString).to eq('1.2.3') }
    it { expect(subject.c_f_bundle_short_version_string).to eq('1.2.3') }
    it { expect(subject.icons).to be_kind_of Array }
  end

  context 'when iPad' do
    let(:app) { AppInfo::IPA.new(fixture_path('apps/ipad.ipa')) }
    subject { AppInfo::InfoPlist.new(app.info_path) }

    it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
    it { expect(subject.format).to eq :infoplist }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
    it { expect(subject.manufacturer).to eq(:apple) }
    it { expect(subject.platform).to eq(AppInfo::Platform::IOS) }
    it { expect(subject.platform).to eq(:ios) }
    it { expect(subject.device).to eq(AppInfo::Device::IPAD) }
    it { expect(subject.device).to eq(:ipad) }
    it { expect(subject).not_to be_iphone }
    it { expect(subject).to be_ipad }
    it { expect(subject).not_to be_universal }
    it { expect(subject).not_to be_macos }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('bundle') }
    it { expect(subject.bundle_name).to eq('bundle') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.icyleaf.bundle') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.bundle') }
    it { expect(subject.min_sdk_version).to eq('9.3') }
    it { expect(subject.min_os_version).to eq('9.3') }

    it { expect(subject.to_h).to be_a Hash }
    it { expect(subject['CFBundleVersion']).to eq('1') }
    it { expect(subject[:CFBundleShortVersionString]).to eq('1.0') }
    it { expect(subject.CFBundleShortVersionString).to eq('1.0') }
    it { expect(subject.c_f_bundle_short_version_string).to eq('1.0') }
    it { expect(subject.icons).to be_kind_of Array }
  end

  context 'when Unversal of iOS' do
    let(:app) { AppInfo::IPA.new(fixture_path('apps/embedded.ipa')) }
    subject { AppInfo::InfoPlist.new(app.info_path) }

    it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
    it { expect(subject.format).to eq :infoplist }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
    it { expect(subject.manufacturer).to eq(:apple) }
    it { expect(subject.platform).to eq(AppInfo::Platform::IOS) }
    it { expect(subject.platform).to eq(:ios) }
    it { expect(subject.device).to eq(AppInfo::Device::UNIVERSAL) }
    it { expect(subject.device).to eq(:universal) }
    it { expect(subject).not_to be_iphone }
    it { expect(subject).not_to be_ipad }
    it { expect(subject).to be_universal }
    it { expect(subject).not_to be_macos }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('Demo') }
    it { expect(subject.bundle_name).to eq('Demo') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.icyleaf.test.Demo') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.test.Demo') }
    it { expect(subject.min_sdk_version).to eq('14.3') }
    it { expect(subject.min_os_version).to eq('14.3') }

    it { expect(subject.to_h).to be_a Hash }
    it { expect(subject['CFBundleVersion']).to eq('1') }
    it { expect(subject[:CFBundleShortVersionString]).to eq('1.0') }
    it { expect(subject.CFBundleShortVersionString).to eq('1.0') }
    it { expect(subject.c_f_bundle_short_version_string).to eq('1.0') }
    it { expect(subject.icons).to be_kind_of Array }
  end

  context 'when macOS' do
    let(:app) { AppInfo::Macos.new(fixture_path('apps/macos.zip')) }
    subject { AppInfo::InfoPlist.new(app.info_path) }

    it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
    it { expect(subject.format).to eq :infoplist }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
    it { expect(subject.manufacturer).to eq(:apple) }
    it { expect(subject.platform).to eq(AppInfo::Platform::MACOS) }
    it { expect(subject.platform).to eq(:macos) }
    it { expect(subject.device).to eq(AppInfo::Device::MACOS) }
    it { expect(subject.device).to eq(:macos) }
    it { expect(subject).not_to be_iphone }
    it { expect(subject).not_to be_ipad }
    it { expect(subject).not_to be_universal }
    it { expect(subject).to be_macos }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('GuiApp') }
    it { expect(subject.bundle_name).to eq('GuiApp') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.icyleaf.macos.GUIApp') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.macos.GUIApp') }
    it { expect(subject.min_system_version).to eq('11.3') }
    it { expect(subject.min_os_version).to eq('11.3') }
    it { expect(subject.to_h).to be_a Hash }
    it { expect(subject['CFBundleVersion']).to eq('1') }
    it { expect(subject[:CFBundleShortVersionString]).to eq('1.0') }
    it { expect(subject.CFBundleShortVersionString).to eq('1.0') }
    it { expect(subject.c_f_bundle_short_version_string).to eq('1.0') }
    it { expect(subject.icons).to be_kind_of Array }
  end
end
