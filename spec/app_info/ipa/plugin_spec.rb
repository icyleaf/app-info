
describe AppInfo::Plugin do
  subject { AppInfo::Plugin.parse(fixture_path('payload'), 'plugins') }

  it { expect(subject).to be_a Array}
  it { expect(subject.size).to eq(1) }
  it { expect(subject[0]).to be_a AppInfo::Plugin }
  it { expect(subject[0].name).to eq('NotificationService') }
  it { expect(subject[0].release_version).to eq('4.20.0') }
  it { expect(subject[0].build_version).to eq('01140113') }
  it { expect(subject[0].info).to be_a AppInfo::InfoPlist }
  it { expect(subject[0].bundle_id).to eq('com.haohaozhu.shaijia.NotificationService') }
end
