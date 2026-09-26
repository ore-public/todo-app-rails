class User < ApplicationRecord
  PASSWORD_MIN_LENGTH = 8

  has_secure_password
  normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true

  has_many :sessions, dependent: :destroy, inverse_of: :user
  has_many :todos, dependent: :destroy, inverse_of: :user
  has_many :tags, dependent: :destroy, inverse_of: :user

  # タグの絞り込みの選択肢に表示する、タグごとの未完了の todo の件数
  def open_todo_counts_by_tag_id
    todos.open.joins(:taggings).group('taggings.tag_id').count
  end
end
