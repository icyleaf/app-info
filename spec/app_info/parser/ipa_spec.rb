describe AppInfo::Parser::IPA do
  describe '#iPhone' do
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/iphone.ipa' }
    subject { AppInfo::Parser::IPA.new(file) }

    context 'subject' do
      it { expect(subject.os).to eq 'iOS' }
      it { expect(subject.file).to eq file }
      it { expect(subject.build_version).to eq('5') }
      it { expect(subject.release_version).to eq('1.2.3') }
      it { expect(subject.name).to eq('AppInfoDemo') }
      it { expect(subject.bundle_name).to eq('AppInfoDemo') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.icyleaf.AppInfoDemo') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.AppInfoDemo') }
      it { expect(subject.device_type).to eq('iPhone') }

      if OS.mac?
        it { expect(subject.devices).to be_kind_of Array }
        it { expect(subject.team_name).to eq('QYER Inc') }
        it { expect(subject.profile_name).to eq('iOS Team Provisioning Profile: *') }
        it { expect(subject.expired_date).not_to be_nil }
        it { expect(subject.distribution_name).not_to be_nil }
        it { expect(subject.mobileprovision).to be_kind_of AppInfo::Parser::MobileProvision }
      end

      it { expect(subject.mobileprovision?).to be true }
      it { expect(subject.metadata).to be_nil }
      it { expect(subject.metadata?).to be false }
      it { expect(subject.stored?).to be false }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
    end
  end

  describe '#iPad' do
    let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/ipad.ipa' }
    subject { AppInfo::Parser::IPA.new(file) }

    context 'subject in mac' do
      it { expect(subject.os).to eq 'iOS' }
      it { expect(subject.file).to eq file }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.release_version).to eq('1.0') }
      it { expect(subject.name).to eq('bundle') }
      it { expect(subject.bundle_name).to eq('bundle') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.icyleaf.bundle') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.bundle') }
      it { expect(subject.device_type).to eq('iPad') }

      if OS.mac?
        it { expect(subject.devices).to be_nil }
        it { expect(subject.team_name).to eq('QYER Inc') }
        it { expect(subject.profile_name).to eq('XC: *') }
        it { expect(subject.expired_date).not_to be_nil }
        it { expect(subject.distribution_name).to eq('XC: * - QYER Inc') }
        it { expect(subject.mobileprovision).to be_kind_of AppInfo::Parser::MobileProvision }
      end

      it { expect(subject.mobileprovision?).to be true }
      it { expect(subject.metadata).to be_nil }
      it { expect(subject.metadata?).to be false }
      it { expect(subject.stored?).to be false }
      it { expect(subject.ipad?).to be true }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
    end

    context 'subject in linux' do
      before do
        allow(OS).to receive('mac?').and_return(false)
      end

      it { expect(subject.os).to eq 'iOS' }
      it { expect(subject.file).to eq file }
      it { expect(subject.build_version).to eq('1') }
      it { expect(subject.release_version).to eq('1.0') }
      it { expect(subject.name).to eq('bundle') }
      it { expect(subject.bundle_name).to eq('bundle') }
      it { expect(subject.display_name).to be_nil }
      it { expect(subject.identifier).to eq('com.icyleaf.bundle') }
      it { expect(subject.bundle_id).to eq('com.icyleaf.bundle') }
      it { expect(subject.device_type).to eq('iPad') }

      it { expect { subject.devices }.to raise_error('Only works in Mac OS') }
      it { expect { subject.team_name }.to raise_error('Only works in Mac OS') }
      it { expect { subject.profile_name }.to raise_error('Only works in Mac OS') }
      it { expect { subject.expired_date }.to raise_error('Only works in Mac OS') }
      it { expect { subject.distribution_name }.to raise_error('Only works in Mac OS') }
      it { expect { subject.mobileprovision }.to raise_error('Only works in Mac OS') }

      it { expect(subject.mobileprovision?).to be true }
      it { expect(subject.metadata).to be_nil }
      it { expect(subject.metadata?).to be false }
      it { expect(subject.stored?).to be false }
      it { expect(subject.ipad?).to be true }
      it { expect(subject.info).to be_kind_of AppInfo::Parser::InfoPlist }
    end
  end
end
