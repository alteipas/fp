ActionController::Routing::Routes.draw do |map|

  map.thank '/thank',   :controller => 'transfers', :action => 'new'
  map.resources :transfers

  map.root              :controller => 'sessions', :action => 'root'
  map.login '/login',   :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.forgot '/forgot', :controller => 'inhabitants', :action => 'forgot'
  map.resource :session
  
  #map.connect ':id', :controller => 'inhabitants', :action => 'show', :requirements=>{:id=>/^(?!inhabitants)/}
  map.test_auth '/api/test_auth/:id.xml',   :controller => 'inhabitants', :action => 'test_auth', :format =>'xml'
  map.activate '/token/:login_by_email_token', :controller => 'inhabitants', :action => 'activate'
  map.signup '/invite',                     :controller => 'inhabitants', :action => 'new'
  map.resources :inhabitants
  map.connect ':id',                        :controller => 'inhabitants', :action => 'show'
end
