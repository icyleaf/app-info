# Android file list:
# - wear.apk v1
# - android.apk v1/v2
describe AppInfo::Android::Signature do
  describe "#versions" do
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
end
