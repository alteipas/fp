require File.dirname(__FILE__) + '/../test_helper'

class AbitantTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  #fixtures :abitants
  def setup
    @midas=Abitant.create(:login=>"midas",:password=>"pass",:password_confirmation=>"pass",:email=>"midas@hecpeare.net")
    @user1=create_abitant(:login=>"user1")
    @user2=create_abitant(:login=>"user2",:password=>"pass",:password_confirmation=>"pass")
 
  end
  def test_should_not_create_abitant_if_login_includes_dots
    u=create_abitant(:login=>"hecpeare.net")
    assert !u.valid?
  end
  def test_login_not_number
    u=create_abitant(:login=>"3366")
    assert !u.valid?
  end
  def test_find_by_email
    create_abitant(:email=>"my@email.com")
    assert Abitant.find("my@email.com")
  end
  def test_to_xml_include_login_and_favs
    abitant=create_abitant
    assert abitant.valid?
    %w(login id favs).each{|n| assert abitant.to_xml.include?(n)}
  end
  def test_to_xml_no_include_email
    abitant=create_abitant
    assert abitant.valid?
    assert !abitant.to_xml.include?("<email>")
  end
  def test_shouldnt_save_user_if_negative_favs
    user=create_abitant
    assert user.valid?
    user.favs=-50
    user.save
    assert !user.valid?
  end
  def test_generated_wealth
    assert_equal 0, @user1.generated_wealth
    Transfer.create(:sender=>@midas,:receiver=>@user1,:amount=>500)
    Transfer.create(:sender=>@user1,:receiver=>@user2,:amount=>50)
    assert_equal 50, @user1.generated_wealth
    Transfer.create(:sender=>@user1,:receiver=>@user2,:amount=>200)
    assert_equal 250, @user1.generated_wealth
  end

  def test_should_create_abitant
    assert_difference 'Abitant.count' do
      user = create_abitant
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_login_by_email_token_upon_creation
    user = create_abitant
    user.reload
    assert_not_nil user.login_by_email_token
  end

  def test_should_create_without_login
    assert_difference 'Abitant.count' do
      u = create_abitant(:login => nil)
      #assert u.errors.on(:login)
    end
  end

  def test_should_require_password_if_no_email
    assert_no_difference 'Abitant.count' do
      u = create_abitant(:password => nil, :email=>nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Abitant.count' do
      u = create_abitant(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_create_without_email
    assert_difference 'Abitant.count' do
      u = create_abitant(:email=>nil)
    end
  end

  def test_should_reset_password
    #@user2.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    u=create_abitant
    u.activate
    u.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal u, Abitant.authenticate(u.login, 'new password')
  end

  def test_should_not_rehash_password
    #@user2.update_attributes(:login => 'user22') #it seems login isn't updated
    u=create_abitant(:password=>"test", :password_confirmation=>"test")
    login='newlogin'
    u.activate
    u.update_attributes(:login => login)
    assert_equal u, Abitant.authenticate('newlogin', 'test')
  end

  def test_should_authenticate_user
    assert_equal @user2, Abitant.authenticate('user2', 'pass')
  end

  def test_should_set_remember_token
    @user2.remember_me
    assert_not_nil @user2.remember_token
    assert_not_nil @user2.remember_token_expires_at
  end

  def test_should_unset_remember_token
    @user2.remember_me
    assert_not_nil @user2.remember_token
    @user2.forget_me
    assert_nil @user2.remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    @user2.remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil @user2.remember_token
    assert_not_nil @user2.remember_token_expires_at
    assert @user2.remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    @user2.remember_me_until time
    assert_not_nil @user2.remember_token
    assert_not_nil @user2.remember_token_expires_at
    assert_equal @user2.remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    @user2.remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil @user2.remember_token
    assert_not_nil @user2.remember_token_expires_at
    assert @user2.remember_token_expires_at.between?(before, after)
  end

protected
  def create_abitant(options = {})
    aleat='aleat' + (10000+rand(89999)).to_s
    record = Abitant.create({ :login => aleat, :email => aleat + '@example.com', :password => aleat, :password_confirmation => aleat}.merge(options))
    record.reload if record.valid?
    record.favs=options['favs'] if options['favs']
    record.save
    record
  end
end
