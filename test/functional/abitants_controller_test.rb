require File.dirname(__FILE__) + '/../test_helper'
require 'abitants_controller'

# Re-raise errors caught by the controller.
class AbitantsController; def rescue_action(e) raise e end; end

class AbitantsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper
  include PublicCurrentAbitantTestHelper

  def setup
    @controller = AbitantsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @midas=Abitant.create(:login=>"midas",:password=>"pass",:password_confirmation=>"pass",:email=>"midas@hecpeare.net")

    #TODO: create @user1 and @user2 calling create_abitant (so transfers are created automatically)
    @user1=Abitant.create(:login=>"user1",:password=>"pass",:password_confirmation=>"pass",:email=>"user1@email.com")
    @user2=Abitant.create(:login=>"user2",:password=>"pass",:password_confirmation=>"pass",:email=>"user2@email.com")
    @transfer1=Transfer.create(:sender=>@midas, :receiver=>@user1)
    @transfer2=Transfer.create(:sender=>@midas, :receiver=>@user2)

    ActionMailer::Base.deliveries = []
  end
  def set_basic_authentication(login,password) # TODO: this doesn't work. Why?
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::b64encode("#{login}:#{password}")
  end
#  def test_routes
#    assert_routing "abitants", {:controller=>"abitants",:action=>"index"}
#    assert_routing "midas", {:controller=>"abitants",:action=>"show",:id=>"midas"}
#
#  end
  def test_truth
    @user1.valid?
  end
  def test_should_get_show
    get :show, :id=>'user2'
    assert_response 200
    assert_template "abitants/show"
  end
  def test_test_auth
    set_basic_authentication('user1','pass')
    get :test_auth, :format=>'xml'
    assert_response :success
  end
  def test_should_not_auth_in_test_auth_if_no_pass

    set_basic_authentication(@user2.login,'no_pass')
    get :test_auth, :format=>'xml'
    assert_response 401
  end
  def test_test_auth_with_crypted_password
    assert @user1.authenticated?(@user1.crypted_password)
    login_as(@user1)
    
    get :test_auth, :format=>'xml'
    assert_response :success
  end
  def test_test_auth_and_return_crypted_password
    login_as('user1')
    get :test_auth, :format=>'xml'
    assert_response 200
    a=assigns(:abitant)
    assert 'user1', a.login
    assert @user1.crypted_password, a.crypted_password
  end
  def test_update_url
    #xml
    login_as('user2')
    put :update, :id=>'user2', :abitant=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 200
    #html
    login_as('user2')
    put :update, :id=>'user2', :abitant=>{:url=>"http://mynewurl.com"}
    assert_redirected_to :controller=>'abitants', :action=>'show', :id=>'user2'
  end
#  def test_find_by_email
#    a=Abitant.find("midas@hecpeare.net")
#    assert a.valid?
#  end
  def test_not_update_email
    #xml
    login_as('user2')
    get :activate, :login_by_email_token => @user2.login_by_email_token
    put :update, :id=>'user2', :abitant=>{:email=>"newemail@server.com"}, :format=>'xml'
    assert_response 403
  end
  
  def test_should_not_invite_if_no_favs
    login_as('midas')
    u=create_abitant
    assert_equal 1, u.favs
    @controller.current_abitant=(u)
    assert create_abitant.valid?
    u.reload
    assert_equal 0, u.favs
    assert !create_abitant.valid?
  end
  def test_weird

    #get :activate, :login_by_email_token => @user1.login_by_email_token
    get :activate, :login_by_email_token => @user2.login_by_email_token
    login_as('user2')
    put :update, :id=>'user2', :email=>'my@email33.com', :format=>'xml'
    assert_response 403

    get :activate, :login_by_email_token => @user1.login_by_email_token #why can't I move it to the first line??
    login_as('user1')
    put :update, :id=>'user1', :email=>'my@emailbb.com', :format=>'xml'
    assert_response 403
  end
  def test_should_not_invite_if_no_favs
    login_as('user2')
    assert_equal 1, @user2.favs
    a=create_abitant
    @user2.reload
    assert_equal 0, @user2.favs
    assert_no_difference 'Transfer.count' do
      assert_no_difference 'Abitant.count' do
        create_abitant(:email => "hector@hecpeare.net")
      end
    end
  end

  def test_mail
    login_as('user2')
    assert_difference 'Abitant.count' do
      create_abitant(:email => "hector@hecpeare.net")
    end
    assert !ActionMailer::Base.deliveries.empty?

  end
  def test_should_update_email_only_first_time
    login_as('midas')
    assert @midas.valid?
    #@controller.current_abitant=@midas
    #assert_equal @midas, @controller.current_abitant # TODO: login_as(u.login) doesn't work
    i=Abitant.create(:login=>"login",:email=>"my@email.com")
    assert_equal 0, i.favs
    u=create_abitant
    assert_equal 1, u.inputs.size
    assert_equal 1, u.favs
    @controller.current_abitant=u # TODO: login_as(u.login) doesn't work
    assert_equal u, @controller.current_abitant
    u=nil
    assert_difference 'Abitant.count' do
      u=create_abitant(:email => nil, :login => 'newuser')
    end
    #assert ActionMailer::Base.deliveries.empty?
    assert_equal nil,Abitant.find('newuser').email
    assert_equal nil, u.email
    login_as('newuser')
    @controller.current_abitant=(u) # TODO: login_as('newuser') doesn't work. Why?
    assert_equal "newuser", @controller.current_abitant.login
    put :update, :id=>'newuser', :email=>'my@email33.com', :format=>'xml'

    assert_response :success
    assert_equal "my@email33.com",Abitant.find('newuser').email

    get :activate, :login_by_email_token => Abitant.find('newuser').login_by_email_token

    #if email is set (activated), it can't be updated (for now).
    put :update, :id=>'newuser', :email=>'myRENEW@email33.com'
    assert_response 403
    assert_equal "my@email33.com",Abitant.find('newuser').email


  end 

