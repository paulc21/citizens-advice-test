Rails.application.routes.draw do
  # Order management
  resources :orders, only: [:index,:show,:create,:update] do
    member do
      # Order status changes
      match 'place', to: 'orders#place', via: [:get,:post]
      match 'pay', to: 'orders#pay', via: [:get,:post]
      match 'cancel', to: 'orders#cancel', via: [:get,:post]
      # Item management
      match 'add_item', to: 'orders#add_item', via: [:get,:post]
      match 'remove_item', to: 'orders#remove_item', via: [:get,:post]
    end
  end
  # Product management
  resources :products, except: [:new,:edit]
end
