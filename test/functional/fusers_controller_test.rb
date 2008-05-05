require File.dirname(__FILE__) + '/../test_helper'
require 'fusers_controller'

# Re-raise errors caught by the controller.
class FusersController; def rescue_action(e) raise e end; end

class FusersControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :fusers

  def setup
    @controller = FusersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #login="midas"; pass="pass"
    #@user=User.create(:login=>login,:password=>pass,:password_confirmation=>pass,:email=>"my@email.com")
    #set_basic_authentication(login,pass)
  end
  def set_basic_authentication(login,password)
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::b64encode("#{login}:#{password}")
  end
  def test_routes
    assert_routing "fusers", {:controller=>"fusers",:action=>"index"}
    assert_routing "midas", {:controller=>"fusers",:action=>"show",:id=>"midas"}

  end
  def test_should_get_show
    get :show, :id=>'quentin'
    assert_response 200
  end
  def test_auth_only_user

    authorize_as('quentin')
    get :test_auth, :id=>'quentin', :format=>'xml'
    assert_response 200

    get :test_auth, :id=>'aaron', :format=>'xml'
    assert_response 401
  end
  def test_update_url
    #xml
    authorize_as('quentin')
    put :update, :id=>'quentin', :fuser=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 200
    #html
    login_as('quentin')
    put :update, :id=>'quentin', :fuser=>{:url=>"http://mynewurl.com"}
    assert_redirected_to :controller=>'fusers', :action=>'show', :id=>'quentin'
  end
  def test_not_update_email
    #xml
    authorize_as('quentin')
    put :update, :id=>'quentin', :fuser=>{:email=>"newemail@server.com"}, :format=>'xml'
    assert_response 403
  end

#  def test_not_update_username # BUG. See note in the update method.
#    #xml
#    authorize_as('quentin')
#    put :update, :id=>'quentin', :fuser=>{:login=>"newusername"}, :format=>'xml'
#    assert_response 403
#  end

  def test_not_update_url_if_authorized_as_other_user
    authorize_as('aaron')
    put :update, :id=>'quentin', :fuser=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 401
  end
  def test_should_allow_signup
    assert_difference 'Fuser.count' do
      create_fuser
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'Fuser.count' do
      create_fuser(:login => nil)
      assert assigns(:fuser).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'Fuser.count' do
      create_fuser(:password => nil)
      assert assigns(:fuser).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'Fuser.count' do
      create_fuser(:password_confirmation => nil)
      assert assigns(:fuser).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'Fuser.count' do
      create_fuser(:email => nil)
      assert assigns(:fuser).errors.on(:email)
      assert_response :success
    end
  end
  

  
  def test_should_sign_up_user_with_activation_code
    create_fuser
    assigns(:fuser).reload
    assert_not_nil assigns(:fuser).activation_code
  end

  def test_should_activate_user
    assert_nil Fuser.authenticate('aaron', 'test')
    get :activate, :activation_code => fusers(:aaron).activation_code
    assert_redirected_to '/'
    assert_not_nil flash[:notice]
    assert_equal fusers(:aaron), Fuser.authenticate('aaron', 'test')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end

  protected
    def create_fuser(options = {})
      
      key='quire' + (10000+rand(89999)).to_s unless key=options.delete(:key)

      post :create, :fuser => { :login => key, :email => key + '@example.com',
        :password => key, :password_confirmation => key }.merge(options)
    end
end
