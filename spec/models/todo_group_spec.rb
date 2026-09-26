require 'rails_helper'

RSpec.describe TodoGroup do
  let(:today) { Date.new(2026, 9, 26) }

  describe '.group について' do
    it '実施日の昇順にまとめ、実施日のないグループを最後にし、グループの中は作成順に並べる' do
      unscheduled = build_stubbed(:todo, id: 1, scheduled_on: nil)
      later = build_stubbed(:todo, id: 2, scheduled_on: Date.new(2026, 9, 28))
      earlier_second = build_stubbed(:todo, id: 4, scheduled_on: Date.new(2026, 9, 27))
      earlier_first = build_stubbed(:todo, id: 3, scheduled_on: Date.new(2026, 9, 27))

      groups = TodoGroup.group([unscheduled, later, earlier_second, earlier_first])

      expect(groups.map(&:date)).to eq [Date.new(2026, 9, 27), Date.new(2026, 9, 28), nil]
      expect(groups.map(&:todos)).to eq [[earlier_first, earlier_second], [later], [unscheduled]]
    end
  end

  describe '#label について' do
    it '昨日・今日・明日は相対的な呼び方を付け、それ以外は日付と曜日だけにする' do
      expect(TodoGroup.new(date: Date.new(2026, 9, 25), todos: []).label(today:)).to eq '昨日 9/25(金)'
      expect(TodoGroup.new(date: Date.new(2026, 9, 26), todos: []).label(today:)).to eq '今日 9/26(土)'
      expect(TodoGroup.new(date: Date.new(2026, 9, 27), todos: []).label(today:)).to eq '明日 9/27(日)'
      expect(TodoGroup.new(date: Date.new(2026, 9, 28), todos: []).label(today:)).to eq '9/28(月)'
      expect(TodoGroup.new(date: nil, todos: []).label(today:)).to eq '実施日なし'
    end
  end

  describe '#past? について' do
    it '実施日が今日より前なら true を返す' do
      expect(TodoGroup.new(date: Date.new(2026, 9, 25), todos: []).past?(today:)).to be true
      expect(TodoGroup.new(date: Date.new(2026, 9, 26), todos: []).past?(today:)).to be false
      expect(TodoGroup.new(date: nil, todos: []).past?(today:)).to be false
    end
  end
end
