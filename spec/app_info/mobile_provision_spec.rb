describe AppInfo::MobileProvision do
  describe :ios do
    context 'Development' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/ios_development.mobileprovision')) }

      it { expect(subject.devices).to be_a Array }
      it { expect(subject.platform).to eq :ios }
      it { expect(subject.platforms).to eq [:ios] }
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

    context 'Adhoc' do
      subject { AppInfo::MobileProvision.new(fixture_path('mobileprovisions/ios_adhoc.mobileprovision')) }

      it { expect(subject.devices).to be_a Array }
      it { expect(subject.platform).to eq :ios }
      it { expect(subject.platforms).to eq [:ios] }
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

      it { expect(subject.devices).to be_nil }
      it { expect(subject.platform).to eq :ios }
      it { expect(subject.platforms).to eq [:ios] }
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

      it { expect(subject.devices).to be_a Array }
      it { expect(subject.platform).to eq :macos }
      it { expect(subject.platforms).to eq [:macos] }
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

      it { expect(subject.devices).to be_nil }
      it { expect(subject.platform).to eq :macos }
      it { expect(subject.platforms).to eq [:macos] }
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
