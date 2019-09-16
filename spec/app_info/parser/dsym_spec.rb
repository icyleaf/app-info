describe AppInfo::Parser::DSYM do
  describe '#SingleMachO' do
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/dsyms/single_ios.dSYM.zip' }
    subject { AppInfo::Parser::DSYM.new(file) }

    context 'parse' do
      data = {
        type: :dsym,
        uuid: 'ea9bbf2d-bfdd-3ce0-85b2-1cbe7152fca5',
        cpu_type: :arm64,
        cpu_name: :arm64,
        size: 866_911,
        humanable_size: '846.59 KB'
      }

      it { expect(subject.machos.size).to eq 1 }
      it { expect(subject.machos[0].type).to eq data[:type] }
      it { expect(subject.machos[0].uuid).to eq data[:uuid] }
      it { expect(subject.machos[0].cpu_type).to eq data[:cpu_type] }
      it { expect(subject.machos[0].cpu_name).to eq data[:cpu_name] }
      it { expect(subject.machos[0].size).to eq data[:size] }
      it { expect(subject.machos[0].size(true)).to eq data[:humanable_size] }
      it { expect(subject.machos[0].to_h).to eq data }
    end
  end

  describe '#MultiMachO' do
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/dsyms/multi_ios.dSYM.zip' }
    subject { AppInfo::Parser::DSYM.new(file) }

    context 'parse' do
      data = [
        {
          type: :dsym,
          uuid: '26dfc15d-bdce-351f-b5de-6ee9f5dd6d85',
          cpu_type: :arm,
          cpu_name: :armv7,
          size: 866_526,
          humanable_size: '846.22 KB'
        },
        {
          type: :dsym,
          uuid: '17f58291-dd25-3fc8-9417-ccbe8163d33e',
          cpu_type: :arm64,
          cpu_name: :arm64,
          size: 866_911,
          humanable_size: '846.59 KB'
        }
      ]
      it { expect(subject.machos.size).to eq 2 }

      it { expect(subject.machos[0].type).to eq data[0][:type] }
      it { expect(subject.machos[0].uuid).to eq data[0][:uuid] }
      it { expect(subject.machos[0].cpu_type).to eq data[0][:cpu_type] }
      it { expect(subject.machos[0].cpu_name).to eq data[0][:cpu_name] }
      it { expect(subject.machos[0].size).to eq data[0][:size] }
      it { expect(subject.machos[0].size(true)).to eq data[0][:humanable_size] }
      it { expect(subject.machos[0].to_h).to eq data[0] }

      it { expect(subject.machos[1].type).to eq data[1][:type] }
      it { expect(subject.machos[1].uuid).to eq data[1][:uuid] }
      it { expect(subject.machos[1].cpu_type).to eq data[1][:cpu_type] }
      it { expect(subject.machos[1].cpu_name).to eq data[1][:cpu_name] }
      it { expect(subject.machos[1].size).to eq data[1][:size] }
      it { expect(subject.machos[1].size(true)).to eq data[1][:humanable_size] }
      it { expect(subject.machos[1].to_h).to eq data[1] }
    end
  end
end
