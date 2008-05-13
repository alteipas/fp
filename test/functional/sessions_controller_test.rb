require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  #fixtures :fusers

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @midas=Fuser.create(:login=>"midas",:password=>"test",:password_confirmation=>"test",:email=>"midas@email.com")
    @fuser=Fuser.create(:login=>"fuser",:password=>"test",:password_confirmation=>"test",:email=>"fuser2@email.com", :inviter_id=>@midas.id)
  end

  def test_should_get_root
    get :root
    assert_response :success
  end
  def test_should_login_and_redirect
    post :create, :login => 'fuser', :password => 'test'
    assert session[:fuser_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'fuser', :password => 'bad password'
    assert_nil session[:fuser_id]
    assert_response :success
  end

  def test_should_logout
    login_as "fuser"
    get :destroy
    assert_nil session[:fuser_id]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'fuser', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :login => 'fuser', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as "fuser"
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    @fuser.remember_me
    @request.cookies["auth_token"] = cookie_for("fuser")
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    @fuser.remember_me
    @fuser.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for("fuser")
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @fuser.remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(fuser)
      auth_token Fuser.find(fuser).remember_token
    end
end
