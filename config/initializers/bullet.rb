if defined?(Bullet)
  Rails.application.config.after_initialize do
    Bullet.enable = Rails.env.local?
    Bullet.rails_logger = Rails.env.development?
    # テストでは N+1 クエリと不要な eager loading を検出したら例外にする
    Bullet.raise = Rails.env.test?
    # counter_cache は使わない方針なので提案させない
    Bullet.counter_cache_enable = false
  end
end
