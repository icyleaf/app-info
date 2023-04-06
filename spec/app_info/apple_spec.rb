describe AppInfo::Apple do
  describe 'when iOS' do
    let(:file) { fixture_path('apps/iphone.ipa') }
    subject { AppInfo::Apple.new(file) }

    it { expect(subject.file).to eq file }
    it { expect(subject.platform).to eq(AppInfo::Platform::APPLE) }
    it { expect(subject.platform).to eq(:apple) }
    it { expect { subject.format }.to raise_error NotImplementedError }
    it { expect { subject.opera_system }.to raise_error NotImplementedError }
    it { expect { subject.distribution_name }.to raise_error NotImplementedError }
    it { expect { subject.info }.to raise_error NotImplementedError }
    it { expect { subject.icons }.to raise_error NotImplementedError }
    it { expect { subject.stored? }.to raise_error NotImplementedError }
    it { expect { subject.mobileprovision_path }.to raise_error NotImplementedError }
    it { expect { subject.info_path }.to raise_error NotImplementedError }
    it { expect { subject.app_path }.to raise_error NotImplementedError }
    it { expect { subject.mobileprovision_path }.to raise_error NotImplementedError }
    it { expect { subject.clear! }.to raise_error NotImplementedError }
  end

  describe 'when macOS' do
    let(:file) { fixture_path('apps/macos.zip') }
    subject { AppInfo::Apple.new(file) }

    it { expect(subject.file).to eq file }
    it { expect(subject.platform).to eq(AppInfo::Platform::APPLE) }
    it { expect(subject.platform).to eq(:apple) }
    it { expect { subject.format }.to raise_error NotImplementedError }
    it { expect { subject.opera_system }.to raise_error NotImplementedError }
    it { expect { subject.distribution_name }.to raise_error NotImplementedError }
    it { expect { subject.info }.to raise_error NotImplementedError }
    it { expect { subject.icons }.to raise_error NotImplementedError }
    it { expect { subject.stored? }.to raise_error NotImplementedError }
    it { expect { subject.mobileprovision_path }.to raise_error NotImplementedError }
    it { expect { subject.info_path }.to raise_error NotImplementedError }
    it { expect { subject.app_path }.to raise_error NotImplementedError }
    it { expect { subject.mobileprovision_path }.to raise_error NotImplementedError }
    it { expect { subject.clear! }.to raise_error NotImplementedError }
  end
end
