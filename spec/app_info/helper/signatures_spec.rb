# frozen_string_literal: true

require 'stringio'

# rubocop:disable Metrics/BlockLength
RSpec.describe AppInfo::Helper::Algorithm do
  let(:parser) do
    Class.new do
      def logger
        AppInfo.logger
      end
    end.new
  end
  let(:instance) { AppInfo::Android::Signature::V2.new(parser) }

  describe 'verity algorithm detection' do
    def algorithm_bytes(id)
      [id].pack('V').unpack('C*')
    end

    [0x0421, 0x0423, 0x0425].each do |id|
      it "detects 0x#{id.to_s(16)} as a verity algorithm" do
        expect(instance.verity_algorithm?(algorithm_bytes(id))).to be true
      end
    end

    [0x0103, 0x0104, 0x0201, 0x0202, 0x0301].each do |id|
      it "does not treat 0x#{id.to_s(16)} as a verity algorithm" do
        expect(instance.verity_algorithm?(algorithm_bytes(id))).to be false
      end
    end
  end

  describe 'algorithm_match' do
    it 'still resolves verity algorithms for certificate lineage verification' do
      expect(instance.algorithm_match([0x21, 0x04, 0x00, 0x00])).to eq('SHA256')
    end
  end
end

RSpec.describe AppInfo::Helper::Signatures do
  def lp_record(payload)
    [payload.size].pack('V') + payload
  end

  def digest_record(algorithm_id_bytes, digest)
    lp_record(algorithm_id_bytes.pack('C*') + lp_record(digest))
  end

  let(:parser) do
    Class.new do
      def logger
        AppInfo.logger
      end
    end.new
  end
  let(:instance) { AppInfo::Android::Signature::V2.new(parser) }

  # Mirrors an APK Signature Scheme v2/v3 SignedData digests block containing
  # a standard RSA PKCS1 v1.5 SHA-256 record followed by a verity record.
  # Both are mapped to the "SHA256" digest name before the fix, so the verity
  # record (written later in the block) silently overrides the standard one.
  let(:standard_digest) { 'a' * 32 }
  let(:verity_digest) { ('b' * 32) + ("\x00" * 8) } # 40-byte verity payload
  let(:digests_io) do
    StringIO.new(
      digest_record([0x03, 0x01, 0x00, 0x00], standard_digest) +
      digest_record([0x21, 0x04, 0x00, 0x00], verity_digest)
    )
  end

  describe '#signed_data_digests' do
    subject { instance.send(:signed_data_digests, digests_io) }

    it 'returns content digests keyed by digest name' do
      expect(subject).to have_key('SHA256')
      expect(subject['SHA256']).to have_key(:content)
    end

    it 'does not let the verity digest record override the standard digest record' do
      expect(subject['SHA256'][:content].string).to eq(standard_digest)
      expect(subject['SHA256'][:content].string.bytesize).to eq(32)
    end
  end

  describe '#signature_algorithms' do
    let(:standard_signature) { 's' * 256 }
    let(:verity_signature) { 'v' * 256 }
    let(:signatures_io) do
      StringIO.new(
        lp_record([0x03, 0x01, 0x00, 0x00].pack('C*') + lp_record(standard_signature)) +
        lp_record([0x21, 0x04, 0x00, 0x00].pack('C*') + lp_record(verity_signature))
      )
    end

    subject { instance.send(:signature_algorithms, signatures_io) }

    it 'keeps the standard signature algorithm record' do
      expect(subject).to contain_exactly(
        hash_including(id: [0x03, 0x01, 0x00, 0x00], digest: 'SHA256',
                       signature: standard_signature)
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
