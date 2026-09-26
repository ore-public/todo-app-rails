require 'rails_helper'

RSpec.describe 'todo の画面' do
  let(:user) { create(:user) }

  describe 'PC 幅でのキーボード操作', :js do
    before do
      travel_to Time.zone.local(2026, 9, 26, 10, 0, 0)
      create(:todo, user:, title: '資料作成', scheduled_on: Date.new(2026, 9, 26), tag_names: ['仕事'])
      create(:todo, user:, title: '牛乳を買う', scheduled_on: Date.new(2026, 9, 27), tag_names: ['買い物'])
      create(:todo, user:, title: 'いつかやる')
      sign_in_as user
    end

    it '1 行の入力で todo を追加し、実施日ごとに表示する' do
      fill_in 'todo を追加', with: '会議の準備 #仕事 @today !+2d'
      click_on '追加'

      within('.bl_todoGroup', text: '今日 9/26(土)') do
        expect(page).to have_css('.bl_todoItem', text: '会議の準備 #仕事 期限間近 9/28(月)', normalize_ws: true)
      end
      expect(page).to have_field('todo を追加', with: '')
    end

    it '入力が正しくなければエラーを表示する' do
      fill_in 'todo を追加', with: '#仕事'
      click_on '追加'

      expect(page).to have_css('[role=alert]', text: 'タイトルを入力してください')
    end

    it 'j / k でカーソルを動かし、x で完了にする' do
      expect(page).to have_css('.bl_todoItem[aria-current=true]', text: '資料作成')

      page.send_keys('j')
      expect(page).to have_css('.bl_todoItem[aria-current=true]', text: '牛乳を買う')

      page.send_keys('x')
      expect(page).to have_no_text('牛乳を買う')
      # 完了して一覧から消えた todo と同じ位置の todo を選択する
      expect(page).to have_css('.bl_todoItem[aria-current=true]', text: 'いつかやる')

      page.send_keys('k')
      expect(page).to have_css('.bl_todoItem[aria-current=true]', text: '資料作成')
    end

    it 'Ctrl + j で実施日を 1 日後にし、同じ todo を選択し続ける' do
      page.send_keys([:control, 'j'])

      within('.bl_todoGroup', text: '明日 9/27(日)') do
        expect(page).to have_css('.bl_todoItem[aria-current=true]', text: '資料作成')
      end
    end

    it 'e で編集ダイアログを開いて保存する' do
      page.send_keys('e')

      within('dialog[open]') do
        fill_in 'タイトル', with: '企画書作成'
        click_on '今日', match: :first
        click_on '+1 日', match: :first
        click_on '保存'
      end

      expect(page).to have_no_css('dialog[open]')
      within('.bl_todoGroup', text: '明日 9/27(日)') do
        expect(page).to have_css('.bl_todoItem', text: '企画書作成')
      end
    end

    it 't でタグの入力欄にフォーカスした編集ダイアログを開く' do
      page.send_keys('t')

      expect(page).to have_field('タグ（空白区切り）', with: '仕事', focused: true)
    end

    it 'd で確認ダイアログを開き、Enter で削除する' do
      page.send_keys('d')

      expect(page).to have_css('dialog[open]', text: '「資料作成」を削除しますか？')
      page.send_keys(:enter)

      expect(page).to have_no_text('資料作成')
      expect(user.todos.pluck(:title)).to contain_exactly('牛乳を買う', 'いつかやる')
    end

    it '/ でタグの絞り込みに移動し、c で完了済みも表示する' do
      page.send_keys('/')
      expect(page).to have_select('タグで絞り込み', focused: true)

      select '#仕事 (1)', from: 'タグで絞り込み'
      expect(page).to have_no_text('牛乳を買う')
      expect(page).to have_text('資料作成')

      find('body').send_keys(:escape)
      page.send_keys('c')
      expect(page).to have_checked_field('完了済みも表示')
    end

    it '? でキーボード操作のヘルプを表示する' do
      page.send_keys('?')

      expect(page).to have_css('dialog[open]', text: 'キーボード操作')
    end
  end

  describe 'スマホ幅でのタップ操作', :mobile do
    before do
      create(:todo, user:, title: 'とても長いタイトルの todo ' * 5, tag_names: %w[仕事 急ぎ 買い物])
      sign_in_as user
    end

    it '横にスクロールせずに表示し、チェックボックスのタップで完了にする' do
      expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be true

      find('.bl_todoItem input[type=checkbox]').click

      expect(page).to have_text('todo はありません')
      expect(user.todos.completed.count).to eq 1
    end
  end
end
