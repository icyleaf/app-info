# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'app_info'
require 'pathname'

def fixture_path(name)
  File.expand_path(File.join('fixtures', name), __dir__)
end

def generate_test_cert(root_key = OpenSSL::PKey::DSA.generate(2048), algorithem = 'SHA256')
  digest = OpenSSL::Digest.new(algorithem)
  cert_name = OpenSSL::X509::Name.parse("/DC=com/DC=icyleaf/CN=AppInfo")
  created_at = Time.now.utc
  expired_date = 2 * 365 * 24 * 60 * 60  # 2 year
  expired_at = created_at + expired_date

  # cert = OpenSSL::X509::Request.new
  # cert.subject = cert_name
  # cert.public_key = root_key
  # cert.sign(root_key, digest)

  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = Random.rand(2**16 - 2) + 1
  cert.subject = cert_name
  cert.issuer = cert_name
  cert.not_before = created_at
  cert.not_after = expired_at
  cert.public_key = root_key.is_a?(OpenSSL::PKey::EC) ? root_key : root_key.public_key
  cert_ext = OpenSSL::X509::ExtensionFactory.new
  cert_ext.subject_certificate = cert
  cert_ext.issuer_certificate = cert
  cert.add_extension(cert_ext.create_extension("basicConstraints","CA:TRUE",true))
  cert.add_extension(cert_ext.create_extension("keyUsage","keyCertSign, cRLSign", true))
  cert.add_extension(cert_ext.create_extension("subjectKeyIdentifier","hash",false))
  cert.add_extension(cert_ext.create_extension("authorityKeyIdentifier","keyid:always",false))
  cert.sign(root_key, digest)
  cert
end
