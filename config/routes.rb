Rails.application.routes.draw do
  root 'todos#index'

  resources :todos, only: %i[index create edit update destroy] do
    scope module: :todos do
      resource :completion, only: %i[create destroy]
      resource :schedule, only: :update
    end
  end

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  resource :registration, only: %i[new create]

  # ロードバランサーなどから死活監視に使う
  get 'up' => 'rails/health#show', as: :rails_health_check
end
