require 'rails_helper'

RSpec.describe TodosHelper do
  describe '#tag_filter_options について' do
    it '先頭に「すべてのタグ」を置き、タグごとに未完了の件数を付ける' do
      work_tag = build_stubbed(:tag, id: 1, name: '仕事')
      shopping_tag = build_stubbed(:tag, id: 2, name: '買い物')

      expect(helper.tag_filter_options([work_tag, shopping_tag], { 1 => 3 })).to eq [['すべてのタグ', ''], ['#仕事 (3)', '仕事'], ['#買い物 (0)', '買い物']]
    end
  end

  describe '#due_badge について' do
    let(:today) { Date.new(2026, 9, 26) }

    it '期限の状態に合わせた文言とクラスで表示する' do
      expect(helper.due_badge(build(:todo, due_on: Date.new(2026, 9, 25)), today:)).to eq '<span class="el_dueBadge el_dueBadge__overdue">期限切れ 9/25(金)</span>'
      expect(helper.due_badge(build(:todo, due_on: Date.new(2026, 9, 27)), today:)).to eq '<span class="el_dueBadge el_dueBadge__soon">期限間近 9/27(日)</span>'
      expect(helper.due_badge(build(:todo, due_on: Date.new(2026, 10, 1)), today:)).to eq '<span class="el_dueBadge el_dueBadge__later">期限 10/1(木)</span>'
    end

    it '完了済みの todo は状態を付けずに期限を表示する' do
      todo = create(:todo, :completed, due_on: Date.new(2026, 9, 25))

      expect(helper.due_badge(todo, today:)).to eq '<span class="el_dueBadge el_dueBadge__none">期限 9/25(金)</span>'
    end
  end
end
