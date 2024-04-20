Rails.application.routes.draw do
  resources :merchants, only: %i[show] do
    resources :dashboard, only: %i[index]
    resources :items, except: %i[destroy]
    resources :item_status, only: %i[update]
    resources :invoices, only: %i[index show update]
    resources :coupons, only: %i[index show]
  end

  namespace :admin do
    resources :dashboard, only: %i[index]
    resources :merchants, except: %i[destroy]
    resources :merchant_status, only: %i[update]
    resources :invoices, except: %i[new destroy]
  end
end
