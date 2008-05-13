require File.dirname(__FILE__) + '/../test_helper'

class InhabitantTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  #fixtures :inhabitants
  def setup
    @midas=Inhabitant.create(:login=>"midas",:password=>"pass",:password_confirmation=>"pass",:email=>"midas@hecpeare.net")
    @user1=create_inhabitant(:login=>"user1")
    @user2=create_inhabitant(:login=>"user2",:password=>"pass",:password_confirmation=>"pass")
 
  end
  def test_to_xml_include_login_and_favs
    inhabitant=create_inhabitant
    assert inhabitant.valid?
    %w(login id favs).each{|n| assert inhabitant.to_xml.include?(n)}
  end
  def test_to_xml_no_include_email
    inhabitant=create_inhabitant
    assert inhabitant.valid?
    assert !inhabitant.to_xml.include?("<email>")
  end
  def test_shouldnt_save_user_if_negative_favs
    user=create_inhabitant
    assert user.valid?
    user.favs=-50
    user.save
    assert !user.valid?
  end

  def test_should_create_inhabitant
    assert_difference 'Inhabitant.count' do
      user = create_inhabitant
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_inhabitant
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_create_without_login
    assert_difference 'Inhabitant.count' do
      u = create_inhabitant(:login => nil)
      #assert u.errors.on(:login)
    end
  end

  def test_should_require_password_if_no_email
    assert_no_difference 'Inhabitant.count' do
      u = create_inhabitant(:password => nil, :email=>nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Inhabitant.count' do
      u = create_inhabitant(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_create_without_email
    assert_difference 'Inhabitant.count' do
      u = create_inhabitant(:email=>nil)
    end
  end

  def test_should_create_transfer_by_inviter
    @user1.favs=50
    assert @user1.save
    u=nil
  
    assert_difference 'Transfer.count' do
      u = create_inhabitant(:inviter_id=>@user1.id)
    end
    assert u
    assert_equal 1,u.favs
    @user1.reload
    assert_equal 49,@user1.favs
    u2 = create_inhabitant(:inviter_id=>@user1.id, :invitation_amount=>5)
    assert_equal 5,u2.favs
    @user1.reload
    assert_equal 44,@user1.favs
  end
  def test_not_create_transfer_if_inviter_no_favs
    @user1.favs=0
    @user1.save
    u=nil
    assert_no_difference 'Transfer.count' do
      u = create_inhabitant(:inviter_id=>@user1.id)
    end
    assert !u.valid?

    @user1.favs=4
    @user1.save
    assert_no_difference 'Transfer.count' do
      u = create_inhabitant(:inviter_id=>@user1.id, :invitation_amount=>5)
    end
    assert !u.valid?
 
  end
  def test_should_reset_password
    #@user2.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    u=create_inhabitant
    u.activate
    u.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal u, Inhabitant.authenticate(u.login, 'new password')
  end

  def test_should_not_rehash_password
    #@user2.update_attributes(:login => 'user22') #it seems login isn't updated
    u=create_inhabitant(:password=>"test", :password_confirmation=>"test")
    login='newlogin'
    u.activate
    u.update_attributes(:login => login)
    assert_equal u, Inhabitant.authenticate('newlogin', 'test')
  end

  def test_should_authenticate_user
    assert_equal @user2, Inhabitant.authenticate('user2', 'pass')
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
  def create_inhabitant(options = {})
    aleat='aleat' + (10000+rand(89999)).to_s
    record = Inhabitant.create({ :login => aleat, :email => aleat + '@example.com', :password => aleat, :password_confirmation => aleat, :inviter_id=>Inhabitant.find('midas').id }.merge(options))
    record.reload if record.valid?
    record.favs=options['favs'] if options['favs']
    record.save
    record
  end
end
