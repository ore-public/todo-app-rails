class Todo::Completion < ApplicationRecord
  belongs_to :todo, inverse_of: :completion
end
