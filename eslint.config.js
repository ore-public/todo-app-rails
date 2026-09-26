import js from '@eslint/js'
import stylistic from '@stylistic/eslint-plugin'
import eslintComments from '@eslint-community/eslint-plugin-eslint-comments'
import globals from 'globals'

const stimulusMessage = 'Stimulus の機能を使ってください（docs/coding_rules.md の JS の規約を参照）。どうしても必要な場合は、理由を書いた eslint-disable コメントを付けてください。'

export default [
  {
    ignores: ['app/assets/builds/**', 'node_modules/**', 'public/**', 'tmp/**', 'vendor/**']
  },
  js.configs.recommended,
  {
    files: ['**/*.js'],
    plugins: {
      '@stylistic': stylistic,
      'eslint-comments': eslintComments
    },
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: globals.browser
    },
    linterOptions: {
      reportUnusedDisableDirectives: 'error'
    },
    rules: {
      '@stylistic/semi': ['error', 'never'],
      '@stylistic/quotes': ['error', 'single', { avoidEscape: true }],
      '@stylistic/indent': ['error', 2],
      '@stylistic/no-trailing-spaces': 'error',
      '@stylistic/no-multiple-empty-lines': ['error', { max: 2 }],
      '@stylistic/space-before-blocks': 'error',
      '@stylistic/keyword-spacing': 'error',
      '@stylistic/comma-dangle': ['error', 'never'],
      'no-unused-vars': ['error', { vars: 'all', args: 'none' }],
      'prefer-const': 'error',
      'no-var': 'error',
      'eqeqeq': 'error',
      'camelcase': 'error',
      'curly': ['error', 'multi-line'],
      // eslint-disable には理由の記述を必須にする（JS-08）
      'eslint-comments/require-description': ['error', { ignore: ['eslint-enable'] }],
      'eslint-comments/no-unlimited-disable': 'error',
      'eslint-comments/disable-enable-pair': ['error', { allowWholeFile: false }]
    }
  },
  {
    files: ['app/javascript/**/*.js'],
    rules: {
      'no-restricted-properties': ['error',
        // DOM は targets / outlets で参照する（JS-01）
        { property: 'querySelector', message: `targets / outlets を使ってください。${stimulusMessage}` },
        { property: 'querySelectorAll', message: `targets / outlets を使ってください。${stimulusMessage}` },
        { property: 'getElementById', message: `targets / outlets を使ってください。${stimulusMessage}` },
        { property: 'getElementsByClassName', message: `targets / outlets を使ってください。${stimulusMessage}` },
        { property: 'getElementsByTagName', message: `targets / outlets を使ってください。${stimulusMessage}` },
        // イベントは data-action で受ける（JS-02）
        { property: 'addEventListener', message: `data-action を使ってください（window / document のイベントは @window / @document）。${stimulusMessage}` },
        { property: 'removeEventListener', message: `data-action を使ってください。${stimulusMessage}` },
        // data 属性は values / Action Parameters で読む（JS-03）
        { property: 'dataset', message: `values または Action Parameters を使ってください。${stimulusMessage}` },
        { property: 'getAttribute', message: `values または Action Parameters を使ってください。${stimulusMessage}` },
        // イベントの既定動作の抑止は action オプションで行う（JS-04）
        { property: 'preventDefault', message: `data-action の :prevent を使ってください。${stimulusMessage}` },
        { property: 'stopPropagation', message: `data-action の :stop を使ってください。${stimulusMessage}` }
      ],
      'no-restricted-syntax': ['error',
        // DOM の変化は [name]TargetConnected で受ける（JS-05）
        { selector: "NewExpression[callee.name='MutationObserver']", message: `[name]TargetConnected / [name]TargetDisconnected を使ってください。${stimulusMessage}` },
        // クラス名は static classes で定義する（JS-06）
        { selector: "CallExpression[callee.object.property.name='classList'] > :matches(Literal, TemplateLiteral)", message: `クラス名は static classes で定義してください。${stimulusMessage}` },
        // action のメソッド名は振る舞いで付ける（JS-07）
        { selector: 'MethodDefinition[key.name=/^on[A-Z]/]', message: 'メソッド名は onClick のようなイベント名ではなく、showDialog のような振る舞いの名前にしてください。' }
      ]
    }
  },
  {
    files: ['bun.config.js', 'eslint.config.js', 'stylelint.config.js'],
    languageOptions: {
      globals: { ...globals.node, Bun: 'readonly' }
    }
  }
]
