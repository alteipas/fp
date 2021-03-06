require File.dirname(__FILE__) + '/../test_helper'

class TransfersControllerTest < Test::Unit::TestCase
 include AuthenticatedTestHelper

  def setup
    @controller = TransfersController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    login="mylogin"; pass="pass"
    @midas=Abitant.create(:login=>'midas', :email=>'midas@hecpeare.net')
    @abitant=create_abitant_and_activate(:login=>login,:password=>pass,:password_confirmation=>pass)
    @transfer=Transfer.create(:receiver=>@abitant, :sender=>@midas)
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
    login_as('mylogin')
    u=create_abitant_and_activate(:key=>'newuser')
    get :new, :receiver=>'newuser'
    assert_response :success
    #assert_not_nil assigns(:transfers)
  end

  def test_redirect_if_get_new_without_receiver
    login_as('mylogin')
    get :new
    assert_response 302
  end

  def test_redirect_if_get_new_without_login
    get :new
    assert_response 302
  end
  def test_should_create_transfer
    @abitant.favs=50 ; @abitant.save # (loged as @abitant)
    r=create_abitant_and_activate
    assert_difference('Transfer.count') do
      post :create, :transfer => {:receiver=>r}
    end
    assert_redirected_to transfer_path(assigns(:transfer))
  end
  def test_should_create_transfer_with_description
    @abitant.favs=50 ; @abitant.save # (loged as @abitant)
    r=create_abitant_and_activate
    assert_difference('Transfer.count') do
      post :create, :transfer => {:receiver=>r,:description=>"thank you!!!"}
    end
    t=assigns(:transfer)
    assert_equal "thank you!!!",t.description
    assert_redirected_to transfer_path(t)
    
  end
  def test_should_not_create_transfer_if_receiver_missing
    assert_no_difference('Transfer.count') do
      post :create, :transfer => {}
    end
  end
#  def test_should_not_create_transfer_if_no_favs
#    @abitant.reload
#    @abitant=create_abitant_and_activate
#    #assert_equal 1, Transfer.count
#    assert_equal 1, @abitant.inputs.size
#    assert_equal 1, @abitant.favs
#    assert_difference('Transfer.count') do
#      post :create, :transfer => {:receiver=>'midas'}
#      assert_equal 3, assigns(:transfer).errors
#    end
#    @abitant.reload
#    assert_equal 0, @abitant.favs
#    assert_no_difference('Transfer.count') do
#      post :create, :transfer => {:receiver=>'midas'}
#    end
#  end
  def test_should_not_create_transfer_if_receiver_is_sender
    assert_no_difference('Transfer.count') do
      post :create, :transfer => {:receiver=>@abitant}
    end
  end

  def test_should_show_transfer
    get :show, :id => @transfer.id
    assert_response :success
  end


  protected
  def create_abitant_and_activate(options = {})
    key=options[:key] || 'quire' + (10000+rand(89999)).to_s
    record = Abitant.create({ :login => key, :email => key + '@example.com', :password => key, :password_confirmation => key }.merge(options))
    record.activate
    record.reload if record.valid?
    record
  end

end
