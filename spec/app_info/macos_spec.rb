describe AppInfo::Macos do
  describe '#macOS' do
    context 'when has a unsigned app' do
      let(:file) { fixture_path('apps/macos.zip') }
      subject { AppInfo::Macos.new(file) }

      after { subject.clear! }

      context 'parse' do
        it { expect(subject.file).to eq file }
        it { expect(subject.format).to eq AppInfo::Format::MACOS }
        it { expect(subject.format).to eq :macos }
        it { expect(subject.platform).to eq(AppInfo::Platform::APPLE) }
        it { expect(subject.platform).to eq(:apple) }
        it { expect(subject.opera_system).to eq(AppInfo::OperaSystem::MACOS) }
        it { expect(subject.opera_system).to eq(:macos) }
        it { expect(subject.device).to eq(AppInfo::Device::MACOS) }
        it { expect(subject.device).to eq(:macos) }
        it { expect(subject.build_version).to eq('1') }
        it { expect(subject.release_version).to eq('1.0') }
        it { expect(subject.name).to eq('GuiApp') }
        it { expect(subject.bundle_name).to eq('GuiApp') }
        it { expect(subject.display_name).to be_nil }
        it { expect(subject.identifier).to eq('com.icyleaf.macos.GUIApp') }
        it { expect(subject.bundle_id).to eq('com.icyleaf.macos.GUIApp') }
        it { expect(subject.min_os_version).to eq('11.3') }
        it { expect(subject.min_system_version).to eq('11.3') }
        it { expect(subject.info['CFBundleVersion']).to eq('1') }
        it { expect(subject.info[:CFBundleShortVersionString]).to eq('1.0') }
        it { expect(subject.archs).to eq(%i[x86_64 arm64]) }
        it { expect(subject.release_type).to eq(:debug) }
        it { expect(subject.mobileprovision?).to be false }
        it { expect(subject.stored?).to be false }
        it { expect(subject.info).to be_kind_of AppInfo::InfoPlist }

        it "should has icons" do
          icons = subject.icons
          expect(icons).not_to be_nil

          expect(icons[:name]).to eq 'AppIcon.icns'
          expect(icons[:file]).not_to be_nil
          expect(icons[:sets]).to be_kind_of Array
        end
      end
    end

    context 'when has a signed app' do
      let(:file) { fixture_path('apps/macos-signed.zip') }
      subject { AppInfo::Macos.new(file) }

      after { subject.clear! }

      context 'parse' do
        it { expect(subject.file).to eq file }
        it { expect(subject.format).to eq AppInfo::Format::MACOS }
        it { expect(subject.format).to eq :macos }
        it { expect(subject.platform).to eq(AppInfo::Platform::APPLE) }
        it { expect(subject.platform).to eq(:apple) }
        it { expect(subject.opera_system).to eq(AppInfo::OperaSystem::MACOS) }
        it { expect(subject.opera_system).to eq(:macos) }
        it { expect(subject.device).to eq(AppInfo::Device::MACOS) }
        it { expect(subject.device).to eq(:macos) }
        it { expect(subject.build_version).to eq('1') }
        it { expect(subject.release_version).to eq('1.0') }
        it { expect(subject.name).to eq('GuiApp') }
        it { expect(subject.bundle_name).to eq('GuiApp') }
        it { expect(subject.display_name).to be_nil }
        it { expect(subject.identifier).to eq('com.icyleaf.macos.GUIApp') }
        it { expect(subject.bundle_id).to eq('com.icyleaf.macos.GUIApp') }
        it { expect(subject.min_os_version).to eq('11.3') }
        it { expect(subject.min_system_version).to eq('11.3') }
        it { expect(subject.info['CFBundleVersion']).to eq('1') }
        it { expect(subject.info[:CFBundleShortVersionString]).to eq('1.0') }
        it { expect(subject.archs).to eq(%i[x86_64 arm64]) }
        it { expect(subject.release_type).to eq(:release) }
        it { expect(subject.stored?).to be false }
        it { expect(subject.info).to be_kind_of AppInfo::InfoPlist }
        it { expect(subject.mobileprovision).to be_kind_of AppInfo::MobileProvision }
        it { expect(subject.mobileprovision?).to be true }
        it { expect(subject.team_name).to eq('Samuel Sharps') }
        it { expect(subject.profile_name).to eq('Layouts') }
        it { expect(subject.expired_date).not_to be_nil }
        it { expect(subject.distribution_name).not_to be_nil }
        it { expect(subject.icons).to be_nil }
      end
    end
  end
end
