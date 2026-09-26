const camelCase = '[a-z][a-zA-Z0-9]*'

export default {
  extends: ['stylelint-config-standard-scss'],
  rules: {
    // id セレクタは使わない（CSS-02）
    'selector-max-id': 0,
    // @import と @extend は使わない。@media は直接書かず Bootstrap の mixin を使う（CSS-01, CSS-02, CSS-03）
    'at-rule-disallowed-list': [['import', 'extend', 'media'], {
      message: (name) => `${name} は使わないでください（docs/coding_rules.md の CSS の規約を参照）。`
    }],
    // クラス名は接頭辞 + camelCase。子要素は _、バリエーションは __ でつなぐ（CSS-04）
    'selector-class-pattern': [`^(bl|el|ly|hp)_${camelCase}(_${camelCase})*(__${camelCase})?$`, {
      message: (selector) => `クラス名 ${selector} は bl_ / el_ / ly_ / hp_ の接頭辞と camelCase で付けてください（例: bl_todoItem_title__done）。`
    }],
    // CSS 変数は camelCase。ローカルな変数は「--クラス名--プロパティ名」。Bootstrap の変数（--bs-）はそのまま使う（CSS-05）
    'custom-property-pattern': [`^(bs-[a-z0-9-]+|((bl|el|ly|hp)_${camelCase}(_${camelCase})*--)?${camelCase})$`, {
      message: (name) => `CSS 変数 ${name} は camelCase、ローカルな変数は --クラス名--プロパティ名 で付けてください。`
    }],
    // Sass の変数・mixin・関数は camelCase。private な変数は $_ で始める（CSS-06）
    'scss/dollar-variable-pattern': [`^_?${camelCase}$`, {
      message: (name) => `Sass の変数 $${name} は camelCase で付けてください。private な変数は $_ で始めます。`
    }],
    'scss/at-mixin-pattern': [`^${camelCase}$`, { message: (name) => `mixin ${name} は camelCase で付けてください。` }],
    'scss/at-function-pattern': [`^${camelCase}$`, { message: (name) => `関数 ${name} は camelCase で付けてください。` }],
    'scss/percent-placeholder-pattern': null,
    // z-index は lib/_zindex.scss の変数だけを使う（CSS-07）
    'declaration-property-value-allowed-list': [{ 'z-index': ['/^\\$zIndex[A-Z]/'] }, {
      message: () => 'z-index は lib/_zindex.scss の $zIndex〜 の変数を使ってください。'
    }],
    // !important は使わない（CSS-08）
    'declaration-no-important': true,
    // フォーカスの表示を消さない（CSS-09）
    'declaration-property-value-disallowed-list': [{ outline: ['none', '0'] }, {
      message: () => 'フォーカスの表示を消さないでください。'
    }]
  }
}
