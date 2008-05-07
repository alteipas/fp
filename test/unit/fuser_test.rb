require File.dirname(__FILE__) + '/../test_helper'

class FuserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  #fixtures :fusers
  def setup
    @aaron=Fuser.create(:login=>"aaron",:password=>"pass",:password_confirmation=>"pass",:email=>"aaron@email.com")
    @quentin=Fuser.create(:login=>"quentin",:password=>"pass",:password_confirmation=>"pass",:email=>"quentin2@email.com")
 
  end
  def test_to_xml_include_login_and_favs
    fuser=create_fuser
    assert fuser.valid?
    %w(login id favs).each{|n| assert fuser.to_xml.include?(n)}
  end
  def test_to_xml_no_include_email
    fuser=create_fuser
    assert fuser.valid?
    assert !fuser.to_xml.include?("<email>")
  end
  def test_cero_default_favs
    assert_equal 0, create_fuser(:favs=>0).favs
  end
  def test_shouldnt_save_user_if_negative_favs
    user=create_fuser
    assert user.valid?
    user.favs=-50
    user.save
    assert !user.valid?
  end

  def test_should_create_fuser
    assert_difference 'Fuser.count' do
      user = create_fuser
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_fuser
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_not_require_login
    assert_difference 'Fuser.count' do
      u = create_fuser(:login => nil)
      #assert u.errors.on(:login)
    end
  end
  def test_should_require_password_if_no_email
    assert_no_difference 'Fuser.count' do
      u = create_fuser(:password => nil, :email=>nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Fuser.count' do
      u = create_fuser(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_create_without_email
    assert_difference 'Fuser.count' do
      u = create_fuser(:email => nil)
    end
  end

  def test_should_reset_password
    #@quentin.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    u=create_fuser
    u.activate
    u.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal u, Fuser.authenticate(u.login, 'new password')
  end

  def test_should_not_rehash_password
    #@quentin.update_attributes(:login => 'quentin2') #it seems login isn't updated
    u=create_fuser(:password=>"test", :password_confirmation=>"test")
    login='newlogin'
    u.activate
    u.update_attributes(:login => login)
    assert_equal u, Fuser.authenticate('newlogin', 'test')
  end

  def test_should_authenticate_user
    assert_equal @quentin, Fuser.authenticate('quentin', 'pass')
  end

  def test_should_set_remember_token
    @quentin.remember_me
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
  end

  def test_should_unset_remember_token
    @quentin.remember_me
    assert_not_nil @quentin.remember_token
    @quentin.forget_me
    assert_nil @quentin.remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    @quentin.remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
    assert @quentin.remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    @quentin.remember_me_until time
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
    assert_equal @quentin.remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    @quentin.remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
    assert @quentin.remember_token_expires_at.between?(before, after)
  end

protected
  def create_fuser(options = {})
    aleat='quire' + (10000+rand(89999)).to_s
    record = Fuser.new({ :login => aleat, :email => aleat + '@example.com', :password => aleat, :password_confirmation => aleat }.merge(options))
    record.favs=options['favs'] || 0
    record.save
    record
  end
end
