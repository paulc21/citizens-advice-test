Rails.application.routes.draw do
  # Order management
  resources :orders, only: [:index,:show,:create] do
    member do
      # Order status changes
      match 'place', to: 'orders#place', via: [:get,:post]
      match 'pay', to: 'orders#pay', via: [:get,:post]
      match 'cancel', to: 'orders#cancel', via: [:get,:post]
    end
    # Item management
    resources :items, only: [:create,:update,:destroy], controller: 'line_items'
  end
  # Product management
  resources :products, except: [:new,:edit]
end
