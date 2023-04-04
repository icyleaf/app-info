describe AppInfo::Android::Signature::V1 do
  let(:version) { 1 }
  let(:signature_description) { AppInfo::Android::Signature::V1::DESCRIPTION }

  context 'when parse v1 signature apk' do
    let(:file) { fixture_path('apps/wear.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V1.verify(parser) }

    it { expect(subject.version).to eq(version) }
    it { expect(subject.scheme).to eq("v#{version}") }
    it { expect(subject.description).to eq(signature_description) }
    it { expect(subject.signatures).to be_kind_of(Hash) }
    it { expect(subject.signatures).to have_key('META-INF/CERT.RSA') }
    it { expect(subject.signatures['META-INF/CERT.RSA']).to be_kind_of(OpenSSL::PKCS7) }
    it { expect(subject.certificates).to be_kind_of(Array) }
    it { expect(subject.certificates[0]).to be_kind_of(AppInfo::Certificate) }
  end

  context 'when parse v2 signature only apk' do
    let(:file) { fixture_path('apps/android-v2-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V1.verify(parser) }

    it { expect { AppInfo::Android::Signature::V1.verify(parser) }.to raise_error(AppInfo::Android::Signature::NotFoundError) }
    it { expect { subject.verify }.to raise_error(AppInfo::Android::Signature::NotFoundError) }
  end
end
