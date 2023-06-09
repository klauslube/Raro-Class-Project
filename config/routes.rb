require "sidekiq/web"

Rails.application.routes.draw do
  # Routes for devise user authentication
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Authenticated routes
  authenticated :user do
    # Routes for admin user (role: admin)
    constraints(RoleConstraint.new([:admin])) do
      root to: "admin#index", as: :admin_root #TODO: implement /admin route to redirect to admin#index
      get "/admin", to: "admin#index"

      namespace :admin do
        resources :classrooms
        resources :investments, only: %i[index new create show destroy]

        # Routes for admin user (role: admin) to manage other users accounts
        resources :users, only: %i[index edit update] do
          get "/edit", to: "users#edit", as: :edit
          patch "", to: "users#update", as: :update
        end

        # Routes for admin user (role: admin) to manage his own account
        get "/edit", to: "users#edit_admin", as: :edit
        patch "/", to: "users#update_admin", as: :update
        delete "/", to: "users#destroy_admin", as: :destroy
      end
    end

    # Routes for other users (role: free, premium)
    constraints(RoleConstraint.new([:free, :premium])) do
      root to: "home#index" #TODO: implement home#index

      resources :accounts, only: %i[index]
      resources :transactions, only: %i[index show new create] do
        member do
          post :resend_email
        end
      end
      resources :user_investments
    end
  end

  # Unauthenticated routes
  unauthenticated do
    as :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end

    # All routes unauthenticated should go to root
    get "*path", to: redirect("/")

    # except for the ones below
    get "/users/password/new", to: "devise/passwords#new", as: :new_user_password_path
    get "/users/password/edit", to: "devise/passwords#edit", as: :edit_user_password_path
    patch "/users/password", to: "devise/passwords#update", as: :user_password_path
    post "/users/password", to: "devise/passwords#create"
  end
  mount Sidekiq::Web => "/sidekiq"
end
