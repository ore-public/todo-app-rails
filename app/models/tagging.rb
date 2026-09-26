class Tagging < ApplicationRecord
  belongs_to :todo, inverse_of: :taggings
  belongs_to :tag, inverse_of: :taggings
end
