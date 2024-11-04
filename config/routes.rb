Spree::Core::Engine.add_routes do

  Spree::Core::Engine.routes.draw do
    namespace :admin, path: Spree.admin_path do
      resources :orders, except: [:show] do
        post :create_netsuite_order, on: :member
      end
    end
  end
end
