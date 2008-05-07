ActionController::Routing::Routes.draw do |map|

  map.thank '/thank',   :controller => 'transfers', :action => 'new'
  map.resources :transfers

  map.root              :controller => 'sessions', :action => 'root'
  map.login '/login',   :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.resource :session
  
  #map.connect ':id', :controller => 'fusers', :action => 'show', :requirements=>{:id=>/^(?!fusers)/}
  map.test_auth '/api/test_auth/:id.xml',   :controller => 'fusers', :action => 'test_auth', :format =>'xml'
  map.activate '/thanked/:activation_code', :controller => 'fusers', :action => 'activate'
  map.signup '/invite',                     :controller => 'fusers', :action => 'new'
  map.resources :fusers
  map.connect ':id',                        :controller => 'fusers', :action => 'show'
end
