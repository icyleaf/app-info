describe AppInfo::Platform do
  it { expect(AppInfo::Platform::IOS).to eq 'iOS' }
  it { expect(AppInfo::Platform::ANDROID).to eq 'Android' }
end
