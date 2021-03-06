Rails.application.routes.draw do
  
  
  root 'welcome#index'
  
  resources :solvents
  
  resources :substances do
    member do
      get :molecule
      get :new_dilution
      post :add_dilution_to_blend
    end
    collection do
      get :new_dilution
      get :suggest
      get :report
      put :refresh_elastic
    end
  end
  
  resources :blends do
    member do
      post :bottle
      post :adjust
      post :resize
      get :dilute
      get :print
      put :detach_families
    end
    collection do
      get :memorize
      put :refresh_elastic
    end
  end
  
  resources :families do
    member do
      get :add_blends
    end
  end
  
  resources :olfactive_families, controller: "olfactive_families"
  
  resource :mixing, :controller => "mixing" do
    member do
      get :new
      post :prepare
      get :prepare
      post :create
      get :update_final_concentration
    end
  end

  resources :separating do
    member do
      get :prepare
      post :create
    end
  end
  
  resource :analyzer, controller: "analyzer" do
    get :comparison
    get :new
    # put :add
    # put :remove
  end
  
  resources :notes
  
  resource :search, :controller => "search"
  
  resource :welcome, :controller => "welcome" do
    get :help
  end
  
  match "set/:key/:value", :controller => "welcome", :action => "set_session_variables", via: [:get, :post]
  
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
