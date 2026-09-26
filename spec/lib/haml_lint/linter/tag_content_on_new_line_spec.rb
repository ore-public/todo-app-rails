require 'haml_lint_helper'

RSpec.describe HamlLint::Linter::TagContentOnNewLine do
  include_context 'linter'

  context 'タグと同じ行に文字列を書いている場合' do
    let(:haml) { '%h1 タイトル' }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'タグと同じ行に Ruby の出力を書いている場合' do
    let(:haml) { '%p.el_title{ data: { x: 1 } }= todo.title' }

    it { is_expected.to report_lint(line: 1) }
  end

  context '内容を次の行に書いている場合' do
    let(:haml) { <<~HAML }
      %h1
        タイトル
      %p
        = todo.title
    HAML

    it { is_expected.not_to report_lint }
  end

  context '内容のない空要素と空白の制御だけのタグの場合' do
    let(:haml) { <<~HAML }
      %br/
      %span<
        text
      %input{ type: 'text' }
    HAML

    it { is_expected.not_to report_lint }
  end
end
