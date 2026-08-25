# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:destroy] do
    member do
      patch :reset_password
    end
  end

  resources :ledgers do
    get 'paginate', on: :collection
  end

  resources :calendar_events
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  scope '/auth' do
    post 'register', to: 'auth#register'
    post 'login',    to: 'auth#login'
    get  'me',       to: 'auth#me'
    get  'users',    to: 'auth#index'
  end

  resources :projects do
    member do
      patch :inactivate
    end
    resources :statuses, only: %i[index create], controller: 'project_statuses' do
      resources :comments, only: %i[create update destroy], controller: 'project_status_comments'
    end
    resources :technical_details, only: %i[index show create update destroy]
  end

  resources :uploads, only: %i[index create destroy] do
    member do
      get :download
    end
    collection do
      delete 'by_item/:item_id', action: :destroy_by_item
    end
  end

  resources :concessionaires do
    get 'paginate', on: :collection
  end

  resources :customers do
    get 'paginate', on: :collection
  end

  resources :addresses do
    get 'paginate', on: :collection
  end

  resources :services do
    get 'paginate', on: :collection
  end

  resources :price_tables do
    get 'paginate', on: :collection
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
