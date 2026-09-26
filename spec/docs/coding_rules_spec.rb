require 'rails_helper'
require 'open3'
require 'rubocop'
require 'haml_lint'

# docs/coding_rules.md の対応表が、実際の設定と AGENTS.md に合っていることを確認する
RSpec.describe 'コーディング規約の対応表' do
  let(:root) { Rails.root }
  let(:check_prefixes) { %w[RuboCop haml-lint ESLint stylelint AI その他] }
  let(:rules) do
    rows = root.join('docs/coding_rules.md').read.scan(/^\| ([A-Z]+-\d+) \| .+ \| (.+) \|$/)
    rows.map do |id, checks|
      { id:, checks: checks.split(/, (?=(?:#{check_prefixes.join('|')}): )/).map { |check| check.split(': ', 2) } }
    end
  end

  def checks_of(tool)
    rules.flat_map { |rule| rule[:checks].filter_map { |prefix, name| [rule[:id], name] if prefix == tool } }
  end

  def print_config(*command)
    output, status = Open3.capture2(*command, chdir: root.to_s)
    raise "#{command.join(' ')} failed" unless status.success?

    JSON.parse(output).fetch('rules')
  end

  it '規約の ID は重複せず、チェック方法は決められた書き方になっている' do
    ids = rules.pluck(:id)
    expect(ids).not_to be_empty
    expect(ids).to eq ids.uniq
    expect(rules.flat_map { |rule| rule[:checks].map(&:first) }.uniq - check_prefixes).to eq []
  end

  it 'RuboCop の cop は存在し、有効になっている' do
    config = RuboCop::ConfigLoader.configuration_from_file(root.join('.rubocop.yml').to_s)
    registry = RuboCop::Cop::Registry.global

    checks_of('RuboCop').each do |id, name|
      expect(registry.find_cops_by_directive(name)).not_to be_empty, "#{id}: #{name} がありません"
      expect(config.cop_enabled?(name)).to be(true), "#{id}: #{name} が無効です"
    end
  end

  it 'haml-lint の linter は存在し、有効になっている' do
    config = HamlLint::ConfigurationLoader.load_applicable_config(root.join('.haml-lint.yml').to_s)
    linters = HamlLint::LinterRegistry.linters.index_by { |linter| linter.name.demodulize }

    checks_of('haml-lint').each do |id, name|
      expect(linters).to have_key(name), "#{id}: #{name} がありません"
      expect(config.for_linter(linters[name])['enabled']).to be(true), "#{id}: #{name} が無効です"
    end
  end

  it 'ESLint のルールは app/javascript で有効になっている' do
    enabled = print_config('bunx', 'eslint', '--print-config', 'app/javascript/controllers/cursor_controller.js')

    checks_of('ESLint').each do |id, name|
      severity = Array(enabled[name]).first
      expect(severity).not_to be_nil, "#{id}: #{name} が設定されていません"
      expect([0, 'off']).not_to include(severity), "#{id}: #{name} が無効です"
    end
  end

  it 'stylelint のルールは有効になっている' do
    enabled = print_config('bunx', 'stylelint', '--print-config', 'app/assets/stylesheets/application.scss')

    checks_of('stylelint').each do |id, name|
      expect(enabled[name]).not_to be_nil, "#{id}: #{name} が有効ではありません"
    end
  end

  it 'AI 指示の規約は、指定した AGENTS.md に同じ ID で書いてある' do
    checks_of('AI').each do |id, path|
      file = root.join(path)
      expect(file).to exist, "#{id}: #{path} がありません"
      expect(file.read).to include("**#{id}**"), "#{id}: #{path} に書かれていません"
    end
  end

  it 'AGENTS.md に書いた規約は、対応表でその AGENTS.md を AI 指示にしている' do
    documented = checks_of('AI').to_set { |id, path| [id, path] }

    root.glob('{AGENTS.md,{app,config,db,spec}/**/AGENTS.md}').each do |file|
      path = file.relative_path_from(root).to_s
      file.read.scan(/\*\*([A-Z]+-\d+)\*\*/).flatten.each do |id|
        expect(documented).to include([id, path]), "#{path} の #{id} が対応表にありません"
      end
    end
  end
end
