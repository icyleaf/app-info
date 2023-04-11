describe AppInfo::DSYM do
  describe 'Single dSYM in a zip file' do
    describe 'when single mach-o' do
      subject { AppInfo::DSYM.new(fixture_path('dsyms/iOS-single-dSYM-with-single-macho.zip')) }
      let(:data) {
        {
          type: :dsym,
          uuid: 'ea9bbf2d-bfdd-3ce0-85b2-1cbe7152fca5',
          cpu_type: :arm64,
          cpu_name: :arm64,
          size: 866_911,
          human_size: '846.59 KB'
        }
      }
      after { subject.clear! }
      context  do
        it { expect(subject.file).to eq fixture_path('dsyms/iOS-single-dSYM-with-single-macho.zip') }
        it { expect(subject.format).to eq AppInfo::Format::DSYM }
        it { expect(subject.format).to eq :dsym }
        it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
        it { expect(subject.manufacturer).to eq(:apple) }
        it { expect{ subject.platform }.to raise_error NotImplementedError }
        it { expect{ subject.device }.to raise_error NotImplementedError }
        it { expect(subject.files.size).to eq 1 }
        it { expect(subject.files[0].object).to eq 'iOS' }
        it { expect(subject.files[0].macho_type).to be_a ::MachO::MachOFile }
        it { expect(subject.files[0].release_version).to eq '1.0' }
        it { expect(subject.files[0].build_version).to eq '1' }
        it { expect(subject.files[0].identifier).to eq 'com.icyleaf.iOS' }
        it { expect(subject.files[0].bundle_id).to eq 'com.icyleaf.iOS' }
        it { expect(subject.files[0].machos.size).to eq 1 }
        it { expect(subject.files[0].machos[0].type).to eq data[:type] }
        it { expect(subject.files[0].machos[0].uuid).to eq data[:uuid] }
        it { expect(subject.files[0].machos[0].cpu_type).to eq data[:cpu_type] }
        it { expect(subject.files[0].machos[0].cpu_name).to eq data[:cpu_name] }
        it { expect(subject.files[0].machos[0].size).to eq data[:size] }
        it { expect(subject.files[0].machos[0].size(human_size: true)).to eq data[:human_size] }
        it { expect(subject.files[0].machos[0].to_h).to eq data }
        it { expect(subject.objects).to eq subject.files }
      end
    end

    describe 'when single mach-o' do
      subject { AppInfo::DSYM.new(fixture_path('dsyms/iOS-single-dSYM-with-multi-macho.zip')) }
      let(:data) {
        [
          {
            type: :dsym,
            uuid: '26dfc15d-bdce-351f-b5de-6ee9f5dd6d85',
            cpu_type: :arm,
            cpu_name: :armv7,
            size: 866_526,
            human_size: '846.22 KB'
          },
          {
            type: :dsym,
            uuid: '17f58291-dd25-3fc8-9417-ccbe8163d33e',
            cpu_type: :arm64,
            cpu_name: :arm64,
            size: 866_911,
            human_size: '846.59 KB'
          }
        ]
      }
      after { subject.clear! }

      context '.parse' do
        it { expect(subject.file).to eq fixture_path('dsyms/iOS-single-dSYM-with-multi-macho.zip') }
        it { expect(subject.format).to eq AppInfo::Format::DSYM }
        it { expect(subject.format).to eq :dsym }
        it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
        it { expect(subject.manufacturer).to eq(:apple) }
        it { expect{ subject.platform }.to raise_error NotImplementedError }
        it { expect{ subject.device }.to raise_error NotImplementedError }
        it { expect(subject.files.size).to eq 1 }
        it { expect(subject.files[0].object).to eq 'iOS' }
        it { expect(subject.files[0].macho_type).to be_a ::MachO::FatFile }
        it { expect(subject.files[0].release_version).to eq '1.0' }
        it { expect(subject.files[0].build_version).to eq '2' }
        it { expect(subject.files[0].identifier).to eq 'com.icyleaf.iOS' }
        it { expect(subject.files[0].bundle_id).to eq 'com.icyleaf.iOS' }
        it { expect(subject.files[0].machos.size).to eq 2}
        it { expect(subject.files[0].machos[0].type).to eq data[0][:type] }
        it { expect(subject.files[0].machos[0].uuid).to eq data[0][:uuid] }
        it { expect(subject.files[0].machos[0].cpu_type).to eq data[0][:cpu_type] }
        it { expect(subject.files[0].machos[0].cpu_name).to eq data[0][:cpu_name] }
        it { expect(subject.files[0].machos[0].size).to eq data[0][:size] }
        it { expect(subject.files[0].machos[0].size(human_size: true)).to eq data[0][:human_size] }
        it { expect(subject.files[0].machos[0].to_h).to eq data[0] }
        it { expect(subject.files[0].machos[1].type).to eq data[1][:type] }
        it { expect(subject.files[0].machos[1].uuid).to eq data[1][:uuid] }
        it { expect(subject.files[0].machos[1].cpu_type).to eq data[1][:cpu_type] }
        it { expect(subject.files[0].machos[1].cpu_name).to eq data[1][:cpu_name] }
        it { expect(subject.files[0].machos[1].size).to eq data[1][:size] }
        it { expect(subject.files[0].machos[1].size(human_size: true)).to eq data[1][:human_size] }
        it { expect(subject.files[0].machos[1].to_h).to eq data[1] }
      end
    end
  end

  describe 'Multi dSYM in a zip file' do
    after { subject.clear! }

    describe 'when dSYM in root path' do
      let(:file) { fixture_path('dsyms/iOS-mutli-dSYMs-directly.zip') }
      subject { AppInfo::DSYM.new(file) }
      let(:data) {
        [
          {
            type: :dsym,
            uuid: '52e65dbe-8234-3387-b733-c5044e26653f',
            cpu_type: :arm64,
            cpu_name: :arm64,
            size: 1_029_092,
            human_size: '1004.97 KB'
          },
          {
            type: :dsym,
            uuid: '628e9796-746c-3fec-91e7-586b4bed352a',
            cpu_type: :arm64,
            cpu_name: :arm64,
            size: 988_131,
            human_size: '964.97 KB'
          }
        ]
      }

      context  do
        it { expect(subject.file).to eq file }
        it { expect(subject.format).to eq AppInfo::Format::DSYM }
        it { expect(subject.format).to eq :dsym }
        it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
        it { expect(subject.manufacturer).to eq(:apple) }
        it { expect{ subject.platform }.to raise_error NotImplementedError }
        it { expect{ subject.device }.to raise_error NotImplementedError }
        it { expect(subject.files.size).to eq 2 }
        it { expect(subject.files[0].object).to eq 'AppInfo' }
        it { expect(subject.files[0].macho_type).to be_a ::MachO::MachOFile }
        it { expect(subject.files[0].release_version).to eq '1.0' }
        it { expect(subject.files[0].build_version).to eq '1' }
        it { expect(subject.files[0].identifier).to eq 'im.ews.ios.AppInfo' }
        it { expect(subject.files[0].bundle_id).to eq 'im.ews.ios.AppInfo' }
        it { expect(subject.files[0].machos.size).to eq 1 }
        it { expect(subject.files[0].machos[0].type).to eq data[0][:type] }
        it { expect(subject.files[0].machos[0].uuid).to eq data[0][:uuid] }
        it { expect(subject.files[0].machos[0].cpu_type).to eq data[0][:cpu_type] }
        it { expect(subject.files[0].machos[0].cpu_name).to eq data[0][:cpu_name] }
        it { expect(subject.files[0].machos[0].size).to eq data[0][:size] }
        it { expect(subject.files[0].machos[0].size(human_size: true)).to eq data[0][:human_size] }
        it { expect(subject.files[0].machos[0].to_h).to eq data[0] }

        it { expect(subject.files[1].object).to eq 'AppInfoNotificationCenter' }
        it { expect(subject.files[1].macho_type).to be_a ::MachO::MachOFile }
        it { expect(subject.files[1].release_version).to eq '1.0' }
        it { expect(subject.files[1].build_version).to eq '1' }
        it { expect(subject.files[1].identifier).to eq 'im.ews.ios.AppInfo.AppInfoNotificationCenter' }
        it { expect(subject.files[1].bundle_id).to eq 'im.ews.ios.AppInfo.AppInfoNotificationCenter' }
        it { expect(subject.files[1].machos.size).to eq 1 }
        it { expect(subject.files[1].machos[0].type).to eq data[1][:type] }
        it { expect(subject.files[1].machos[0].uuid).to eq data[1][:uuid] }
        it { expect(subject.files[1].machos[0].cpu_type).to eq data[1][:cpu_type] }
        it { expect(subject.files[1].machos[0].cpu_name).to eq data[1][:cpu_name] }
        it { expect(subject.files[1].machos[0].size).to eq data[1][:size] }
        it { expect(subject.files[1].machos[0].size(human_size: true)).to eq data[1][:human_size] }
        it { expect(subject.files[1].machos[0].to_h).to eq data[1] }
      end

      after { subject.clear! }
    end

    describe 'when dSYM in children path' do
      let(:file) { fixture_path('dsyms/iOS-mutli-dSYMs-wrapped-by-folder.zip') }
      subject { AppInfo::DSYM.new(file) }
      let(:data) {
        [
          {
            type: :dsym,
            uuid: '52e65dbe-8234-3387-b733-c5044e26653f',
            cpu_type: :arm64,
            cpu_name: :arm64,
            size: 1_029_092,
            human_size: '1004.97 KB'
          },
          {
            type: :dsym,
            uuid: '628e9796-746c-3fec-91e7-586b4bed352a',
            cpu_type: :arm64,
            cpu_name: :arm64,
            size: 988_131,
            human_size: '964.97 KB'
          }
        ]
      }

      context  do
        it { expect(subject.file).to eq file }
        it { expect(subject.format).to eq AppInfo::Format::DSYM }
        it { expect(subject.format).to eq :dsym }
        it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::APPLE) }
        it { expect(subject.manufacturer).to eq(:apple) }
        it { expect{ subject.platform }.to raise_error NotImplementedError }
        it { expect{ subject.device }.to raise_error NotImplementedError }
        it { expect(subject.files.size).to eq 2 }
        it { expect(subject.files[0].object).to eq 'AppInfo' }
        it { expect(subject.files[0].macho_type).to be_a ::MachO::MachOFile }
        it { expect(subject.files[0].release_version).to eq '1.0' }
        it { expect(subject.files[0].build_version).to eq '1' }
        it { expect(subject.files[0].identifier).to eq 'im.ews.ios.AppInfo' }
        it { expect(subject.files[0].bundle_id).to eq 'im.ews.ios.AppInfo' }
        it { expect(subject.files[0].machos.size).to eq 1 }
        it { expect(subject.files[0].machos[0].type).to eq data[0][:type] }
        it { expect(subject.files[0].machos[0].uuid).to eq data[0][:uuid] }
        it { expect(subject.files[0].machos[0].cpu_type).to eq data[0][:cpu_type] }
        it { expect(subject.files[0].machos[0].cpu_name).to eq data[0][:cpu_name] }
        it { expect(subject.files[0].machos[0].size).to eq data[0][:size] }
        it { expect(subject.files[0].machos[0].size(human_size: true)).to eq data[0][:human_size] }
        it { expect(subject.files[0].machos[0].to_h).to eq data[0] }

        it { expect(subject.files[1].object).to eq 'AppInfoNotificationCenter' }
        it { expect(subject.files[1].macho_type).to be_a ::MachO::MachOFile }
        it { expect(subject.files[1].release_version).to eq '1.0' }
        it { expect(subject.files[1].build_version).to eq '1' }
        it { expect(subject.files[1].identifier).to eq 'im.ews.ios.AppInfo.AppInfoNotificationCenter' }
        it { expect(subject.files[1].bundle_id).to eq 'im.ews.ios.AppInfo.AppInfoNotificationCenter' }
        it { expect(subject.files[1].machos.size).to eq 1 }
        it { expect(subject.files[1].machos[0].type).to eq data[1][:type] }
        it { expect(subject.files[1].machos[0].uuid).to eq data[1][:uuid] }
        it { expect(subject.files[1].machos[0].cpu_type).to eq data[1][:cpu_type] }
        it { expect(subject.files[1].machos[0].cpu_name).to eq data[1][:cpu_name] }
        it { expect(subject.files[1].machos[0].size).to eq data[1][:size] }
        it { expect(subject.files[1].machos[0].size(human_size: true)).to eq data[1][:human_size] }
        it { expect(subject.files[1].machos[0].to_h).to eq data[1] }
      end

      after { subject.clear! }
    end
  end
end
