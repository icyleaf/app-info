describe AppInfo::File do
  context 'when ininizlize' do
    let(:file) { fixture_path('apps/win-TopBar-v0.1.1.zip') }
    subject { AppInfo::File.new(file) }

    context 'parse' do
      it { expect{ subject.format }.to raise_error NotImplementedError }
      it { expect{ subject.manufacturer }.to raise_error NotImplementedError }
      it { expect{ subject.platform }.to raise_error NotImplementedError }
      it { expect{ subject.device }.to raise_error NotImplementedError }
      it { expect{ subject.size }.to raise_error NotImplementedError }
    end
  end
end
