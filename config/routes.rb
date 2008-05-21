ActionController::Routing::Routes.draw do |map|

  map.thank '/thank',   :controller => 'transfers', :action => 'new'
  map.resources :transfers

  map.root              :controller => 'sessions', :action => 'root'
  map.login '/login',   :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.forgot '/forgot', :controller => 'abitants', :action => 'forgot'
  map.resource :session
  
  #map.connect ':id', :controller => 'abitants', :action => 'show', :requirements=>{:id=>/^(?!abitants)/}
  map.test_auth '/api/test_auth/:id.xml',   :controller => 'abitants', :action => 'test_auth', :format =>'xml'
  map.activate '/token/:login_by_email_token', :controller => 'abitants', :action => 'activate'
  map.signup '/invite',                     :controller => 'abitants', :action => 'new'
  map.resources :abitants
  map.connect ':id',                        :controller => 'abitants', :action => 'show'
end
