ActionController::Routing::Routes.draw do |map|
  map.resources :pages
  map.home '/', :controller => "site", :action => 'index'

  map.login   '/login',  :controller => 'sessions', :action => 'new'
  map.logout  '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup  '/signup', :controller => 'users',   :action => 'new'
  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.mail_reset_code '/mail_reset_code', :controller => 'passwords', :action => 'create'
  map.reset_password '/reset_password/:activation_code', :controller => 'passwords', :action => 'edit'
  
  map.open_id_complete         'sessions', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  #map.open_id_complete_on_user 'users',    :controller => "users",    :action => "create", :requirements => { :method => :get }
  
  map.resources :users do |user|
    #user.resources :user_openids
    user.resources :lists do |list|
      list.resources :items
    end
  end
  
  map.resource :sessions

  map.admin '/admin', :controller => 'admin/dashboard', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :users,
                    :member => {:suspend => :put,
                                :unsuspend => :put,
                                :destroy => :put,
                                :purge => :delete},
                    :collection => {:mass_update => :put}
  end
end
