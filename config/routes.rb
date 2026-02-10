Rails.application.routes.draw do
  get "home/index"
  # ================= AUTH =================
  devise_for :users, controllers: {
    passwords: "users/passwords"
  }

  # ================= DASHBOARD REDIRECT ROOT =================
  authenticated :user do
    root to: "dashboard#redirect", as: :authenticated_root
  end

  unauthenticated do
    root "home#index"
  end


# ================= STUDENT =================
namespace :students do
  get "dashboard", to: "dashboard#index"
  resource :profile, only: [ :edit, :update ]
  resources :speaking_attempts, only: [:create]

  # ================== PAYMENTS ==================
  resources :payments, only: [ :create ] do
    collection do
      get :vnpay_return
      match :vnpay_ipn, via: [:get, :post] 
      post :momo_create
      post :momo_notify
      get  :momo_return

    end
  end

  # ================== COURSES ==================
  resources :courses, only: [ :index, :show ] do
    resources :orders, only: [ :new, :create, :show ] do
      member do
        get  :checkout
      end
    end
  end
end



  # ================= ADMIN =================
  namespace :admin do
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index"
    resource :profile, only: [ :edit, :update ]
    resources :users
    resources :achievements
    resources :students, only: [ :index, :edit, :update, :destroy, :show ]
    resources :payments, only: [ :index ]

    resources :teachers do
      resource :teacher_profile
    end

    resources :courses do
      resources :course_sections do
        resources :lessons
      end
    end
  end
end
