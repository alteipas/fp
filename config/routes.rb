ActionController::Routing::Routes.draw do |map|
  map.root :controller=>"sessions", :action=>'root'
  map.test_auth '/api/test_auth/:id.xml', :controller=>'fusers', :action=>'test_auth', :format=>'xml'
  map.resources :transfers

  map.activate '/activate/:activation_code', :controller => 'fusers', :action => 'activate'
  map.signup '/signup', :controller => 'fusers', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.resource :session
  
  #map.connect ':id', :controller => 'fusers', :action => 'show', :requirements=>{:id=>/^(?!fusers)/}
  map.resources :fusers
  map.connect ':id', :controller => 'fusers', :action => 'show'
end
