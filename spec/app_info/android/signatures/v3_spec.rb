describe AppInfo::Android::Signature::V3 do
  let(:version) { 3 }
  let(:signature_description) { "#{AppInfo::Android::Signature::V3::DESCRIPTION} v#{version}" }
  before { AppInfo.logger.level = :error }

  context 'when parse v1 signature apk' do
    let(:file) { fixture_path('apps/wear.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V3.new(parser) }

    it { expect { AppInfo::Android::Signature::V3.verify(parser) }.to raise_error(AppInfo::Android::Signature::NotFoundError) }
    it { expect { subject.verify }.to raise_error(AppInfo::Android::Signature::NotFoundError) }
  end

  context 'when parse v2 signature apk' do
    let(:file) { fixture_path('apps/android-v2-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V3.verify(parser) }

    it { expect { AppInfo::Android::Signature::V3.verify(parser) }.to raise_error(AppInfo::Android::Signature::NotFoundError) }
    it { expect { subject.verify }.to raise_error(AppInfo::Android::Signature::NotFoundError) }
  end

  context 'when parse v3 signature apk' do
    let(:file) { fixture_path('apps/android-v3-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    subject { AppInfo::Android::Signature::V3.verify(parser) }

    it { expect(subject.version).to eq(version) }
    it { expect(subject.scheme).to eq("v#{version}") }
    it { expect(subject.description).to eq(signature_description) }
    it { expect(subject.certificates).to be_kind_of(Array) }
    it { expect(subject.certificates).not_to be_empty }
    it { expect(subject.certificates[0]).to be_kind_of(AppInfo::Certificate) }
    it { expect(subject.digests).to be_kind_of(Hash) }
    it { expect(subject.digests).not_to be_empty }
    it { expect(subject.digests).to have_key('SHA256') }
    it { expect(subject.digests['SHA256']).to be_kind_of(StringIO) }
    it { expect(subject.digests['SHA256']).not_to be_nil }
  end
end
