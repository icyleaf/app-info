describe AppInfo::Parser::Platform do
  it { expect(AppInfo::Parser::Platform::IOS).to eq 'iOS' }
  it { expect(AppInfo::Parser::Platform::ANDROID).to eq 'Android' }
end

describe AppInfo::Parser do
  it do
    allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('darwin14.6.0')
    expect(AppInfo::Parser).to be_mac
  end

  it do
    allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux-gnu')
    expect(AppInfo::Parser).not_to be_mac
  end
end