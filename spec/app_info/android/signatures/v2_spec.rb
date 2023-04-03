describe AppInfo::Android::Signature::V2 do
  let(:version) { 2 }
  let(:signature_description) { "#{AppInfo::Android::Signature::V2::DESCRIPTION} v#{version}" }
  before { AppInfo.logger.level = :error }
  context 'when parse v1 signature apk' do
    let(:file) { fixture_path('apps/wear.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V2.new(version, parser) }

    it { expect { AppInfo::Android::Signature::V2.verify(version, parser) }.to raise_error(AppInfo::Android::Signature::SecurityError) }
    it { expect { subject.verify }.to raise_error(AppInfo::Android::Signature::SecurityError) }
  end

  context 'when parse v2 signature apk' do
    let(:file) { fixture_path('apps/android-v2-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V2.verify(version, parser) }

    it { expect(subject.scheme).to eq("v#{version}") }
    it { expect(subject.description).to eq(signature_description) }
    it { expect(subject.certificates).to be_kind_of(Array) }
    it { expect(subject.certificates).not_to be_empty }
    it { expect(subject.certificates[0]).to be_kind_of(OpenSSL::X509::Certificate) }
    it { expect(subject.digests).to be_kind_of(Hash) }
    it { expect(subject.digests).not_to be_empty }
    it { expect(subject.digests).to have_key('SHA256') }
    it { expect(subject.digests['SHA256']).to be_kind_of(StringIO) }
    it { expect(subject.digests['SHA256']).not_to be_nil }
  end

  context 'when parse v3 signature apk' do
    let(:file) { fixture_path('apps/android-v3-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V2.verify(version, parser) }

    it { expect { AppInfo::Android::Signature::V2.verify(version, parser) }.to raise_error(AppInfo::Android::Signature::SecurityError) }
    it { expect { subject.verify }.to raise_error(AppInfo::Android::Signature::SecurityError) }
  end
end
