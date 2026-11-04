# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec::Matchers.define_negated_matcher :exclude, :include

describe WebTranslateIt::Commands::Init do
  subject(:command) { described_class.new(nil, {}, parameters) }

  let(:api_key) { 'proj_pvt_test_key' }
  let(:parameters) { [api_key] }
  let(:project_info) do
    {'project' => {'name' => 'Frontend', 'source_locale' => {'code' => 'en'},
                   'target_locales' => [{'code' => 'en'}, {'code' => 'fr'}], 'project_files' => [{'id' => 1}]}}
  end
  let(:configuration) { File.read('.wti') }

  around do |example|
    previous = ENV.delete('WTI_PROJECT_API_KEY')
    Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
  ensure
    previous.nil? ? ENV.delete('WTI_PROJECT_API_KEY') : ENV['WTI_PROJECT_API_KEY'] = previous
  end

  before { allow(WebTranslateIt::Project).to receive(:fetch_info).and_return(project_info.to_json) }

  def git_init(gitignore: nil)
    system('git', 'init', '-q', exception: true)
    File.write('.gitignore', gitignore) if gitignore
  end

  context 'when the key is passed as a parameter' do
    it 'writes the key into the configuration file' do
      expect { command.call }.to output.to_stdout
      expect(configuration).to include("api_key: #{api_key}\n")
    end

    it 'warns when the configuration file is not ignored by git' do
      git_init
      expect { command.call }.to output(/`.wti` contains your Project API Key and is not ignored by git/).to_stdout
    end

    it 'does not warn when the configuration file is ignored by git' do
      git_init(gitignore: ".wti\n")
      expect { command.call }.not_to output(/not ignored by git/).to_stdout
    end

    it 'does not warn outside a git work tree' do
      expect { command.call }.not_to output(/not ignored by git/).to_stdout
    end
  end

  context 'when WTI_PROJECT_API_KEY is set' do
    before { ENV['WTI_PROJECT_API_KEY'] = api_key }

    it 'reads the key from the environment instead of writing it' do
      expect { command.call }.to output.to_stdout
      expect(configuration).to include("api_key: <%= ENV['WTI_PROJECT_API_KEY'] %>\n").and(exclude(api_key))
    end

    it 'does not warn about git, since the file holds no secret' do
      git_init
      expect { command.call }.not_to output(/not ignored by git/).to_stdout
    end

    it 'writes a configuration the gem can load back' do
      expect { command.call }.to output.to_stdout
      expect(YAML.safe_load(ERB.new(configuration).result)['api_key']).to eq(api_key)
    end

    context 'without parameters' do
      let(:parameters) { [] }

      before { allow(WebTranslateIt::Prompt).to receive(:ask).with(' Path to configuration file:', '.wti').and_return('.wti') }

      it 'uses the key from the environment without prompting for it' do
        expect { command.call }.to output(/Using the Project API Key from WTI_PROJECT_API_KEY/).to_stdout
        expect(WebTranslateIt::Project).to have_received(:fetch_info).with(api_key)
      end

      it 'keeps the key out of the configuration file' do
        expect { command.call }.to output.to_stdout
        expect(configuration).not_to include(api_key)
      end
    end

    context 'with a different key passed as a parameter' do
      let(:parameters) { ['proj_pvt_other_key'] }

      it 'writes the passed key and warns that the environment takes precedence' do
        expect { command.call }.to output(/WTI_PROJECT_API_KEY is set and takes precedence/).to_stdout
        expect(configuration).to include("api_key: proj_pvt_other_key\n")
      end
    end
  end
end
