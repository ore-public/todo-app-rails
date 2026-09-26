# SimpleCov の結果から、PR にコメントするカバレッジの要約を出力する
# 使い方: ruby script/ci/coverage_summary.rb [coverage/coverage.json]
require 'json'

module CiReport; end
require_relative '../../lib/ci_report/coverage_summary'

puts CiReport::CoverageSummary.new(JSON.parse(File.read(ARGV.fetch(0, 'coverage/coverage.json')))).to_markdown
