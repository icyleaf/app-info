describe AppInfo::MobileProvision do
  describe :ios do
    context 'Development' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/ios_development.mobileprovision')) }

      it { expect(subject.format).to eq AppInfo::Format::MOBILEPROVISION }
      it { expect(subject.format).to eq :mobileprovision }
      it { expect(subject.platform).to eq AppInfo::Platform::APPLE }
      it { expect(subject.platform).to eq :apple }
      it { expect(subject.opera_system).to eq AppInfo::OperaSystem::IOS }
      it { expect(subject.opera_system).to eq :ios }
      it { expect(subject.opera_systems).to eq [:ios] }
      it { expect{ subject.device }.to raise_error NotImplementedError }
      it { expect(subject.devices).to eq(['e801228c2086d3aacc917b9c3d19bfa56efcab5b']) }
      it { expect(subject.name).to_not be_empty }
      it { expect(subject.app_name).to_not be_empty }
      it { expect(subject.type).to eq :development }
      it { expect(subject.development?).to be_truthy }
      it { expect(subject.adhoc?).to be_falsey }
      it { expect(subject.appstore?).to be_falsey }
      it { expect(subject.inhouse?).to be_falsey }
      it { expect(subject.enterprise?).to be_falsey }
      it { expect(subject.team_identifier).to_not be_empty }
      it { expect(subject.team_name).to_not be_empty }
      it { expect(subject.profile_name).to_not be_empty }
      it { expect(subject.created_date).to be_a Time }
      it { expect(subject.expired_date).to be_a Time }
      it { expect(subject.entitlements).to be_a Hash }
      it { expect(subject.developer_certs).to be_a Array }
      it { expect(subject.certificates).to be_a Array }
      it { expect(subject.certificates.size).to eq(1) }
      it { expect(subject.certificates[0]).to be_a(AppInfo::Certificate) }  # see spec/app_info/certificate_spec.rb
      it { expect(subject.enabled_capabilities).not_to be_empty }
    end

    context 'Adhoc' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/ios_adhoc.mobileprovision')) }

      it { expect(subject.format).to eq AppInfo::Format::MOBILEPROVISION }
      it { expect(subject.format).to eq :mobileprovision }
      it { expect(subject.platform).to eq AppInfo::Platform::APPLE }
      it { expect(subject.platform).to eq :apple }
      it { expect(subject.opera_system).to eq AppInfo::OperaSystem::IOS }
      it { expect(subject.opera_system).to eq :ios }
      it { expect(subject.opera_system).to eq AppInfo::OperaSystem::IOS }
      it { expect(subject.opera_system).to eq :ios }
      it { expect(subject.opera_systems).to eq [:ios] }
      it { expect{ subject.device }.to raise_error NotImplementedError }
      it { expect(subject.devices).to be_a Array }
      it { expect(subject.devices).to eq(['e801228c2086d3aacc917b9c3d19bfa56efcab5b']) }
      it { expect(subject.name).to_not be_empty }
      it { expect(subject.app_name).to_not be_empty }
      it { expect(subject.type).to eq :adhoc }
      it { expect(subject.development?).to be_falsey }
      it { expect(subject.adhoc?).to be_truthy }
      it { expect(subject.appstore?).to be_falsey }
      it { expect(subject.inhouse?).to be_falsey }
      it { expect(subject.enterprise?).to be_falsey }
      it { expect(subject.team_identifier).to_not be_empty }
      it { expect(subject.team_name).to_not be_empty }
      it { expect(subject.profile_name).to_not be_empty }
      it { expect(subject.created_date).to be_a Time }
      it { expect(subject.expired_date).to be_a Time }
      it { expect(subject.entitlements).to be_a Hash }
      it { expect(subject.developer_certs).to be_a Array }
      it { expect(subject.enabled_capabilities).not_to be_empty }
    end

    context 'AppStore' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/ios_appstore.mobileprovision')) }

      it { expect(subject.format).to eq AppInfo::Format::MOBILEPROVISION }
      it { expect(subject.format).to eq :mobileprovision }
      it { expect(subject.platform).to eq AppInfo::Platform::APPLE }
      it { expect(subject.platform).to eq :apple }
      it { expect(subject.opera_system).to eq AppInfo::OperaSystem::IOS }
      it { expect(subject.opera_system).to eq :ios }
      it { expect(subject.opera_systems).to eq [:ios] }
      it { expect{ subject.device }.to raise_error NotImplementedError }
      it { expect(subject.devices).to be_nil }
      it { expect(subject.name).to_not be_empty }
      it { expect(subject.app_name).to_not be_empty }
      it { expect(subject.type).to eq :appstore }
      it { expect(subject.development?).to be_falsey }
      it { expect(subject.adhoc?).to be_falsey }
      it { expect(subject.appstore?).to be_truthy }
      it { expect(subject.inhouse?).to be_falsey }
      it { expect(subject.enterprise?).to be_falsey }
      it { expect(subject.team_identifier).to_not be_empty }
      it { expect(subject.team_name).to_not be_empty }
      it { expect(subject.profile_name).to_not be_empty }
      it { expect(subject.created_date).to be_a Time }
      it { expect(subject.expired_date).to be_a Time }
      it { expect(subject.entitlements).to be_a Hash }
      it { expect(subject.developer_certs).to be_a Array }
      it { expect(subject.enabled_capabilities).not_to be_empty }
    end
  end

  describe 'macOS' do
    context 'Development' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/macos_development.provisionprofile')) }

      it { expect(subject.format).to eq AppInfo::Format::MOBILEPROVISION }
      it { expect(subject.format).to eq :mobileprovision }
      it { expect(subject.platform).to eq AppInfo::Platform::APPLE }
      it { expect(subject.platform).to eq :apple }
      it { expect(subject.opera_system).to eq AppInfo::OperaSystem::MACOS }
      it { expect(subject.opera_system).to eq :macos }
      it { expect(subject.opera_systems).to eq [:macos] }
      it { expect{ subject.device }.to raise_error NotImplementedError }
      it { expect(subject.devices).to be_a Array }
      it { expect(subject.name).to_not be_empty }
      it { expect(subject.app_name).to_not be_empty }
      it { expect(subject.type).to eq :development }
      it { expect(subject.development?).to be_truthy }
      it { expect(subject.adhoc?).to be_falsey }
      it { expect(subject.appstore?).to be_falsey }
      it { expect(subject.inhouse?).to be_falsey }
      it { expect(subject.enterprise?).to be_falsey }
      it { expect(subject.team_identifier).to_not be_empty }
      it { expect(subject.team_name).to_not be_empty }
      it { expect(subject.profile_name).to_not be_empty }
      it { expect(subject.created_date).to be_a Time }
      it { expect(subject.expired_date).to be_a Time }
      it { expect(subject.entitlements).to be_a Hash }
      it { expect(subject.developer_certs).to be_a Array }
      it { expect(subject.enabled_capabilities).not_to be_empty }
    end

    context 'AppStore' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/macos_appstore.provisionprofile')) }

      it { expect(subject.format).to eq AppInfo::Format::MOBILEPROVISION }
      it { expect(subject.format).to eq :mobileprovision }
      it { expect(subject.platform).to eq AppInfo::Platform::APPLE }
      it { expect(subject.platform).to eq :apple }
      it { expect(subject.opera_system).to eq AppInfo::OperaSystem::MACOS }
      it { expect(subject.opera_system).to eq :macos }
      it { expect(subject.opera_systems).to eq [:macos] }
      it { expect{ subject.device }.to raise_error NotImplementedError }
      it { expect(subject.devices).to be_nil }
      it { expect(subject.name).to_not be_empty }
      it { expect(subject.app_name).to_not be_empty }
      it { expect(subject.type).to eq :appstore }
      it { expect(subject.development?).to be_falsey }
      it { expect(subject.adhoc?).to be_falsey }
      it { expect(subject.appstore?).to be_truthy }
      it { expect(subject.inhouse?).to be_falsey }
      it { expect(subject.enterprise?).to be_falsey }
      it { expect(subject.team_identifier).to_not be_empty }
      it { expect(subject.team_name).to_not be_empty }
      it { expect(subject.profile_name).to_not be_empty }
      it { expect(subject.created_date).to be_a Time }
      it { expect(subject.expired_date).to be_a Time }
      it { expect(subject.entitlements).to be_a Hash }
      it { expect(subject.developer_certs).to be_a Array }
      it { expect(subject.enabled_capabilities).not_to be_empty }
    end
  end
end
