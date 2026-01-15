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

  # ================= STUDENT =================
  namespace :student do
    get "dashboard", to: "dashboard#index"

    resources :courses, only: [] do
      resources :orders, only: [:create] do
        collection do
          get  :checkout
          post :pay
        end
      end
    end
  end

  # ================= ADMIN =================
  namespace :admin do
    get "dashboard", to: "dashboard#index"

    resources :users, only: [:index]
    resources :students, only: [:index]
    resources :payments, only: [:index]

    resources :teachers do
      resource :teacher_profile, except: [:show]
    end

    resources :courses do
      resources :course_sections do
        resources :lessons
      end
    end
  end
end
