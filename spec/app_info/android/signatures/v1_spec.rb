describe AppInfo::Android::Signature::V1 do
  context 'when parse no signature apk' do
    let(:file) { fixture_path('apps/android.apk') }
    subject { AppInfo::Android::Signature::V1.verify(1, file) }

    it { expect(subject.scheme).to eq('v1') }
    it { expect(subject.description).to eq(AppInfo::Android::Signature::V1::DESCRIPTION) }

    it { expect(subject.certificates).to be_nil }
  end
end
