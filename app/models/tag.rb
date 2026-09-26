class Tag < ApplicationRecord
  NAME_MAX_LENGTH = 50
  NAME_FORMAT = /\A[^[:space:],]+\z/

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }, format: { with: NAME_FORMAT }

  belongs_to :user, inverse_of: :tags
  has_many :taggings, dependent: :delete_all, inverse_of: :tag
  has_many :todos, through: :taggings

  scope :ordered, -> { order(:name) }
end
