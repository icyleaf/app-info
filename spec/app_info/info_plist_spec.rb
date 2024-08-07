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
    it { expect(subject.device).to eq(AppInfo::Device::Apple::IPHONE) }
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

    it { expect(subject.url_schemes).to eq([]) }
    it { expect(subject.query_schemes).to eq([]) }
    it { expect(subject.background_modes).to eq([]) }
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
    it { expect(subject.device).to eq(AppInfo::Device::Apple::IPAD) }
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

    it { expect(subject.url_schemes).to eq([]) }
    it { expect(subject.query_schemes).to eq([]) }
    it { expect(subject.background_modes).to eq([]) }
  end

  context 'when Unversal of iOS' do
    describe 'with embeded' do
      let(:app) { AppInfo::IPA.new(fixture_path('apps/embedded.ipa')) }
      subject { AppInfo::InfoPlist.new(app.info_path) }

      it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
      it { expect(subject.format).to eq :infoplist }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
      it { expect(subject.manufacturer).to eq(:apple) }
      it { expect(subject.platform).to eq(AppInfo::Platform::IOS) }
      it { expect(subject.platform).to eq(:ios) }
      it { expect(subject.device).to eq(AppInfo::Device::Apple::UNIVERSAL) }
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

      it { expect(subject.url_schemes).to eq([]) }
      it { expect(subject.query_schemes).to eq([]) }
      it { expect(subject.background_modes).to eq([]) }
    end

    describe 'with backend mode' do
      subject { AppInfo::InfoPlist.new(fixture_path('info/unversal-background.plist')) }

      it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
      it { expect(subject.format).to eq :infoplist }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
      it { expect(subject.manufacturer).to eq(:apple) }
      it { expect(subject.platform).to eq(AppInfo::Platform::IOS) }
      it { expect(subject.platform).to eq(:ios) }
      it { expect(subject.device).to eq(AppInfo::Device::Apple::UNIVERSAL) }
      it { expect(subject.device).to eq(:universal) }
      it { expect(subject).not_to be_iphone }
      it { expect(subject).not_to be_ipad }
      it { expect(subject).to be_universal }
      it { expect(subject).not_to be_macos }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.release_version).to eq('0.5.6') }
      it { expect(subject.name).to eq('SideStore') }
      it { expect(subject.bundle_name).to eq('SideStore') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.SideStore.SideStore') }
      it { expect(subject.bundle_id).to eq('com.SideStore.SideStore') }
      it { expect(subject.min_sdk_version).to eq('14.0') }
      it { expect(subject.min_os_version).to eq('14.0') }

      it { expect(subject.to_h).to be_a Hash }
      it { expect(subject['CFBundleVersion']).to eq('1') }
      it { expect(subject[:CFBundleShortVersionString]).to eq('0.5.6') }
      it { expect(subject.CFBundleShortVersionString).to eq('0.5.6') }
      it { expect(subject.c_f_bundle_short_version_string).to eq('0.5.6') }
      it { expect(subject.icons).to be_kind_of Array }

      it { expect(subject.url_schemes[0][:name]).to eq('AltStore General') }
      it { expect(subject.url_schemes[0][:role]).to eq('Editor') }
      it { expect(subject.url_schemes[0][:schemes]).to eq(['altstore', 'sidestore']) }
      it { expect(subject.query_schemes).to eq([
          'altstore-com.rileytestut.AltStore',
          'altstore-com.rileytestut.AltStore.Beta',
          'altstore-com.rileytestut.Delta',
          'altstore-com.rileytestut.Delta.Beta',
          'altstore-com.rileytestut.Delta.Lite',
          'altstore-com.rileytestut.Delta.Lite.Beta',
          'altstore-com.rileytestut.Clip',
          'altstore-com.rileytestut.Clip.Beta',
        ])
      }

      it { expect(subject.background_modes).to eq(['audio', 'fetch', 'remote-notification']) }
    end
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
    it { expect(subject.device).to eq(AppInfo::Device::Apple::MACOS) }
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

    it { expect(subject.url_schemes).to eq([]) }
    it { expect(subject.query_schemes).to eq([]) }
    it { expect(subject.background_modes).to eq([]) }
  end

  context 'when AppleTV' do
    describe "has URL schemes" do
      subject { AppInfo::InfoPlist.new(fixture_path('info/apple-tv-with-url-schemes.plist')) }

      it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
      it { expect(subject.format).to eq :infoplist }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
      it { expect(subject.manufacturer).to eq(:apple) }
      it { expect(subject.platform).to eq(AppInfo::Platform::APPLETV) }
      it { expect(subject.platform).to eq(:appletv) }
      it { expect(subject.device).to eq(AppInfo::Device::Apple::APPLETV) }
      it { expect(subject.device).to eq(:appletv) }
      it { expect(subject).not_to be_iphone }
      it { expect(subject).not_to be_ipad }
      it { expect(subject).not_to be_universal }
      it { expect(subject).not_to be_macos }
      it { expect(subject).to be_appletv }
      it { expect(subject.build_version).to eq('359') }
      it { expect(subject.release_version).to eq('1.2.40') }
      it { expect(subject.name).to eq('Streamer') }
      it { expect(subject.bundle_name).to eq('Streamer') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.streamer.tvos') }
      it { expect(subject.bundle_id).to eq('com.streamer.tvos') }
      it { expect(subject.min_system_version).to be_nil }
      it { expect(subject.min_os_version).to eq('15.0') }
      it { expect(subject.to_h).to be_a Hash }
      it { expect(subject['CFBundleVersion']).to eq('359') }
      it { expect(subject[:CFBundleShortVersionString]).to eq('1.2.40') }
      it { expect(subject.CFBundleShortVersionString).to eq('1.2.40') }
      it { expect(subject.c_f_bundle_short_version_string).to eq('1.2.40') }
      it { expect(subject.icons).to be_nil }

      it { expect(subject.url_schemes[0][:name]).to be nil }
      it { expect(subject.url_schemes[0][:role]).to eq('Editor') }
      it { expect(subject.url_schemes[0][:schemes]).to eq(['streamer']) }
      it { expect(subject.query_schemes).to eq(['infuse', 'vlc-x-callback', 'youtube', 'vlc']) }
      it { expect(subject.background_modes).to eq(['audio']) }
    end

    describe 'use basic' do
      subject { AppInfo::InfoPlist.new(fixture_path('info/apple-tv-basic.plist')) }

      it { expect(subject.format).to eq AppInfo::Format::INFOPLIST }
      it { expect(subject.format).to eq :infoplist }
      it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
      it { expect(subject.manufacturer).to eq(:apple) }
      it { expect(subject.platform).to eq(AppInfo::Platform::APPLETV) }
      it { expect(subject.platform).to eq(:appletv) }
      it { expect(subject.device).to eq(AppInfo::Device::Apple::APPLETV) }
      it { expect(subject.device).to eq(:appletv) }
      it { expect(subject).not_to be_iphone }
      it { expect(subject).not_to be_ipad }
      it { expect(subject).not_to be_universal }
      it { expect(subject).not_to be_macos }
      it { expect(subject).to be_appletv }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.release_version).to eq('1.4') }
      it { expect(subject.name).to eq('XplorerTV') }
      it { expect(subject.bundle_name).to eq('XplorerTV') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.xtremeapp.Xplorer') }
      it { expect(subject.bundle_id).to eq('com.xtremeapp.Xplorer') }
      it { expect(subject.min_system_version).to be_nil }
      it { expect(subject.min_os_version).to eq('9.0') }
      it { expect(subject.to_h).to be_a Hash }
      it { expect(subject['CFBundleVersion']).to eq('1') }
      it { expect(subject[:CFBundleShortVersionString]).to eq('1.4') }
      it { expect(subject.CFBundleShortVersionString).to eq('1.4') }
      it { expect(subject.c_f_bundle_short_version_string).to eq('1.4') }
      it { expect(subject.icons).to be_nil }

      it { expect(subject.url_schemes).to eq([]) }
      it { expect(subject.query_schemes).to eq([]) }
      it { expect(subject.background_modes).to eq([]) }
    end
  end
end
