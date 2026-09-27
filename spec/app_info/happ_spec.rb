# frozen_string_literal: true

describe AppInfo::HAPP do
  subject { AppInfo::HAPP.new(file) }
  after { subject.clear! }

  context 'with valid HAPP file' do
    let(:file) { fixture_path('apps/harmony.app') }

    it { expect(subject.file).to eq file }
    it { expect(subject.size).to eq(122_621) }
    it { expect(subject.size(human_size: true)).to eq('119.75 KB') }
    it { expect(subject.format).to eq(:happ) }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::HUAWEI) }
    it { expect(subject.manufacturer).to eq(:huawei) }
    it { expect(subject.platform).to eq(AppInfo::Platform::HARMONYOS) }
    it { expect(subject.platform).to eq(:harmonyos) }
    it { expect(subject.name).to eq('MyApplication') }
    it { expect(subject.bundle_id).to eq('com.example.myapplication') }
    it { expect(subject.icons.length).not_to be_nil }
    it { expect(subject.default_entry).to be_kind_of(AppInfo::HAP) }
    it { expect(subject.default_entry_name).to eq('entry-default') }
    it { expect(subject.modules.size).to eq(1) }
    it { expect(subject.release_version).to eq('1.0.0') }
    it { expect(subject.build_version).to eq(1_000_000) }

    it { expect(subject.identifier).to eq('com.example.myapplication') }
    it { expect(subject.bundle_name).to eq('com.example.myapplication') }
    it { expect(subject.display_name).to eq('MyApplication') }
    it { expect(subject.version).to eq('1.0.0') }

    it { expect(subject.module_info).to include('app', 'module') }
    it { expect(subject.app_info['bundleName']).to eq('com.example.myapplication') }
    it { expect(subject.module_metadata['mainElement']).to eq('EntryAbility') }
    it { expect(subject.main_element).to eq('EntryAbility') }
    it { expect(subject.min_api_version).to eq(50_000_012) }
    it { expect(subject.target_api_version).to eq(50_000_012) }
    it { expect(subject.compile_sdk_version).to eq('5.0.0.25') }
    it { expect(subject.api_release_type).to eq('Beta1') }
    it { expect(subject.profiles).to include('main_pages', 'backup_config') }

    it { expect(subject.permissions).to eq([]) }
    it { expect(subject.use_permissions).to eq([]) }
    it { expect(subject.features).to eq(%w[phone tablet 2in1]) }
    it { expect(subject.use_features).to eq(%w[phone tablet 2in1]) }
    it { expect(subject.device_types).to eq(%w[phone tablet 2in1]) }

    it { expect(subject).to be_phone }
    it { expect(subject).to be_tablet }
    it { expect(subject).to be_two_in_one }
    it { expect(subject).not_to be_tv }
    it { expect(subject).not_to be_wearable }
    it { expect(subject).not_to be_car }

    it { expect(subject.components.size).to eq(2) }
    it { expect(subject.activities.first['name']).to eq('EntryAbility') }
    it { expect(subject.services).to eq([]) }
    it { expect(subject.deep_links).to eq([]) }
    it { expect(subject.schemes).to eq([]) }
    it { expect(subject.architectures).to eq([]) }
    it { expect(subject.native_codes).to eq([]) }
    it { expect(subject.icons.first[:name]).to eq('app_icon.png') }
  end
end
