require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  #fixtures :inhabitants

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @midas=Inhabitant.create(:login=>"midas",:password=>"test",:password_confirmation=>"test",:email=>"midas@email.com")
    @inhabitant=Inhabitant.create(:login=>"inhabitant",:password=>"test",:password_confirmation=>"test",:email=>"inhabitant2@email.com")
  end

  def test_should_get_root
    get :root
    assert_response :success
  end
  def test_should_login_and_redirect
    post :create, :login => 'inhabitant', :password => 'test'
    assert session[:inhabitant_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'inhabitant', :password => 'bad password'
    assert_nil session[:inhabitant_id]
    assert_response :success
  end

  def test_should_logout
    login_as "inhabitant"
    get :destroy
    assert_nil session[:inhabitant_id]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'inhabitant', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :login => 'inhabitant', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as "inhabitant"
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    @inhabitant.remember_me
    @request.cookies["auth_token"] = cookie_for("inhabitant")
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    @inhabitant.remember_me
    @inhabitant.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for("inhabitant")
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @inhabitant.remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(inhabitant)
      auth_token Inhabitant.find(inhabitant).remember_token
    end
end
