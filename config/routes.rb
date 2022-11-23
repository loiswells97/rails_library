Rails.application.routes.draw do
  resources :books do
    member do
      get :delete
    end
  end
  resources :lists do
    member do
      get :delete
    end
    collection do
      get :current
      get :recent
    end
  end

  resources :targets do
    member do
      get :delete
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
