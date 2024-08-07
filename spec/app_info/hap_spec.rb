describe AppInfo::HAP do
  subject { AppInfo::HAP.new(file) }
  after { subject.clear! }

  context 'with valid HAP file' do
    let(:file) { fixture_path('apps/harmony.hap') }

    it { expect(subject.file).to eq file }
    it { expect(subject.size).to eq(142283) }
    it { expect(subject.size(human_size: true)).to eq('138.95 KB') }
    it { expect(subject.format).to eq(AppInfo::Format::HAP) }
    it { expect(subject.format).to eq(:hap) }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::HUAWEI) }
    it { expect(subject.manufacturer).to eq(:huawei) }
    it { expect(subject.platform).to eq(AppInfo::Platform::HARMONYOS) }
    it { expect(subject.platform).to eq(:harmonyos) }
    it { expect(subject.name).to eq('com.example.myapplication') }
    it { expect(subject.bundle_id).to eq('com.example.myapplication') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.release_version).to eq('1.0.0') }
    it { expect(subject.build_version).to eq(1000000) }
  end
end