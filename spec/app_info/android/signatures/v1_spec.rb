describe AppInfo::Android::Signature::V1 do
  context 'when parse no signature apk' do
    let(:file) { fixture_path('apps/android-v2-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V1.verify(1, parser) }

    it { expect(subject.scheme).to eq('v1') }
    it { expect(subject.description).to eq(AppInfo::Android::Signature::V1::DESCRIPTION) }
    it { expect(subject.signurates).to be_kind_of(Array) }
    it { expect(subject.signurates).to be_empty }
    it { expect(subject.certificates).to be_kind_of(Array) }
    it { expect(subject.certificates).to be_empty }
  end

  context 'when parse v1 signature apk' do
    let(:file) { fixture_path('apps/android.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V1.verify(1, parser) }

    it { expect(subject.scheme).to eq('v1') }
    it { expect(subject.description).to eq(AppInfo::Android::Signature::V1::DESCRIPTION) }
    it { expect(subject.signurates).to be_kind_of(Array) }
    it { expect(subject.signurates).not_to be_empty }
    it { expect(subject.signurates[0]).to be_kind_of(OpenSSL::PKCS7) }
    it { expect(subject.certificates).to be_kind_of(Array) }
    it { expect(subject.certificates).not_to be_empty }
    it { expect(subject.certificates[0]).to be_kind_of(OpenSSL::X509::Certificate) }
  end
end
