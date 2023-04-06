describe AppInfo::File do
  context 'when ininizlize' do
    let(:file) { fixture_path('apps/win-TopBar-v0.1.1.zip') }
    subject { AppInfo::File.new(file) }

    context 'parse' do
      it { expect{ subject.file_type }.to raise_error NotImplementedError }
      it { expect{ subject.size }.to raise_error NotImplementedError }
    end
  end
end
