
describe AppInfo::Framework do
  subject { AppInfo::Framework.parse(fixture_path('payload'), 'frameworks') }

  it { expect(subject).to be_a Array}
  it { expect(subject.size).to eq(2) }
  it { expect(subject[0]).to be_a AppInfo::Framework }
  it { expect(subject[0].lib?).to be_falsey }
  it { expect(subject[0].name).to eq('FMDB.framework') }
  it { expect(subject[0].release_version).to eq '2.7.5' }
  it { expect(subject[0].build_version).to eq '1' }
  it { expect(subject[0].bundle_id).to eq 'org.cocoapods.FMDB' }
  it { expect(subject[0].macho).to be_nil }

  it { expect(subject[1]).to be_a AppInfo::Framework }
  it { expect(subject[1].name).to eq('libswiftPhotos.dylib') }
  it { expect(subject[1].lib?).to be_truthy }
  it { expect(subject[1].release_version).to be_nil }
  it { expect(subject[1].build_version).to be_nil }
  it { expect(subject[1].info).to be_a AppInfo::InfoPlist }
  it { expect(subject[1].bundle_id).to be_nil }
  it { expect(subject[1].macho).to be_a MachO::FatFile }

end
