describe AppInfo::Android::Signature do
  describe "verify v1 scheme" do
    let(:file) { fixture_path('apps/wear.apk') }
    let(:parser) { AppInfo.parse(file) }
    context 'when not set min_version' do
      subject { AppInfo::Android::Signature.verify(parser) }
      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(3) }
      it { expect(subject[0][:version]).to eq(1) }
      it { expect(subject[0]).to have_key(:verified) }
      it { expect(subject[0][:certificates]).not_to be_empty }
      it { expect(subject[1]).to have_key(:version) }
      it { expect(subject[1]).not_to have_key(:verified) }
      it { expect(subject[1]).not_to have_key(:certificates) }
      it { expect(subject[2]).to have_key(:version) }
      it { expect(subject[2]).not_to have_key(:verified) }
      it { expect(subject[2]).not_to have_key(:certificates) }
    end

    context 'when given integer value 2 to min_version param' do
      let(:file) { fixture_path('apps/wear.apk') }
      let(:parser) { AppInfo.parse(file) }
      subject { AppInfo::Android::Signature.verify(parser, min_version: 1) }

      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(1) }
      it { expect(subject[0]).to have_key(:version) }
      it { expect(subject[0]).to have_key(:verified) }
      it { expect(subject[0]).to have_key(:certificates) }
    end

    context 'when given string value 2 to min_version param' do
      let(:file) { fixture_path('apps/wear.apk') }
      let(:parser) { AppInfo.parse(file) }
      subject { AppInfo::Android::Signature.verify(parser, min_version: '2') }

      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(2) }
      it { expect(subject[0]).to have_key(:version) }
      it { expect(subject[0]).to have_key(:verified) }
      it { expect(subject[0]).to have_key(:certificates) }
      it { expect(subject[1]).to have_key(:version) }
      it { expect(subject[1]).not_to have_key(:verified) }
      it { expect(subject[1]).not_to have_key(:certificates) }
    end

    context 'when given integer value 3 to min_version param' do
      let(:file) { fixture_path('apps/wear.apk') }
      let(:parser) { AppInfo.parse(file) }
      subject { AppInfo::Android::Signature.verify(parser, min_version: 3) }

      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(3) }
      it { expect(subject[0]).to have_key(:version) }
      it { expect(subject[0]).to have_key(:verified) }
      it { expect(subject[0]).to have_key(:certificates) }
      it { expect(subject[1]).to have_key(:version) }
      it { expect(subject[1]).not_to have_key(:verified) }
      it { expect(subject[1]).not_to have_key(:certificates) }
      it { expect(subject[2]).to have_key(:version) }
      it { expect(subject[2]).not_to have_key(:verified) }
      it { expect(subject[2]).not_to have_key(:certificates) }
    end
  end

  describe "verify v2 scheme" do
    let(:file) { fixture_path('apps/android-v2-signed-only.apk') }
    let(:parser) { AppInfo.parse(file) }
    context 'when not set min_version' do
      subject { AppInfo::Android::Signature.verify(parser) }
      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(3) }
      it { expect(subject[0]).to have_key(:version) }
      it { expect(subject[0]).not_to have_key(:verified) }
      it { expect(subject[0]).not_to have_key(:certificates) }
      it { expect(subject[1][:version]).to eq(2) }
      it { expect(subject[1][:verified]).to be_falsey }
      it { expect(subject[1][:certificates]).not_to be_empty }
      it { expect(subject[2]).to have_key(:version) }
      it { expect(subject[2]).not_to have_key(:verified) }
      it { expect(subject[2]).not_to have_key(:certificates) }
    end
  end

  describe "verify v1-v2 scheme" do
    let(:file) { fixture_path('apps/android.apk') }
    let(:parser) { AppInfo.parse(file) }
    context 'when not set min_version' do
      subject { AppInfo::Android::Signature.verify(parser) }
      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(3) }
      it { expect(subject[0][:version]).to eq(1) }
      it { expect(subject[0][:verified]).to be_falsey }
      it { expect(subject[0][:certificates]).not_to be_empty }
      it { expect(subject[1][:version]).to eq(2) }
      it { expect(subject[1][:verified]).to be_falsey }
      it { expect(subject[1][:certificates]).not_to be_empty }
      it { expect(subject[2]).to have_key(:version) }
      it { expect(subject[2]).not_to have_key(:verified) }
      it { expect(subject[2]).not_to have_key(:certificates) }
    end
  end

  describe "verify v1-v3 scheme" do
    let(:file) { fixture_path('apps/android-v1-v2-v3-signed.apk') }
    let(:parser) { AppInfo.parse(file) }
    context 'when not set min_version' do
      subject { AppInfo::Android::Signature.verify(parser) }
      it { expect(subject).not_to be_empty }
      it { expect(subject.size).to eq(3) }
      it { expect(subject[0][:version]).to eq(1) }
      it { expect(subject[0][:verified]).to be_falsey }
      it { expect(subject[0][:certificates]).not_to be_empty }
      it { expect(subject[1][:version]).to eq(2) }
      it { expect(subject[1][:verified]).to be_falsey }
      it { expect(subject[1][:certificates]).not_to be_empty }
      it { expect(subject[2][:version]).to eq(3) }
      it { expect(subject[2][:verified]).to be_falsey }
      it { expect(subject[2][:certificates]).not_to be_empty }
    end
  end
end
