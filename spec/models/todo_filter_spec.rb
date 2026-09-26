require 'rails_helper'

RSpec.describe TodoFilter do
  let(:user) { create(:user) }
  let(:work_todo) { create(:todo, user:, title: '資料作成', tag_names: ['仕事']) }
  let(:completed_work_todo) { create(:todo, :completed, user:, title: '会議', tag_names: ['仕事']) }
  let(:shopping_todo) { create(:todo, user:, title: '牛乳', tag_names: ['買い物']) }

  before do
    work_todo
    completed_work_todo
    shopping_todo
    create(:todo, title: '他のユーザーの todo')
  end

  describe '#todos について' do
    it '条件がなければ、ログイン中のユーザーの未完了の todo を返す' do
      expect(TodoFilter.new(user:).todos.map(&:title)).to contain_exactly('資料作成', '牛乳')
    end

    it '完了済みも表示する場合は、完了済みの todo も返す' do
      expect(TodoFilter.new(user:, show_completed: 'true').todos.map(&:title)).to contain_exactly('資料作成', '会議', '牛乳')
    end

    it 'タグを指定した場合は、そのタグが付いた todo だけを返す' do
      expect(TodoFilter.new(user:, tag: '仕事', show_completed: 'true').todos.map(&:title)).to contain_exactly('資料作成', '会議')
    end
  end

  describe '#to_params について' do
    it '指定された条件だけを返す' do
      expect(TodoFilter.new(user:).to_params).to eq({})
      expect(TodoFilter.new(user:, tag: '仕事', show_completed: 'true').to_params).to eq({ tag: '仕事', show_completed: true })
    end
  end

  describe '#open_todo_counts_by_tag_id について' do
    it 'タグごとの未完了の todo の件数を返す' do
      work_tag = user.tags.find_by!(name: '仕事')
      shopping_tag = user.tags.find_by!(name: '買い物')

      expect(TodoFilter.new(user:).open_todo_counts_by_tag_id).to eq({ work_tag.id => 1, shopping_tag.id => 1 })
    end
  end

  describe '#groups について' do
    it '実施日ごとにまとめた todo を返す' do
      expect(TodoFilter.new(user:).groups.map { |group| group.todos.map(&:title) }).to eq [%w[資料作成 牛乳]]
    end
  end

  describe '#tags について' do
    it 'ログイン中のユーザーのタグを名前順に返す' do
      expect(TodoFilter.new(user:).tags.map(&:name)).to eq %w[仕事 買い物]
    end
  end
end
