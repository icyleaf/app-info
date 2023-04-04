describe AppInfo::Certificate do
  describe 'use different algorithm' do
    context 'when parse RSA 256 cert' do
      let(:pem) {
        <<-EOF
-----BEGIN CERTIFICATE-----
MIIDYTCCAkmgAwIBAgIEPYzXgDANBgkqhkiG9w0BAQ0FADBAMRMwEQYKCZImiZPy
LGQBGRYDY29tMRcwFQYKCZImiZPyLGQBGRYHaWN5bGVhZjEQMA4GA1UEAwwHQXBw
SW5mbzAeFw0yMzAzMzEwNTIzMzNaFw0yNTAzMzAwNTIzMzNaMEAxEzARBgoJkiaJ
k/IsZAEZFgNjb20xFzAVBgoJkiaJk/IsZAEZFgdpY3lsZWFmMRAwDgYDVQQDDAdB
cHBJbmZvMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvOSTnCAAGNXJ
JSn/p/RLS+3Z6hTGUDfTMv9Rz6NOPfW+GEwpJZVwvx7liRxVpdZ5kyoULqScJUlV
vDSXgMGo7PHBbyhuJrskgOJVHETI6Z52C598FgIUqJ6YZqL8ePTeNycfaiOwMt9X
IPkD+xRck9dpWGQGV2nNARwLrfDzIXdNHsvBpXdtgVI0cTX9phn5n5ljfyZm8VIa
lcSil/vGQtxqURF9icbvmyyKPLGTXQB+u94bBHOU/Ck77odzmK9HWoZo4Km3i76P
JuryskCpOeUjCkVNkl8HYew9RN3oZk88yJTSp5ozGkGxGo+xBNsgw+RNF0vMRHe9
vFf1+ZmvDwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIB
BjAdBgNVHQ4EFgQUhs+AYSFFeoKdlG4FYWIaVMKHFyUwHwYDVR0jBBgwFoAUhs+A
YSFFeoKdlG4FYWIaVMKHFyUwDQYJKoZIhvcNAQENBQADggEBAGNKlmW/A+wMQw+m
EaLEjSjxJsQfJR9Vi8m5m2gKCoZrtyEg0+AZwdwyzur4Hd3IvL2DIEZtYr5n9Xe4
LpQ8G/fgHH3EizbR8Qcpyv0qqIHDwbqAe9gzmLa1MGx5cIntqYvIxdgggfm5hzCH
hEbrJFZzewcFPMBQW0G1byFgn6miwQkFYRy7zNP4V5nEi5N8l7w1YHn03zjrH1Jo
mnTWWLrfyvXhs4LJuHMyNXSCJ57fJQBOHTaU5V1n6MxVzji5RsBB+1v3kD+k0iqN
3BJU/sqS7eyN0l/RkNOdmEfU5giNhNeqtVIiqVRYOC08sa7WOr89sh8qUmxSHx8S
6gkx+rk=
-----END CERTIFICATE-----
        EOF
      }

      let(:cert) { OpenSSL::X509::Certificate.new(pem) }
      subject { AppInfo::Certificate.new(cert) }

      it { expect(subject.raw).to eq(cert) }
      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([['DC', 'com'], ['DC', 'icyleaf'], ['CN', 'AppInfo']]) }
      it { expect(subject.subject(format: :to_s)).to eq('DC=com DC=icyleaf CN=AppInfo') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([['DC', 'com'], ['DC', 'icyleaf'], ['CN', 'AppInfo']]) }
      it { expect(subject.issuer(format: :to_s)).to eq('DC=com DC=icyleaf CN=AppInfo') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.size).to eq(2048) }
      it { expect(subject.serial).to eq('1032640384') }
      it { expect(subject.serial(16)).to eq('3d8cd780') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x3D8CD780') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('5ca7af6b45133e0783ad9125dee5ac5d') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('5C:A7:AF:6B:45:13:3E:07:83:AD:91:25:DE:E5:AC:5D') }
    end

    context 'when parse DSA 512 cert' do
      let(:pem) {
        <<-EOF
-----BEGIN CERTIFICATE-----
MIIDHzCCAtygAwIBAgIEPYzXgDALBglghkgBZQMEAwQwQDETMBEGCgmSJomT8ixk
ARkWA2NvbTEXMBUGCgmSJomT8ixkARkWB2ljeWxlYWYxEDAOBgNVBAMMB0FwcElu
Zm8wHhcNMjMwMzMxMDYwNTQ2WhcNMjUwMzMwMDYwNTQ2WjBAMRMwEQYKCZImiZPy
LGQBGRYDY29tMRcwFQYKCZImiZPyLGQBGRYHaWN5bGVhZjEQMA4GA1UEAwwHQXBw
SW5mbzCCAbcwggErBgcqhkjOOAQBMIIBHgKBgQDAMk6nKNC0f4LvdWkobYjGAu7w
pXZhrW7hWl0unJNn5CzDL5UY+DeYLjofDcgRF/H/jkxMVrxdEcWHz+Q1pKmhKHPj
T2mhaoO93cYDvsq/UVjBGKSZWmO9JnBnaQEca5tSlqjtiDBBD3WPUR8nC9BOLFna
IkaRTQolP1eW1DBucwIVAN20ca17j3k0B0VXsI1rJVgBCVChAoGAU/AUIrole6rP
afJ0sblqfbZcWehOFUYqS3z/318Jqm2j2ucBWz5rVK/PfRKCGr2gE2VJFhhyuDDx
9D8DXoNaO93T3Q5fUc8RshzeKKQzU7wmyZxrcp/EPYm1aW0vEFJtTI0iWtm78HCw
baO/KYBfUVyx4U8X/qkKz/3Ei34OxG0DgYUAAoGBAKw56r7COMElB5Jr/l7pLXIp
vDM4Ek4rurlZwUisNRKyDOcgG22m57XveUytInS77oAP2Ae60jRjaUCbYsJRlXaW
+vUFowlmncIRY64WKFdh41ifB/epW/biCwIKx3T6y8kHWyV/8Ldke00qr5gEguY2
WvXm3WS9m55+ggUBJLcfo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQE
AwIBBjAdBgNVHQ4EFgQUqp1EYem0z/DbqBVZ9gU+Kk+MCPswHwYDVR0jBBgwFoAU
qp1EYem0z/DbqBVZ9gU+Kk+MCPswCwYJYIZIAWUDBAMEAzAAMC0CFQDFfCKf1wre
70gRM3O2IyPbStBMVgIUD9/NYm/2ExajYYJxo9/8xjLFwHw=
-----END CERTIFICATE-----
        EOF
      }

      let(:cert) { OpenSSL::X509::Certificate.new(pem) }
      subject { AppInfo::Certificate.new(cert) }

      it { expect(subject.raw).to eq(cert) }
      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([['DC', 'com'], ['DC', 'icyleaf'], ['CN', 'AppInfo']]) }
      it { expect(subject.subject(format: :to_s)).to eq('DC=com DC=icyleaf CN=AppInfo') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([['DC', 'com'], ['DC', 'icyleaf'], ['CN', 'AppInfo']]) }
      it { expect(subject.issuer(format: :to_s)).to eq('DC=com DC=icyleaf CN=AppInfo') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:dsa) }
      it { expect(subject.size).to eq(1024) }
      it { expect(subject.serial).to eq('1032640384') }
      it { expect(subject.serial(16)).to eq('3d8cd780') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x3D8CD780') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('c29976fa25d1131585f7bd34ea3d58f0') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('C2:99:76:FA:25:D1:13:15:85:F7:BD:34:EA:3D:58:F0') }
    end

    context 'when parse EC P-256(prime256v1) cert' do
      let(:pem) {
        <<-EOF
-----BEGIN CERTIFICATE-----
MIIB1DCCAXqgAwIBAgIDANlvMAoGCCqGSM49BAMCMEAxEzARBgoJkiaJk/IsZAEZ
FgNjb20xFzAVBgoJkiaJk/IsZAEZFgdpY3lsZWFmMRAwDgYDVQQDDAdBcHBJbmZv
MB4XDTIzMDMzMTA2MzAxMFoXDTI1MDMzMDA2MzAxMFowQDETMBEGCgmSJomT8ixk
ARkWA2NvbTEXMBUGCgmSJomT8ixkARkWB2ljeWxlYWYxEDAOBgNVBAMMB0FwcElu
Zm8wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATnRrAZbtMzyeu18uTP+KsMSezu
BGA3wVIcj9R4OKkOVBMxyYilpx31e6SL00owGJ7DC0PoK7eyIE3d4wwFlwtHo2Mw
YTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUl/6T
DUp/Pg1QBs9osh7VJvGIfy0wHwYDVR0jBBgwFoAUl/6TDUp/Pg1QBs9osh7VJvGI
fy0wCgYIKoZIzj0EAwIDSAAwRQIgMHQs3M/KtwCjVmp6JgTDi4aXGwyJSHR3//ld
w+n4RPwCIQCII6aF8nsElheWUaJey3qE+eaxjcELsuLTuZjIkJFz/g==
-----END CERTIFICATE-----
        EOF
      }

      let(:cert) { OpenSSL::X509::Certificate.new(pem) }
      subject { AppInfo::Certificate.new(cert) }

      it { expect(subject.raw).to eq(cert) }
      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([['DC', 'com'], ['DC', 'icyleaf'], ['CN', 'AppInfo']]) }
      it { expect(subject.subject(format: :to_s)).to eq('DC=com DC=icyleaf CN=AppInfo') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([['DC', 'com'], ['DC', 'icyleaf'], ['CN', 'AppInfo']]) }
      it { expect(subject.issuer(format: :to_s)).to eq('DC=com DC=icyleaf CN=AppInfo') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:ec) }
      it { expect(subject.serial).to eq('55663') }
      it { expect(subject.serial(16)).to eq('d96f') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0xD96F') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('bc08f63d99c0437e1776832cbfe0c76a') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('BC:08:F6:3D:99:C0:43:7E:17:76:83:2C:BF:E0:C7:6A') }

      it { expect { subject.size }.to raise_error(NotImplementedError) }
    end
  end

  describe 'parse from app' do
    context 'when ipa file' do
      let(:file) { fixture_path('apps/iphone.ipa') }
      let(:parser) { AppInfo.parse(file) }
      subject { parser.mobileprovision.certificates[0] }

      after { parser.clear! }

      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([["UID", "RL894YMEUR"], ["CN", "iPhone Developer: wangpeng wangpeng (U398GU648T)"], ["OU", "5PJA6N5A3B"], ["O", "QYER Inc"], ["C", "US"]]) }
      it { expect(subject.subject(format: :to_s)).to eq('UID=RL894YMEUR CN=iPhone Developer: wangpeng wangpeng (U398GU648T) OU=5PJA6N5A3B O=QYER Inc C=US') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([["C", "US"], ["O", "Apple Inc."], ["OU", "Apple Worldwide Developer Relations"], ["CN", "Apple Worldwide Developer Relations Certification Authority"]]) }
      it { expect(subject.issuer(format: :to_s)).to eq('C=US O=Apple Inc. OU=Apple Worldwide Developer Relations CN=Apple Worldwide Developer Relations Certification Authority') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.serial).to eq('411454196435848399') }
      it { expect(subject.serial(16)).to eq('05b5c76963e70ccf') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x05B5C76963E70CCF') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('9582f299fdb93f8fc729b34fa1e1b31a') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('95:82:F2:99:FD:B9:3F:8F:C7:29:B3:4F:A1:E1:B3:1A') }
    end

    context 'when mobileprovision file' do
      let(:file) { fixture_path('mobileprovisions/ios_development.mobileprovision') }
      let(:parser) { AppInfo.parse(file) }
      subject { parser.certificates[0] }

      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([["UID", "SY5DGV3J4K"], ["CN", "Apple Development: Shen Wang (A3Z3NZQ8V3)"], ["OU", "WKR87TTKML"], ["O", "Niceliving (Beijing) Technology Co., Ltd."], ["C", "US"]]) }
      it { expect(subject.subject(format: :to_s)).to eq('UID=SY5DGV3J4K CN=Apple Development: Shen Wang (A3Z3NZQ8V3) OU=WKR87TTKML O=Niceliving (Beijing) Technology Co., Ltd. C=US') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([["C", "US"], ["O", "Apple Inc."], ["OU", "Apple Worldwide Developer Relations"], ["CN", "Apple Worldwide Developer Relations Certification Authority"]]) }
      it { expect(subject.issuer(format: :to_s)).to eq('C=US O=Apple Inc. OU=Apple Worldwide Developer Relations CN=Apple Worldwide Developer Relations Certification Authority') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.serial).to eq('2241281008099464536') }
      it { expect(subject.serial(16)).to eq('1f1aa133b9991558') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x1F1AA133B9991558') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('2c97db0d66fcfc03201c647ddc84406c') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('2C:97:DB:0D:66:FC:FC:03:20:1C:64:7D:DC:84:40:6C') }
    end

    context 'when signature v1 scheme apk file' do
      let(:file) { fixture_path('apps/wear.apk') }
      let(:parser) { AppInfo.parse(file) }
      subject { parser.signatures.find { |sign| sign[:version] == 1 }[:certificates][0] }

      after { parser.clear! }

      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([["C", "86"], ["ST", "BJ"], ["L", "chaoyang"], ["O", "QYER"], ["OU", "Mobile Product Unit"], ["CN", "Yi Xiao"]]) }
      it { expect(subject.subject(format: :to_s)).to eq('C=86 ST=BJ L=chaoyang O=QYER OU=Mobile Product Unit CN=Yi Xiao') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([["C", "86"], ["ST", "BJ"], ["L", "chaoyang"], ["O", "QYER"], ["OU", "Mobile Product Unit"], ["CN", "Yi Xiao"]]) }
      it { expect(subject.issuer(format: :to_s)).to eq('C=86 ST=BJ L=chaoyang O=QYER OU=Mobile Product Unit CN=Yi Xiao') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.serial).to eq('1241130262') }
      it { expect(subject.serial(16)).to eq('49fa2516') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x49FA2516') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('54fb994eb8c1d07aaac2b2e502979b67') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('54:FB:99:4E:B8:C1:D0:7A:AA:C2:B2:E5:02:97:9B:67') }
    end

    context 'when signature v2 scheme apk file' do
      let(:file) { fixture_path('apps/android-v2-signed-only.apk') }
      let(:parser) { AppInfo.parse(file) }
      subject { parser.signatures.find { |sign| sign[:version] == 2 }[:certificates][0] }

      after { parser.clear! }

      it { expect(subject.version).to eq('v1') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('0') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([["CN", "icyleaf"], ["O", "EWS Studio"]]) }
      it { expect(subject.subject(format: :to_s)).to eq('CN=icyleaf O=EWS Studio') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([["CN", "icyleaf"], ["O", "EWS Studio"]]) }
      it { expect(subject.issuer(format: :to_s)).to eq('CN=icyleaf O=EWS Studio') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.serial).to eq('1') }
      it { expect(subject.serial(16)).to eq('01') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x01') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('4f6a2a0d68914ba56042f6936d7fdb26') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('4F:6A:2A:0D:68:91:4B:A5:60:42:F6:93:6D:7F:DB:26') }
    end

    context 'when signature v3 scheme apk file' do
      let(:file) { fixture_path('apps/android-v3-signed-only.apk') }
      let(:parser) { AppInfo.parse(file) }
      subject { parser.signatures.find { |sign| sign[:version] == 3 }[:certificates][0] }

      after { parser.clear! }

      it { expect(subject.version).to eq('v1') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('0') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([["CN", "icyleaf"], ["O", "EWS Studio"]]) }
      it { expect(subject.subject(format: :to_s)).to eq('CN=icyleaf O=EWS Studio') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([["CN", "icyleaf"], ["O", "EWS Studio"]]) }
      it { expect(subject.issuer(format: :to_s)).to eq('CN=icyleaf O=EWS Studio') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.serial).to eq('1') }
      it { expect(subject.serial(16)).to eq('01') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x01') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('4f6a2a0d68914ba56042f6936d7fdb26') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('4F:6A:2A:0D:68:91:4B:A5:60:42:F6:93:6D:7F:DB:26') }
    end

    context 'when signature v1 scheme aab file' do
      let(:file) { fixture_path('apps/android.aab') }
      let(:parser) { AppInfo.parse(file) }
      subject { parser.signatures.find { |sign| sign[:version] == 1 }[:certificates][0] }

      after { parser.clear! }

      it { expect(subject.version).to eq('v3') }
      it { expect(subject.version(prefix: nil, base: 0)).to eq('2') }
      it { expect(subject.subject).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.subject(format: :to_a)).to eq([["C", "86"], ["ST", "Beijing"], ["L", "Beijing"], ["O", "ews"], ["OU", "ews"], ["CN", "icy leaf"]]) }
      it { expect(subject.subject(format: :to_s)).to eq('C=86 ST=Beijing L=Beijing O=ews OU=ews CN=icy leaf') }
      it { expect(subject.issuer).to be_kind_of(OpenSSL::X509::Name) }
      it { expect(subject.issuer(format: :to_a)).to eq([["C", "86"], ["ST", "Beijing"], ["L", "Beijing"], ["O", "ews"], ["OU", "ews"], ["CN", "icy leaf"]]) }
      it { expect(subject.issuer(format: :to_s)).to eq('C=86 ST=Beijing L=Beijing O=ews OU=ews CN=icy leaf') }
      it { expect(subject.created_at).to be_kind_of(Time) }
      it { expect(subject.expired_at).to be_kind_of(Time) }
      it { expect(subject.algorithm).to eq(:rsa) }
      it { expect(subject.serial).to eq('1337031362') }
      it { expect(subject.serial(16)).to eq('4fb17ac2') }
      it { expect(subject.serial(16, prefix: '0x', transform: :upper)).to eq('0x4FB17AC2') }
      it { expect(subject.format).to eq(:x509) }
      it { expect(subject.fingerprint(:md5)).to eq('1b3ab9b8b49b086a2ba2bb63985880ba') }
      it { expect(subject.fingerprint(:md5, transform: :upper, delimiter: ':')).to eq('1B:3A:B9:B8:B4:9B:08:6A:2B:A2:BB:63:98:58:80:BA') }
    end
  end
end
