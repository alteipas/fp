ActionController::Routing::Routes.draw do |map|

  map.thank '/thank',   :controller => 'transfers', :action => 'new'
  map.resources :transfers

  map.root              :controller => 'sessions', :action => 'root'
  map.forgot '/forgot', :controller => 'abitants', :action => 'forgot'
  map.with_options :controller => "sessions" do |page|
    page.login '/login', :action => 'new'
    page.logout '/logout', :action => 'destroy'
  end
  map.resource :session
  
  #map.connect ':id', :controller => 'abitants', :action => 'show', :requirements=>{:id=>/^(?!abitants)/}
  map.test_auth '/abitants/test_auth.xml',   :controller => 'abitants', :action => 'test_auth', :format =>'xml'
  map.activate '/token/:login_by_email_token', :controller => 'abitants', :action => 'activate'
  map.signup '/invite',                     :controller => 'abitants', :action => 'new'
  map.resources :abitants
  map.connect ':id',                        :controller => 'abitants', :action => 'show'
end
