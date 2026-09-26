require 'rails_helper'

RSpec.describe Todo do
  let(:user) { create(:user) }

  describe 'バリデーションについて' do
    it 'タイトルは前後の空白を除いて 1〜500 文字' do
      expect(build(:todo, user:, title: '  資料作成  ').title).to eq '資料作成'
      expect(build(:todo, user:, title: ' ')).not_to be_valid
      expect(build(:todo, user:, title: 'あ' * 500)).to be_valid
      expect(build(:todo, user:, title: 'あ' * 501)).not_to be_valid
    end

    it 'メモは 10000 文字まで' do
      expect(build(:todo, user:, note: 'あ' * 10_000)).to be_valid
      expect(build(:todo, user:, note: 'あ' * 10_001)).not_to be_valid
    end

    it 'タグは 20 個まで' do
      expect(build(:todo, user:, tag_list: (1..20).map { |n| "tag#{n}" }.join(' '))).to be_valid

      todo = build(:todo, user:, tag_list: (1..21).map { |n| "tag#{n}" }.join(' '))
      expect(todo).not_to be_valid
      expect(todo.errors.full_messages).to eq ['タグ（空白区切り）は 20 個までです']
    end

    it 'タグ名は 50 文字まで' do
      expect(build(:todo, user:, tag_list: 'a' * 50)).to be_valid

      todo = build(:todo, user:, tag_list: "ok #{'a' * 51}")
      expect(todo).not_to be_valid
      expect(todo.errors.full_messages).to eq ["タグ（空白区切り）に使えない名前があります（#{'a' * 51}）。タグは 50 文字以内で、空白とカンマは使えません"]
    end
  end

  describe '#tag_names= について' do
    context '新しい todo の場合' do
      it 'まだないタグを作り、既存のタグはそのまま使う' do
        existing_tag = create(:tag, user:, name: '仕事')

        todo = create(:todo, user:, tag_names: ['仕事', '急ぎ', '仕事', ' '])

        expect(todo.tag_names).to eq %w[仕事 急ぎ]
        expect(todo.tags).to include(existing_tag)
        expect(user.tags.order(:name).pluck(:name)).to eq %w[仕事 急ぎ]
      end
    end

    context '保存済みの todo の場合' do
      let(:todo) { create(:todo, user:, tag_names: %w[仕事 急ぎ]) }

      it '保存するまでタグの付け替えを DB に反映しない' do
        todo.tag_names = %w[急ぎ 買い物]

        expect(todo.tag_names).to eq %w[急ぎ 買い物]
        expect(todo.reload.tag_names).to eq %w[仕事 急ぎ]
      end

      it '保存すると外したタグの関連を消し、タグ自体は残す' do
        todo.update!(tag_names: %w[急ぎ 買い物])

        expect(todo.reload.tag_names).to contain_exactly('急ぎ', '買い物')
        expect(user.tags.pluck(:name)).to contain_exactly('仕事', '急ぎ', '買い物')
      end
    end

    it '他のユーザーの同じ名前のタグは使わない' do
      other_tag = create(:tag, name: '仕事')

      todo = create(:todo, user:, tag_names: ['仕事'])

      expect(todo.tags).not_to include(other_tag)
      expect(todo.tags.first.user).to eq user
    end
  end

  describe '#tag_list について' do
    it '空白かカンマで区切ってタグを設定し、空白区切りで返す' do
      todo = build(:todo, user:, tag_list: '仕事, 急ぎ　買い物')

      expect(todo.tag_names).to eq %w[仕事 急ぎ 買い物]
      expect(todo.tag_list).to eq '仕事 急ぎ 買い物'
    end
  end

  describe 'scope について' do
    it '.open は未完了、.completed は完了済みの todo を返す' do
      open_todo = create(:todo, user:)
      completed_todo = create(:todo, :completed, user:)

      expect(Todo.open).to eq [open_todo]
      expect(Todo.completed).to eq [completed_todo]
    end

    it '.tagged は指定した名前のタグが付いた todo を返す' do
      work_todo = create(:todo, user:, tag_names: %w[仕事 急ぎ])
      create(:todo, user:, tag_names: ['買い物'])
      create(:todo, user:)

      expect(Todo.tagged('仕事')).to eq [work_todo]
    end

    it '.in_schedule_order は実施日の昇順で、実施日のないものを最後に、同じ日は作成順に並べる' do
      unscheduled = create(:todo, user:, scheduled_on: nil)
      later = create(:todo, user:, scheduled_on: Date.new(2026, 10, 2))
      earlier_first = create(:todo, user:, scheduled_on: Date.new(2026, 10, 1))
      earlier_second = create(:todo, user:, scheduled_on: Date.new(2026, 10, 1))

      expect(Todo.in_schedule_order.to_a).to eq [earlier_first, earlier_second, later, unscheduled]
    end
  end

  describe '#complete! と #reopen! について' do
    let(:todo) { create(:todo, user:) }

    it '完了にすると完了日時の記録を作り、未完了に戻すと消す' do
      todo.complete!
      expect(todo.reload.completed?).to be true

      todo.reopen!
      expect(todo.reload.completed?).to be false
      expect(Todo::Completion.count).to eq 0
    end

    it '未完了の todo を未完了に戻しても何も変わらない' do
      todo.reopen!

      expect(todo.reload.completed?).to be false
    end

    it '完了済みの todo をもう一度完了にしても記録は 1 件のまま' do
      todo.complete!
      todo.complete!

      expect(Todo::Completion.where(todo:).count).to eq 1
    end
  end

  describe '#reschedule_by! について' do
    let(:today) { Date.new(2026, 9, 26) }

    it '実施日を指定した日数ずらす' do
      todo = create(:todo, user:, scheduled_on: Date.new(2026, 9, 30))

      todo.reschedule_by!(-1, today:)

      expect(todo.reload.scheduled_on).to eq Date.new(2026, 9, 29)
    end

    it '実施日がなければ今日にする' do
      todo = create(:todo, user:, scheduled_on: nil)

      todo.reschedule_by!(1, today:)

      expect(todo.reload.scheduled_on).to eq Date.new(2026, 9, 26)
    end
  end

  describe '#due_status について' do
    let(:today) { Date.new(2026, 9, 26) }

    it '期限との差で期限切れ・期限間近・それ以降を返す' do
      expect(build(:todo, due_on: Date.new(2026, 9, 25)).due_status(today:)).to eq :overdue
      expect(build(:todo, due_on: Date.new(2026, 9, 26)).due_status(today:)).to eq :soon
      expect(build(:todo, due_on: Date.new(2026, 9, 28)).due_status(today:)).to eq :soon
      expect(build(:todo, due_on: Date.new(2026, 9, 29)).due_status(today:)).to eq :later
    end

    it '期限がないか完了済みなら nil を返す' do
      expect(build(:todo, due_on: nil).due_status(today:)).to be_nil
      expect(create(:todo, :completed, due_on: Date.new(2026, 9, 25)).due_status(today:)).to be_nil
    end
  end

  describe '削除について' do
    it 'todo を削除すると完了の記録とタグの関連も消え、タグ自体は残る' do
      todo = create(:todo, :completed, user:, tag_names: ['仕事'])

      todo.destroy!

      expect(Todo::Completion.count).to eq 0
      expect(Tagging.count).to eq 0
      expect(user.tags.pluck(:name)).to eq ['仕事']
    end
  end
end
