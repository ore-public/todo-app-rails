Rails.application.config.dartsass.build_options << '--load-path=node_modules'
# Bootstrap 5.3 の Sass が出す非推奨の警告を表示しない
Rails.application.config.dartsass.build_options << '--quiet-deps'
Rails.application.config.dartsass.build_options << '--silence-deprecation=import'
