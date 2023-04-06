describe AppInfo::Platform do
  it { expect(AppInfo::Platform::APPLE).to eq :apple }
  it { expect(AppInfo::Platform::GOOGLE).to eq :google }
  it { expect(AppInfo::Platform::WINDOWS).to eq :windows }
end

describe AppInfo::OperaSystem do
  it { expect(AppInfo::OperaSystem::MACOS).to eq :macos }
  it { expect(AppInfo::OperaSystem::IOS).to eq :ios }
  it { expect(AppInfo::OperaSystem::ANDROID).to eq :android }
  it { expect(AppInfo::OperaSystem::WINDOWS).to eq :windows }
end

describe AppInfo::Device do
  it { expect(AppInfo::Device::MACOS).to eq :macos }
  it { expect(AppInfo::Device::IPHONE).to eq :iphone }
  it { expect(AppInfo::Device::IPAD).to eq :ipad }
  it { expect(AppInfo::Device::IWATCH).to eq :iwatch }
  it { expect(AppInfo::Device::UNIVERSAL).to eq :universal }
  it { expect(AppInfo::Device::PHONE).to eq :phone }
  it { expect(AppInfo::Device::TABLET).to eq :tablet }
  it { expect(AppInfo::Device::WATCH).to eq :watch }
  it { expect(AppInfo::Device::TELEVISION).to eq :television }
  it { expect(AppInfo::Device::AUTOMOTIVE).to eq :automotive }
  it { expect(AppInfo::Device::WINDOWS).to eq :windows }
end
