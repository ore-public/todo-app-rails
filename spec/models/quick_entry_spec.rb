require 'rails_helper'

RSpec.describe QuickEntry do
  let(:user) { create(:user) }
  let(:today) { Date.new(2026, 9, 26) }

  describe '1 行の入力の解釈について' do
    it '#タグ、@実施日、!期限を取り出し、残りの語をタイトルにする' do
      entry = QuickEntry.new(user:, today:, text: '資料作成 #仕事 @tomorrow !2026-10-01 #急ぎ 午後')

      expect(entry.title).to eq '資料作成 午後'
      expect(entry.tag_names).to eq %w[仕事 急ぎ]
      expect(entry.scheduled_on).to eq Date.new(2026, 9, 27)
      expect(entry.due_on).to eq Date.new(2026, 10, 1)
    end

    it '記号だけの語と全角空白で区切った語も扱う' do
      entry = QuickEntry.new(user:, today:, text: '　メール # 返信　#連絡')

      expect(entry.title).to eq 'メール # 返信'
      expect(entry.tag_names).to eq ['連絡']
    end

    it '日付を指定しなければ実施日と期限は nil' do
      entry = QuickEntry.new(user:, today:, text: '資料作成')

      expect(entry.scheduled_on).to be_nil
      expect(entry.due_on).to be_nil
    end
  end

  describe '.parse_date について' do
    it '日付の形式と、今日からの相対的な指定を解釈する' do
      expect(QuickEntry.parse_date('today', today:)).to eq Date.new(2026, 9, 26)
      expect(QuickEntry.parse_date('Tomorrow', today:)).to eq Date.new(2026, 9, 27)
      expect(QuickEntry.parse_date('yesterday', today:)).to eq Date.new(2026, 9, 25)
      expect(QuickEntry.parse_date('+3d', today:)).to eq Date.new(2026, 9, 29)
      expect(QuickEntry.parse_date('-2d', today:)).to eq Date.new(2026, 9, 24)
      expect(QuickEntry.parse_date('+1w', today:)).to eq Date.new(2026, 10, 3)
      expect(QuickEntry.parse_date('2026-12-31', today:)).to eq Date.new(2026, 12, 31)
    end

    it '解釈できない値は nil を返す' do
      expect(QuickEntry.parse_date('2026-02-30', today:)).to be_nil
      expect(QuickEntry.parse_date('next week', today:)).to be_nil
      expect(QuickEntry.parse_date('+3m', today:)).to be_nil
    end
  end

  describe '#save について' do
    it 'ログイン中のユーザーの todo を作る' do
      entry = QuickEntry.new(user:, today:, text: '資料作成 #仕事 @today')

      expect(entry.save).to be true
      todo = user.todos.sole
      expect(todo.title).to eq '資料作成'
      expect(todo.tag_names).to eq ['仕事']
      expect(todo.scheduled_on).to eq Date.new(2026, 9, 26)
    end

    it 'タイトルがなければ保存せず、エラーを返す' do
      entry = QuickEntry.new(user:, today:, text: '#仕事 @today')

      expect(entry.save).to be false
      expect(entry.errors.full_messages).to eq ['タイトルを入力してください']
      expect(user.todos.count).to eq 0
    end

    it '日付を解釈できなければ保存せず、エラーを返す' do
      entry = QuickEntry.new(user:, today:, text: '資料作成 @someday')

      expect(entry.save).to be false
      expect(entry.errors.full_messages).to eq ['「someday」を日付として解釈できません']
    end

    it 'todo のバリデーションのエラーを返す' do
      entry = QuickEntry.new(user:, today:, text: "資料作成 ##{'a' * 51}")

      expect(entry.save).to be false
      expect(entry.errors.full_messages).to eq ["タグ（空白区切り）に使えない名前があります（#{'a' * 51}）。タグは 50 文字以内で、空白とカンマは使えません"]
    end
  end
end
