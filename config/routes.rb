Rails.application.routes.draw do
  root "auth/sessions#new"

  # ================= AUTH =================
  scope module: "auth" do
    get    "/login",  to: "sessions#new"
    post   "/login",  to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get  "/register", to: "registrations#new"
    post "/register", to: "registrations#create"
    get  "/confirm",  to: "confirmations#show", as: :confirm_account
  end

  # ================= STUDENT =================
  namespace :student do
    get "dashboard", to: "dashboard#index"

    resources :courses, only: [] do
      resources :orders, only: [ :create ] do
        collection do
          get  :checkout
          post :pay
        end
      end
    end

    resources :payments, only: [] do
      member do
        patch :mark_paid
      end
    end
  end

  # ================= TEACHER =================
  namespace :teacher do
    get "dashboard", to: "dashboard#index"
  end

  # ================= ADMIN =================
  namespace :admin do
    get "dashboard", to: "dashboard#index"

    resources :users, only: [ :index ]
    resources :students, only: [ :index ]
    resources :payments, only: [ :index ]

    resources :teachers do
      resource :teacher_profile, except: [ :show ]
    end

    resources :courses do
      resources :course_sections do
        resources :lessons
      end
    end
  end

  # ================= GENERIC =================
  get "/dashboard", to: "dashboard#index"
end
