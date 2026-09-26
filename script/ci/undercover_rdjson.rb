# undercover の JSON の出力を標準入力から読み、reviewdog の rdjson を出力する
# 使い方: bundle exec undercover --compare origin/main --format json | ruby script/ci/undercover_rdjson.rb
module CiReport; end
require_relative '../../lib/ci_report/undercover_diagnostics'

puts CiReport::UndercoverDiagnostics.new($stdin.read).to_rdjson
