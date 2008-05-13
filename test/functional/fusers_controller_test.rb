require File.dirname(__FILE__) + '/../test_helper'
require 'fusers_controller'

# Re-raise errors caught by the controller.
class FusersController; def rescue_action(e) raise e end; end

class FusersControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper
  include PublicCurrentFuserTestHelper

  def setup
    @user1=Fuser.create(:login=>"user1",:password=>"pass",:password_confirmation=>"pass",:email=>"user1@email.com")
    @user2=Fuser.create(:login=>"user2",:password=>"pass",:password_confirmation=>"pass",:email=>"user2@email.com")
    ActionMailer::Base.deliveries = []
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
#  def test_routes
#    assert_routing "fusers", {:controller=>"fusers",:action=>"index"}
#    assert_routing "midas", {:controller=>"fusers",:action=>"show",:id=>"midas"}
#
#  end
  def test_should_get_show
    get :show, :id=>'user2'
    assert_response 200
  end
  def test_auth_only_user
    login_as('user2')
    get :test_auth, :id=>'user2', :format=>'xml'
    assert_response 200

    get :test_auth, :id=>'user1', :format=>'xml'
    assert_response 401
  end
  def test_update_url
    #xml
    login_as('user2')
    put :update, :id=>'user2', :fuser=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 200
    #html
    login_as('user2')
    put :update, :id=>'user2', :fuser=>{:url=>"http://mynewurl.com"}
    assert_redirected_to :controller=>'fusers', :action=>'show', :id=>'user2'
  end
  def test_not_update_email
    #xml
    login_as('user2')
    get :activate, :activation_code => @user2.activation_code
    put :update, :id=>'user2', :fuser=>{:email=>"newemail@server.com"}, :format=>'xml'
    assert_response 403
  end
  
  def test_weird

    #get :activate, :activation_code => @user1.activation_code
    get :activate, :activation_code => @user2.activation_code
    login_as('user2')
    put :update, :id=>'user2', :email=>'my@email33.com', :format=>'xml'
    assert_response 403

    get :activate, :activation_code => @user1.activation_code #why can't I move it to the first line??
    login_as('user1')
    put :update, :id=>'user1', :email=>'my@emailbb.com', :format=>'xml'
    assert_response 403
  end
  def test_mail
    login_as('user2')
    assert_difference 'Fuser.count' do
      create_fuser(:email => "hector@hecpeare.net")
    end
    assert !ActionMailer::Base.deliveries.empty?

  end
  def test_should_update_email_only_first_time
    login_as('user1')
    u=nil
    assert_difference 'Fuser.count' do
      create_fuser(:email => nil, :login => 'newuser')
      assert ActionMailer::Base.deliveries.empty?
      u=assigns(:fuser)
    end
    assert_equal nil,Fuser.find('newuser').email
    assert_equal nil, u.email
    @controller.current_fuser=(u) # TODO: login_as('newuser') doesn't work. Why?
    assert_equal "newuser", @controller.current_fuser.login
    put :update, :id=>'newuser', :email=>'my@email33.com', :format=>'xml'

    assert_equal "my@email33.com",Fuser.find('newuser').email
    assert_response :success

    get :activate, :activation_code => Fuser.find('newuser').activation_code

    #if email is set (activated), it can't be updated (for now).
    put :update, :id=>'newuser', :email=>'myRENEW@email33.com'
    assert_response 403
    assert_equal "my@email33.com",Fuser.find('newuser').email


  end 

#  def test_not_update_username # BUG. See note in the update method.
#    #xml
#    login_as('user2')
#    put :update, :id=>'user2', :fuser=>{:login=>"newusername"}, :format=>'xml'
#    assert_response 403
#  end

  def test_not_update_url_if_authorized_as_other_user
    login_as('user1')
    put :update, :id=>'user2', :fuser=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 401
  end
  def test_should_allow_signup
    login_as('user2')
    assert_difference 'Fuser.count' do
      create_fuser
      assert_response :redirect
    end
  end

  def test_should_signup_without_require_password
    login_as('user2')
    assert_difference 'Fuser.count' do
      create_fuser(:password => nil, :password_confiration=>nil)
    end
  end

  def test_should_require_password_confirmation_on_signup
    login_as('user2')
    assert_no_difference 'Fuser.count' do
      create_fuser(:password_confirmation => nil,:email=>nil)
      assert assigns(:fuser).errors.on(:password_confirmation)
      #assert_response :success
    end
  end

  def test_should_create_without_email
    login_as('user2')
    assert_difference 'Fuser.count' do
      create_fuser(:email => nil)
      assert_redirected_to "/fusers/user2"
    end
  end
 
  def test_login_as_from_fixtures_or_db
    login_as('user2')
    assert_difference 'Fuser.count' do
      create_fuser(:email => nil, :login => 'newuser')
    end
    login_as('newuser')
    assert_difference 'Fuser.count' do
      create_fuser
    end
  end
  
  def test_should_sign_up_user_with_activation_code
    login_as('user2')
    create_fuser
    assigns(:fuser).reload
    assert_not_nil assigns(:fuser).activation_code
  end

  def test_should_activate_user
    assert !@user1.active?
    assert Fuser.authenticate('user1', 'pass') #It isn't required activate before login (no signup, invitation or signup through other website)
    get :activate, :activation_code => Fuser.find('user1').activation_code
    assert_redirected_to "/fusers/user1/edit"
    assert_not_nil flash[:notice]
    @user1.reload
    assert @user1.active?
    assert_equal @user1, Fuser.authenticate('user1', 'pass')
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

      post :create, :fuser => {
        :login => key,
        :email => key + '@example.com',
        :password => key,
        :password_confirmation => key
      }.merge(options)
    end
end
