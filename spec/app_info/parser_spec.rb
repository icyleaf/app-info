describe AppInfo::Parser::Platform do
  it { expect(AppInfo::Parser::Platform::IOS).to eq 'iOS' }
  it { expect(AppInfo::Parser::Platform::ANDROID).to eq 'Android' }
end
