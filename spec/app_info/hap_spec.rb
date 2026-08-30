# frozen_string_literal: true

describe AppInfo::HAP do
  subject { AppInfo::HAP.new(file) }
  after { subject.clear! }

  context 'with valid HAP file' do
    let(:file) { fixture_path('apps/harmony.hap') }

    it { expect(subject.file).to eq file }
    it { expect(subject.size).to eq(142_283) }
    it { expect(subject.size(human_size: true)).to eq('138.95 KB') }
    it { expect(subject.format).to eq(AppInfo::Format::HAP) }
    it { expect(subject.format).to eq(:hap) }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::HUAWEI) }
    it { expect(subject.manufacturer).to eq(:huawei) }
    it { expect(subject.platform).to eq(AppInfo::Platform::HARMONYOS) }
    it { expect(subject.platform).to eq(:harmonyos) }
    it { expect(subject.name).to eq('MyApplication') }
    it { expect(subject.bundle_id).to eq('com.example.myapplication') }
    it { expect(subject.identifier).to eq('com.example.myapplication') }
    it { expect(subject.main_element).to eq('EntryAbility') }
    it { expect(subject.min_api_version).to eq(50_000_012) }
    it { expect(subject.target_api_version).to eq(50_000_012) }
    it { expect(subject.compile_sdk_version).to eq('5.0.0.25') }
    it { expect(subject.profiles).to include('main_pages', 'backup_config') }
    it { expect(subject.device_types).to eq(%w[phone tablet 2in1]) }
    it { expect(subject).to be_phone }
    it { expect(subject).to be_tablet }
    it { expect(subject).to be_two_in_one }
    it { expect(subject.components.size).to eq(2) }
    it { expect(subject.activities.first['name']).to eq('EntryAbility') }
    it { expect(subject.services).to eq([]) }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.release_version).to eq('1.0.0') }
    it { expect(subject.build_version).to eq(1_000_000) }
  end
end