#  def test_not_update_username # BUG. See note in the update method.
#    #xml
#    login_as('user2')
#    put :update, :id=>'user2', :abitant=>{:login=>"newusername"}, :format=>'xml'
#    assert_response 403
#  end
  def test_should_create_with_description_and_link
    login_as('user1')
    create_abitant(:link=>"http://link.com", :description=>"kkk")
    a=assigns(:abitant)
    assert a.valid?
    t=a.inputs[0]
    assert_equal t.link, "http://link.com"
    assert_equal t.description, "kkk"
  end
  def test_not_update_url_if_authorized_as_other_user
    login_as('user1')
    put :update, :id=>'user2', :abitant=>{:url=>"http://mynewurl.com"}, :format=>'xml'
    assert_response 401
  end
  def test_should_allow_signup
    login_as('user2')
    assert_difference 'Abitant.count' do
      create_abitant
      assert_response :redirect
    end
  end

  def test_should_signup_without_require_password
    login_as('user2')
    assert_difference 'Abitant.count' do
      u=create_abitant(:password => nil, :password_confiration=>nil)
    end
  end

  def test_should_require_password_confirmation_on_signup
    login_as('user2')
    assert_no_difference 'Abitant.count' do
      create_abitant(:password_confirmation => nil,:email=>nil)
    end
    assert assigns(:abitant).errors.on(:password_confirmation)
  end

  def test_should_create_without_email
    login_as('user2')
    assert_difference 'Abitant.count' do
      create_abitant(:email => nil)
      assert_redirected_to "/abitants/user2"
    end
  end
 
  def test_should_sign_up_user_with_login_by_email_token
    login_as('user2')
    create_abitant
    assigns(:abitant).reload
    assert_not_nil assigns(:abitant).login_by_email_token
  end

  def test_should_activate_user
    assert !@user1.active?
    assert Abitant.authenticate('user1', 'pass') #It isn't required activate before login (no signup, invitation or signup through other website)
    get :activate, :login_by_email_token => Abitant.find('user1').login_by_email_token
    assert_redirected_to "/abitants/user1/edit"
    assert_not_nil flash[:notice]
    @user1.reload
    assert @user1.active?
    assert_equal @user1, Abitant.authenticate('user1', 'pass')
  end
  def test_should_login_from_email
    get :activate, :login_by_email_token => @user1.login_by_email_token
    assert_redirected_to "/abitants/user1/edit"
    @user1.reload
    assert @user1.active?
    login_as(nil)
    #But if we forgot our password:
    post :forgot, :email=>@user1.email
    assert !ActionMailer::Base.deliveries.empty?
    @user1.reload
    assert @user1.login_by_email_token
    get :activate, :login_by_email_token => @user1.login_by_email_token
    assert_redirected_to "/abitants/user1/edit"
  end
#  def test_should_not_include_email_not_password_of_abitants_in_index TODO!!
#    get :index
#    assert ... assigns(:abitants)
#  end
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end
  def test_should_not_activate_user_with_blank_key
    get :activate, :login_by_email_token => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end

  protected
    def create_abitant(options = {})
      
      key='aleat' + (10000+rand(89999)).to_s unless key=options.delete(:key)

      post :create, :abitant => {
        :login => key,
        :email => key + '@example.com',
        :password => key,
        :password_confirmation => key
      }.merge(options)
      abitant=assigns(:abitant)
      transfer=assigns(:transfer)
      abitant.reload if abitant && abitant.valid? && transfer && transfer.valid?
      if abitant.valid? && abitant.id.nil?
        #the transfer errors are added in the controller, but the test assign doesn't realize, so:
        transfer.errors.each do |param,msg|
          abitant.errors.add(param,msg) unless param=="receiver_id"
        end
      end
      abitant
    end
end
