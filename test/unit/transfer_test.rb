require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  def setup
    @midas=Inhabitant.create(:login=>"midas",:password=>"pass",:password_confirmation=>"pass",:email=>"midas@hecpeare.net")
    @user1=create_inhabitant(:login=>"user1")
    @user2=create_inhabitant(:login=>"user2")
 
 
  end
  def test_first_transfer_of_receiver?
    t=Transfer.create(:receiver=>@user1, :sender=>@midas)
    assert t.first_transfer_of_receiver?
    Transfer.create(:receiver=>@user1, :sender=>@midas)
    assert !t.first_transfer_of_receiver?

  end
  def test_truth
    assert true
  end
  def test_create_transfer
    assert_difference 'Transfer.count' do
      t=create_transfer
    end
  end
  def test_no_create_transfer_if_missing_sender_or_receiver
    t=create_transfer(:sender=>nil)
    assert !t.valid?
    t=create_transfer(:receiver=>nil)
    assert !t.valid?
  end
  def test_substract_favs_from_sender
    u=create_inhabitant
    u.favs=50
    u.save
    t=create_transfer(:sender=>u, :amount=>1)
    u.reload
    assert_equal 49, u.favs
  end
  def test_sender_isnt_receiver
    u=create_inhabitant
    t=create_transfer(:receiver=>u, :sender=>u)
    assert !t.valid?
  end
  def test_add_favs_to_receiver
    u=create_inhabitant
    u2=create_inhabitant
    assert_equal 0, u.favs
    assert_equal 0, u2.favs
    t=create_transfer(:receiver=>u, :sender=>@midas, :amount=>1)
    assert_equal 1, u.favs
    t=create_transfer(:receiver=>u2, :sender=>u, :amount=>1)
    assert_equal 0, u.favs
    assert_equal 1, u2.favs
  end
  def test_shouldnt_add_if_sender_doesnt_have
    u=create_inhabitant
    u2=create_inhabitant
    assert_equal 0, u.favs
    assert_equal 0, u2.favs

    t=create_transfer(:receiver=>u2, :sender=>u, :amount=>1)
    assert !t.valid?
  end
  def test_amount_should_be_greater_than_0
    assert !create_transfer(:amount=>0).valid?
  end
  protected
  def create_transfer(options = {})
    t=Transfer.create({:sender=>@midas,:receiver=>@user1,:amount=>1}.merge(options))
  end
  def create_inhabitant(options = {})
    aleat='quire' + (10000+rand(89999)).to_s
    record = Inhabitant.create({ :login => aleat, :email => aleat + '@example.com', :password => aleat, :password_confirmation => aleat, :amount=>50}.merge(options))
    record.reload if record.valid?
    record
  end

end
