require File.dirname(__FILE__) + '/../test_helper'
require 'inhabitants_controller'

# Re-raise errors caught by the controller.
class InhabitantsController; def rescue_action(e) raise e end; end

class InhabitantsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper
  include PublicCurrentInhabitantTestHelper

  def setup
    @controller = InhabitantsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @midas=Inhabitant.create(:login=>"midas",:password=>"pass",:password_confirmation=>"pass",:email=>"midas@hecpeare.net", :inviter_id=>nil)
    @user1=Inhabitant.create(:login=>"user1",:password=>"pass",:password_confirmation=>"pass",:email=>"user1@email.com", :inviter_id=>@midas.id)
    @user2=Inhabitant.create(:login=>"user2",:password=>"pass",:password_confirmation=>"pass",:email=>"user2@email.com", :inviter_id=>@midas.id)

    ActionMailer::Base.deliveries = []
  end
  def set_basic_authentication(login,password)
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::b64encode("#{login}:#{password}")
  end
#  def test_routes
#    assert_routing "inhabitants", {:controller=>"inhabitants",:action=>"index"}
#    assert_routing "midas", {:controller=>"inhabitants",:action=>"show",:id=>"midas"}
#
#  end
  def test_truth
    @user1.valid?
  end
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
    put :update, :id=>'user2', :inhabitant=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 200
    #html
    login_as('user2')
    put :update, :id=>'user2', :inhabitant=>{:url=>"http://mynewurl.com"}
    assert_redirected_to :controller=>'inhabitants', :action=>'show', :id=>'user2'
  end
  def test_not_update_email
    #xml
    login_as('user2')
    get :activate, :activation_code => @user2.activation_code
    put :update, :id=>'user2', :inhabitant=>{:email=>"newemail@server.com"}, :format=>'xml'
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
    assert_difference 'Inhabitant.count' do
      create_inhabitant(:email => "hector@hecpeare.net")
    end
    assert !ActionMailer::Base.deliveries.empty?

  end
  def test_should_update_email_only_first_time
    login_as('user1')
    u=nil
    assert_difference 'Inhabitant.count' do
      u=create_inhabitant(:email => nil, :login => 'newuser')
      assert ActionMailer::Base.deliveries.empty?
    end
    assert_equal nil,Inhabitant.find('newuser').email
    assert_equal nil, u.email
    login_as('newuser')
    @controller.current_inhabitant=(u) # TODO: login_as('newuser') doesn't work. Why?
    assert_equal "newuser", @controller.current_inhabitant.login
    put :update, :id=>'newuser', :email=>'my@email33.com', :format=>'xml'

    assert_response :success
    assert_equal "my@email33.com",Inhabitant.find('newuser').email

    get :activate, :activation_code => Inhabitant.find('newuser').activation_code

    #if email is set (activated), it can't be updated (for now).
    put :update, :id=>'newuser', :email=>'myRENEW@email33.com'
    assert_response 403
    assert_equal "my@email33.com",Inhabitant.find('newuser').email


  end 

#  def test_not_update_username # BUG. See note in the update method.
#    #xml
#    login_as('user2')
#    put :update, :id=>'user2', :inhabitant=>{:login=>"newusername"}, :format=>'xml'
#    assert_response 403
#  end

  def test_not_update_url_if_authorized_as_other_user
    login_as('user1')
    put :update, :id=>'user2', :inhabitant=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 401
  end
  def test_should_allow_signup
    login_as('user2')
    assert_difference 'Inhabitant.count' do
      create_inhabitant
      assert_response :redirect
    end
  end

  def test_should_signup_without_require_password
    login_as('user2')
    assert_difference 'Inhabitant.count' do
      create_inhabitant(:password => nil, :password_confiration=>nil)
    end
  end

  def test_should_require_password_confirmation_on_signup
    login_as('user2')
    assert_no_difference 'Inhabitant.count' do
      create_inhabitant(:password_confirmation => nil,:email=>nil)
    end
    assert assigns(:inhabitant).errors.on(:password_confirmation)
  end

  def test_should_create_without_email
    login_as('user2')
    assert_difference 'Inhabitant.count' do
      create_inhabitant(:email => nil)
      assert_redirected_to "/inhabitants/user2"
    end
  end
 
  def test_should_sign_up_user_with_activation_code
    login_as('user2')
    create_inhabitant
    assigns(:inhabitant).reload
    assert_not_nil assigns(:inhabitant).activation_code
  end

  def test_should_activate_user
    assert !@user1.active?
    assert Inhabitant.authenticate('user1', 'pass') #It isn't required activate before login (no signup, invitation or signup through other website)
    get :activate, :activation_code => Inhabitant.find('user1').activation_code
    assert_redirected_to "/inhabitants/user1/edit"
    assert_not_nil flash[:notice]
    @user1.reload
    assert @user1.active?
    assert_equal @user1, Inhabitant.authenticate('user1', 'pass')
  end
  def test_nn
    login_as(@user1)
    assert_no_difference 'Inhabitant.count' do
      create_inhabitant(:invitation_favs=>0)
    end
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
    def create_inhabitant(options = {})
      
      key='aleat' + (10000+rand(89999)).to_s unless key=options.delete(:key)

      post :create, :inhabitant => {
        :login => key,
        :email => key + '@example.com',
        :password => key,
        :password_confirmation => key
      }.merge(options)
      inhabitant=assigns(:inhabitant)
      inhabitant.reload if inhabitant && inhabitant.valid?
      inhabitant
    end
end
