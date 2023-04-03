# frozen_string_literal: true

module AppInfo::Android
  # Android Certificate of signature
  class Certificate
    def initialize(cert)
      @cert = cert
    end

    def version(prefix: 'v', base: 1)
      "#{prefix}#{raw.version + base}"
    end

    def serial(base = 10, transform: :lower, prefix: nil)
      serial = raw.serial.to_s(base)
      serial = transform == :lower ? serial.downcase : serial.upcase
      return serial unless prefix

      "#{prefix}#{serial}"
    end

    def issuer(format: :raw)
      convert_cert_name(raw.issuer, format: format)
    end

    def subject(format: :raw)
      convert_cert_name(raw.subject, format: format)
    end

    def created_at
      raw.not_before
    end

    def expired_at
      raw.not_after
    end

    def expired?
      expired_at < Time.now.utc
    end

    def format
      :x509
    end

    # return algorithm digest
    #
    # OpenSSL supported digests:
    #
    # -blake2b512                -blake2s256                -md4
    # -md5                       -md5-sha1                  -mdc2
    # -ripemd                    -ripemd160                 -rmd160
    # -sha1                      -sha224                    -sha256
    # -sha3-224                  -sha3-256                  -sha3-384
    # -sha3-512                  -sha384                    -sha512
    # -sha512-224                -sha512-256                -shake128
    # -shake256                  -sm3                       -ssl3-md5
    # -ssl3-sha1                 -whirlpool
    def digest
      signature_algorithm = raw.signature_algorithm

      case signature_algorithm
      when /md5/
        :md5
      when /sha1/
        :sha1
      when /sha224/
        :sha224
      when /sha256/
        :sha256
      when /sha512/
        :sha512
      else
        # Android signature no need the others
        signature_algorithm.to_sym
      end
    end

    # return algorithm name of public key
    def algorithm
      case public_key
      when OpenSSL::PKey::RSA then :rsa
      when OpenSSL::PKey::DSA then :dsa
      when OpenSSL::PKey::DH  then :dh
      when OpenSSL::PKey::EC  then :ec
      end
    end

    # return size of public key
    def size
      case public_key
      when OpenSSL::PKey::RSA
        public_key.n.num_bits
      when OpenSSL::PKey::DSA, OpenSSL::PKey::DH
        public_key.p.num_bits
      when OpenSSL::PKey::EC
        raise NotImplementedError, "key size for #{public_key.inspect} not implemented"
      end
    end

    # return fingerprint of certificate
    def fingerprint(name = :sha256, transform: :lower, delimiter: nil)
      digest = OpenSSL::Digest.new(name.to_s.upcase)
      # digest = case name.to_sym
      #          when :sha1
      #            OpenSSL::Digest::SHA1.new
      #          when :sha224
      #            OpenSSL::Digest::SHA224.new
      #          when :sha384
      #            OpenSSL::Digest::SHA384.new
      #          when :sha512
      #            OpenSSL::Digest::SHA512.new
      #          when :md5
      #            OpenSSL::Digest::MD5.new
      #          else
      #            OpenSSL::Digest::SHA256.new
      #          end

      digest.update(raw.to_der)
      fingerprint = digest.to_s
      fingerprint = fingerprint.upcase if transform.to_sym == :upper
      return fingerprint unless delimiter

      fingerprint.scan(/../).join(delimiter)
    end

    # Orginal OpenSSL X509 certificate
    def raw
      @cert
    end

    private

    def convert_cert_name(name, format:)
      data = name.to_a
      case format
      when :to_a
        data.map { |k, v, _| [k, v] }
      when :to_s
        data.map { |k, v, _| "#{k}=#{v}" }.join(' ')
      else
        name
      end
    end

    def method_missing(method, *args, &block)
      @cert.send(method.to_sym, *args, &block) || super
    end

    def respond_to_missing?(method)
      @cert.include?(method.to_sym) || super
    end
  end
end
