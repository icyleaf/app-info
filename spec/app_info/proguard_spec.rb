require 'zip'
require 'fileutils'

describe AppInfo::Proguard do
  describe '#SingleMapping' do
    let(:file) { File.dirname(__FILE__) + '/../fixtures/proguards/single_mapping.zip' }
    subject { AppInfo::Proguard.new(file) }

    context 'parse' do
      it { expect(subject.file_type).to eq AppInfo::Platform::PROGUARD }
      it { expect(subject.mapping?).to be true }
      it { expect(subject.mainfest?).to be false }
      it { expect(subject.symbol?).to be false }
      it { expect(subject.resource?).to be false }
    end
  end

  describe '#FullMapping' do
    let(:file) { File.dirname(__FILE__) + '/../fixtures/proguards/full_mapping.zip' }
    subject { AppInfo::Proguard.new(file) }

    context 'parse' do
      it { expect(subject.file_type).to eq AppInfo::Platform::PROGUARD }
      it { expect(subject.mapping?).to be true }
      it { expect(subject.mainfest?).to be true }
      it { expect(subject.symbol?).to be true }
      it { expect(subject.resource?).to be true }
    end
  end

  describe '#CustomMappingFileName' do
    context 'parse' do
      it "should find mapping file" do
        Dir.mktmpdir do |dir|
          names = [
            '2019-12-12-mapping.txt',
            'mapping-2019.12_33.txt',
            'prefix.mapping_suffix.txt'
          ]

          names.each do |name|
            `cd #{dir} && touch #{name}`

            proguard_file = File.join(dir, "#{name}.zip")
            FileUtils.rm_f(proguard_file) if File.exist?(proguard_file)
            Zip::File.open(proguard_file, Zip::File::CREATE) do |zip_file|
              zip_file.add(name, File.join(dir, name))
            end

            parser = AppInfo::Proguard.new(proguard_file)
            expect(parser.mapping?).to be true

            FileUtils.rm_f(proguard_file)
          end
        end
      end
    end
  end
end
