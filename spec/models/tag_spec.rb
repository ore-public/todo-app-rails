require 'rails_helper'

RSpec.describe Tag do
  describe 'バリデーションについて' do
    it '名前は前後の空白を除いて 1〜50 文字で、空白とカンマを含まない' do
      expect(build(:tag, name: ' 仕事 ').name).to eq '仕事'
      expect(build(:tag, name: 'a' * 50)).to be_valid
      expect(build(:tag, name: 'a' * 51)).not_to be_valid
      expect(build(:tag, name: '')).not_to be_valid
      expect(build(:tag, name: '仕事 急ぎ')).not_to be_valid
      expect(build(:tag, name: '仕事,急ぎ')).not_to be_valid
    end
  end

  describe '削除について' do
    it 'タグを削除すると todo から外れ、todo は残る' do
      todo = create(:todo, tag_names: ['仕事'])

      todo.tags.first.destroy!

      expect(todo.reload.tag_names).to eq []
      expect(Todo.count).to eq 1
    end
  end
end
