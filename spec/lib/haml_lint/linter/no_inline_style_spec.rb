require 'haml_lint_helper'

RSpec.describe HamlLint::Linter::NoInlineStyle do
  include_context 'linter'

  context 'style 属性で CSS のプロパティを指定している場合' do
    let(:haml) { "%div{ style: 'color: red' }" }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'HTML 形式の属性で style を指定している場合' do
    let(:haml) { '%div(style="color: red")' }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'style 属性の値が文字列でない場合' do
    let(:haml) { '%div{ style: todo_style }' }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'ヘルパーの style オプションで CSS のプロパティを指定している場合' do
    let(:haml) { "= tag.div(flash[:alert], style: 'color:red')" }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'ヘルパーの style オプションで CSS カスタムプロパティだけを指定している場合' do
    let(:haml) { "= tag.div(todo.title, style: '--progress: 50%')" }

    it { is_expected.not_to report_lint }
  end

  context 'style タグを使っている場合' do
    let(:haml) { '%style' }

    it { is_expected.to report_lint(line: 1) }
  end

  context 'css フィルタを使っている場合' do
    let(:haml) { <<~HAML }
      :css
        .el_title { color: red; }
    HAML

    it { is_expected.to report_lint(line: 1) }
  end

  context 'style 属性で CSS カスタムプロパティだけを指定している場合' do
    let(:haml) { <<~'HAML' }
      %div{ style: "--progress: #{progress}%; --color: red" }
    HAML

    it { is_expected.not_to report_lint }
  end

  context 'style 属性を使っていない場合' do
    let(:haml) { "%div.el_title{ data: { controller: 'dialog' } }" }

    it { is_expected.not_to report_lint }
  end

  context 'style を含まない Ruby の出力と、CSS 以外のフィルタの場合' do
    let(:haml) { <<~HAML }
      = todo.title
      :plain
        text
    HAML

    it { is_expected.not_to report_lint }
  end
end
