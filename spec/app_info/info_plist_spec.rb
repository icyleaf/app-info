describe AppInfo::InfoPlist do
  context 'when iOS' do
    let(:app) { AppInfo::IPA.new(fixture_path('apps/ipad.ipa')) }
    subject { AppInfo::InfoPlist.new(app.info_path) }

    it { expect(subject.file_type).to eq(AppInfo::Format::INFOPLIST) }
    it { expect(subject.file_type).to eq(:infoplist) }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('bundle') }
    it { expect(subject.bundle_name).to eq('bundle') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.icyleaf.bundle') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.bundle') }
    it { expect(subject.device_type).to eq('iPad') }
    it { expect(subject.min_sdk_version).to eq('9.3') }
    it { expect(subject.min_os_version).to eq('9.3') }

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

    it { expect(subject.file_type).to eq(AppInfo::Format::INFOPLIST) }
    it { expect(subject.file_type).to eq(:infoplist) }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('GuiApp') }
    it { expect(subject.bundle_name).to eq('GuiApp') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.icyleaf.macos.GUIApp') }
    it { expect(subject.bundle_id).to eq('com.icyleaf.macos.GUIApp') }
    it { expect(subject.device_type).to eq('macOS') }
    it { expect(subject.min_system_version).to eq('11.3') }
    it { expect(subject.min_os_version).to eq('11.3') }

    it { expect(subject.to_h).to be_a Hash }
    it { expect(subject['CFBundleVersion']).to eq('1') }
    it { expect(subject[:CFBundleShortVersionString]).to eq('1.0') }
    it { expect(subject.CFBundleShortVersionString).to eq('1.0') }
    it { expect(subject.c_f_bundle_short_version_string).to eq('1.0') }
    it { expect(subject.icons).to be_kind_of Array }
  end

  # context ".icons" do
  #   it "should uncrush icons" do
  #     subject.icons.each do |icon|
  #       expect(icon[:uncrushed_file]).not_to be_nil
  #     end
  #   end

  #   it "should not return uncrushed icons" do
  #     subject.icons(false).each do |icon|
  #       expect(icon[:uncrushed_file]).to be_nil
  #     end
  #   end
  # end
end
