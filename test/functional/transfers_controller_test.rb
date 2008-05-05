require File.dirname(__FILE__) + '/../test_helper'

class TransfersControllerTest < Test::Unit::TestCase
 include AuthenticatedTestHelper

  def setup
    @controller = TransfersController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    login="mylogin"; pass="pass"
    @fuser=create_fuser_and_activate(:login=>login,:password=>pass,:password_confirmation=>"mypass")
    set_basic_authentication(login,pass)
  end
  def set_basic_authentication(login,password)
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::b64encode("#{login}:#{password}")
  end
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:transfers)
  end
  def test_should_get_new
    login_as('quentin')
    get :new, :receiver=>'aaron'
    assert_response :success
    #assert_not_nil assigns(:transfers)
  end

  def test_redirect_if_get_new_without_receiver
    login_as('quentin')
    get :new
    assert_response 302
  end

  def test_redirect_if_get_new_without_login
    get :new
    assert_response 302
  end
  def test_should_create_transfer
    assert_difference('Transfer.count') do
      post :create, :transfer => {:receiver=>create_fuser_and_activate}
    end
    assert_redirected_to transfer_path(assigns(:transfer))
  end
  def test_should_not_create_transfer_if_receiver_missing
    assert_no_difference('Transfer.count') do
      post :create, :transfer => {}
    end
  end
  def test_should_not_create_transfer_if_receiver_is_sender
    assert_no_difference('Transfer.count') do
      post :create, :transfer => {:receiver=>@fuser}
    end
  end

  def test_should_show_transfer
    get :show, :id => transfers(:one).id
    assert_response :success
  end


  protected
  def create_fuser_and_activate(options = {})
    aleat='quire' + (10000+rand(89999)).to_s
    record = Fuser.new({ :login => aleat, :email => aleat + '@example.com', :password => aleat, :password_confirmation => aleat }.merge(options))
    record.favs=50
    record.activate
    record.save
    record
  end

end
