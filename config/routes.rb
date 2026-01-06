Rails.application.routes.draw do
  root "auth/sessions#new"

  # ================= AUTH =================
  scope module: "auth" do
    get    "/login",  to: "sessions#new"
    post   "/login",  to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get  "/register", to: "registrations#new"
    post "/register", to: "registrations#create"
  end

  # ================= DASHBOARDS =================
  namespace :student do
    get "dashboard", to: "dashboard#index"

    # MUA KHÓA HỌC
    resources :courses, only: [] do
      resources :orders, only: [ :create ] do
        collection do
          get :checkout  # trang thanh toán
          post :pay      # xử lý thanh toán
        end
      end
    end

    # FAKE PAYMENT
    resources :payments, only: [] do
      member do
        patch :mark_paid
      end
    end
  end

  namespace :teacher do
    get "dashboard", to: "dashboard#index"
  end

  namespace :admin do
    get "dashboard", to: "dashboard#index"


    # sau này mở rộng
    resources :teachers do
      resource :teacher_profile, except: [ :show ]
    end
    resources :courses
    resources :students
  end

  # ================= GENERIC =================
  get "/dashboard", to: "dashboard#index"
end
