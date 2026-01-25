Rails.application.routes.draw do
  # ================= AUTH =================
  devise_for :users, controllers: {
    passwords: "users/passwords"
  }

  # ================= DASHBOARD =================
  authenticated :user do
    root to: "dashboard#redirect", as: :authenticated_root
  end

  unauthenticated do
    root to: redirect("/users/sign_in")
  end


  namespace :teacher do
    get "dashboard", to: "dashboard#index"
  end
# ================= STUDENT =================
namespace :students do
  get "dashboard", to: "dashboard#index"
  resource :profile, only: [ :edit, :update ]
  # ================== PAYMENTS ==================
  resources :payments, only: [ :create ] do
    collection do
      get :vnpay_return
      post :vnpay_ipn 
    end
  end

  # ================== COURSES ==================
  resources :courses, only: [ :index, :show ] do
    resources :orders, only: [ :new, :create, :show ] do
      member do
        get  :checkout
        post :pay
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
    resources :students, only: [ :index ]
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
