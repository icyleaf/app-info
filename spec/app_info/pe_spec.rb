describe AppInfo::PE do
  context 'when parse a .zip file' do
    let(:file) { fixture_path('apps/win-TopBar-v0.1.1.zip') }
    subject { AppInfo::PE.new(file) }

    after { subject.clear! }

    context 'parse' do
      it { expect(subject.os).to eq AppInfo::Platform::WINDOWS }
      it { expect(subject.file).to eq file }
      it { expect(subject.binrary_file).not_to be_nil }
      it { expect(subject.size).to eq 415127 }
      it { expect(subject.size(human_size: true)).to eq "405.40 KB" }
      it { expect(subject.binrary_size).to eq 443392 }
      it { expect(subject.binrary_size(human_size: true)).to eq "433.00 KB" }
      it { expect(subject.product_version).to eq('1.0.0') }
      it { expect(subject.release_version).to eq('1.0.0') }
      it { expect(subject.assembly_version).to eq('1.0.0.0') }
      it { expect(subject.build_version).to eq('1.0.0.0') }
      it { expect(subject.name).to eq('TopBar') }
      it { expect(subject.company_name).to eq('Dejan Stojanovic') }
      it { expect(subject.archs).to eq('x64') }
      it { expect(subject.version_info).to be_kind_of(AppInfo::PE::VersionInfo) }
      it { expect(subject.pe).to be_kind_of(PEdump) }

      it "should has imports" do
        imports = subject.imports
        expect(imports).not_to be_nil

        expect(imports).to have_key 'KERNEL32.dll'
        expect(imports['KERNEL32.dll']).to be_kind_of Array
      end

      it "should has icons" do
        icons = subject.icons
        expect(icons).not_to be_nil

        expect(icons.size).to eq 8
        expect(icons[0][:name]).to eq "win-TopBar-v0.1.1-ICON-1.bmp"
        expect(icons[0][:file]).to end_with "win-TopBar-v0.1.1-ICON-1.bmp"
        expect(icons[0][:dimensions]).to eq([16, 16])
      end
    end
  end

  context 'when parse an .exe file' do
    let(:file) { fixture_path('apps/win-upx.exe') }
    subject { AppInfo::PE.new(file) }

    after { subject.clear! }

    context 'parse' do
      it { expect(subject.os).to eq AppInfo::Platform::WINDOWS }
      it { expect(subject.file).to eq file }
      it { expect(subject.binrary_file).not_to be_nil }
      it { expect(subject.size).to eq 293888 }
      it { expect(subject.size(human_size: true)).to eq "287.00 KB" }
      it { expect(subject.binrary_size).to eq 293888 }
      it { expect(subject.binrary_size(human_size: true)).to eq "287.00 KB" }
      it { expect(subject.product_version).to eq('3.08 (2011-12-12)') }
      it { expect(subject.release_version).to eq('3.08 (2011-12-12)') }
      it { expect(subject.assembly_version).to be_nil }
      it { expect(subject.build_version).to be_nil }
      it { expect(subject.name).to eq('UPX') }
      it { expect(subject.company_name).to eq('The UPX Team http://upx.sf.net') }
      it { expect(subject.archs).to eq('i386') }
      it { expect(subject.version_info).to be_kind_of(AppInfo::PE::VersionInfo) }
      it { expect(subject.pe).to be_kind_of(PEdump) }

      it "should has imports" do
        imports = subject.imports
        expect(imports).not_to be_nil

        expect(imports).to have_key 'KERNEL32.DLL'
        expect(imports['KERNEL32.DLL']).to be_kind_of Array
      end

      it "should has icons" do
        icons = subject.icons
        expect(icons).not_to be_nil

        expect(icons.size).to eq 0
      end
    end
  end
end
