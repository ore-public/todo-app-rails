require 'haml_lint_helper'

RSpec.describe HamlLint::Linter::NoInlineScript do
  include_context 'linter'

  context 'script タグを使っている場合' do
    let(:haml) { '%script' }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'javascript フィルタを使っている場合' do
    let(:haml) { <<~HAML }
      :javascript
        alert('x')
    HAML

    it { is_expected.to report_lint(line: 1) }
  end

  context 'script タグも javascript フィルタも使っていない場合' do
    let(:haml) { <<~HAML }
      %div{ data: { controller: 'dialog' } }
      :plain
        text
    HAML

    it { is_expected.not_to report_lint }
  end
end
