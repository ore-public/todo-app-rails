# bin/ci で実行する。GitHub Actions の .github/workflows/ci.yml も同じ検査を実行する

CI.run do
  step 'Setup', 'bin/setup --skip-server'

  step 'Style: Ruby', 'bin/rubocop'
  step 'Style: Haml', 'bundle exec haml-lint'
  step 'Style: JavaScript', 'bun run eslint'
  step 'Style: Stylesheets', 'bun run stylelint'
  step 'I18n: Locale files', 'bundle exec i18n-tasks health'

  step 'Security: Gem audit', 'bin/bundler-audit'
  step 'Security: npm package audit', 'bun audit'
  step 'Security: Brakeman code analysis', 'bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error'

  step 'DB: Schema matches migrations', 'git diff --exit-code db/schema.rb'
  step 'DB: Consistency between models and schema', 'bundle exec database_consistency'
  step 'Code: Autoloading', 'bin/rails zeitwerk:check'

  step 'Tests: RSpec with coverage', 'env COVERAGE=true bin/rspec'
  step 'Tests: Seeds', 'env RAILS_ENV=test bin/rails db:seed:replant'
end
