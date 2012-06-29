SitesUsage::Application.routes.draw do

  resources :sessions, :only => [:new, :create, :destroy]

  resources :users, :except => [:show]
  
  resources :sites, :except => [:show]
  
  resources :clients, :only => [:index, :update, :destroy]
  
  resources :departments do 
    resources :sites, :only => [:show]
    member do
      match 'sites', :to => redirect("/sites")
    end
  end
  
  match '/departments/:department_id/sites/*sites', :to => 'sites#show'
  match '/sites/refresh/*sites', :to => 'sites#refresh'
  match '/sites/popup/:id', :to => 'sites#popup'
  
  match '/api', :to => 'api#index'
  match '/api/counts/:id', :to => 'api#counts'
  match '/api/info', :to => 'api#info'
  match '/api/*sites', :to => 'api#sites', :as => 'api_site'
  
  match '/login', :to => 'sessions#new'
  match '/logout', :to => 'sessions#destroy'
  match '/stats', :to => 'stats#index'
  match '/logs', :to => 'logs#index'
  match '/clients', :to => 'clients#index'
  
  post '/stats/show', :to => 'stats#show'
  get '/stats/show', :to => 'stats#show'
  
  root :to => 'departments#index'
  post 'clients/upload'
end
