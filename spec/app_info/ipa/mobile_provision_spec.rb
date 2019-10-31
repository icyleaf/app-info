describe AppInfo::MobileProvision do
  let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/ipad.ipa' }
  let(:ipa) { AppInfo::IPA.new(file) }
  subject { AppInfo::MobileProvision.new(ipa.mobileprovision_path) }

  it { expect(subject.devices).to be_nil }
  it { expect(subject.team_name).to eq('QYER Inc') }
  it { expect(subject.profile_name).to eq('XC: *') }
  it { expect(subject.expired_date).not_to be_nil }
  it { expect(subject.empty?).to be false }

  it { expect(subject.mobileprovision).to be_a Hash }
  it { expect(subject.to_h).to be_a Hash }
  it { expect(subject['TeamName']).to eq('QYER Inc') }
  it { expect(subject.TeamName).to eq('QYER Inc') }
  it { expect(subject.team_name).to eq('QYER Inc') }
end
