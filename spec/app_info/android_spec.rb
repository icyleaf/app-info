describe AppInfo::Android do
  context 'when aab' do
    let(:file) { fixture_path('apps/android.aab') }
    subject { AppInfo::Android.new(file) }

    it { expect(subject.file).to eq file }
    it { expect(subject.size).to eq(3618865) }
    it { expect(subject.size(human_size: true)).to eq('3.45 MB') }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
    it { expect(subject.manufacturer).to eq(:google) }
    it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
    it { expect(subject.platform).to eq(:android) }
    it { expect { subject.format }.to raise_error NotImplementedError }
    it { expect { subject.name }.to raise_error NotImplementedError }
    it { expect { subject.use_features }.to raise_error NotImplementedError }
    it { expect { subject.use_permissions }.to raise_error NotImplementedError }
    it { expect { subject.device }.to raise_error NotImplementedError }
    it { expect { subject.activities }.to raise_error NotImplementedError }
    it { expect { subject.services }.to raise_error NotImplementedError }
    it { expect { subject.components }.to raise_error NotImplementedError }
    it { expect { subject.manifest }.to raise_error NotImplementedError }
    it { expect { subject.resource }.to raise_error NotImplementedError }
    it { expect { subject.zip }.to raise_error NotImplementedError }
    it { expect { subject.clear! }.to raise_error NotImplementedError }
  end

  context 'when apk' do
    let(:file) { fixture_path('apps/android.apk') }
    subject { AppInfo::Android.new(file) }

    it { expect(subject.file).to eq file }
    it { expect(subject.size).to eq(4000563) }
    it { expect(subject.size(human_size: true)).to eq('3.82 MB') }
    it { expect(subject.manufacturer).to eq(AppInfo::Manufacturer::GOOGLE) }
    it { expect(subject.manufacturer).to eq(:google) }
    it { expect(subject.platform).to eq(AppInfo::Platform::ANDROID) }
    it { expect(subject.platform).to eq(:android) }
    it { expect { subject.format }.to raise_error NotImplementedError }
    it { expect { subject.name }.to raise_error NotImplementedError }
    it { expect { subject.use_features }.to raise_error NotImplementedError }
    it { expect { subject.use_permissions }.to raise_error NotImplementedError }
    it { expect { subject.device }.to raise_error NotImplementedError }
    it { expect { subject.activities }.to raise_error NotImplementedError }
    it { expect { subject.services }.to raise_error NotImplementedError }
    it { expect { subject.components }.to raise_error NotImplementedError }
    it { expect { subject.manifest }.to raise_error NotImplementedError }
    it { expect { subject.native_codes }.to raise_error NotImplementedError }
    it { expect { subject.resource }.to raise_error NotImplementedError }
    it { expect { subject.zip }.to raise_error NotImplementedError }
    it { expect { subject.clear! }.to raise_error NotImplementedError }
  end
end
