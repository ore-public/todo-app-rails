FactoryBot.define do
  factory :todo do
    user
    sequence(:title) { |n| "todo #{n}" }

    trait :completed do
      completion { association :todo_completion, todo: instance }
    end
  end

  factory :todo_completion, class: 'Todo::Completion' do
    todo
  end
end
