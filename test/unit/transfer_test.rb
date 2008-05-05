require File.dirname(__FILE__) + '/../test_helper'

class TransferTest < ActiveSupport::TestCase
  def test_truth
    assert true
  end
  def test_create_transfer
    t=create_transfer
    assert t.valid?
  end
  def test_no_create_transfer_if_missing_sender_or_receiver
    t=create_transfer(:sender=>nil)
    assert !t.valid?
    t=create_transfer(:receiver=>nil)
    assert !t.valid?
  end
  def test_substract_favs_from_sender
    u=create_fuser
    u.favs=50
    u.save
    t=create_transfer(:sender=>u, :amount=>1)
    u.reload
    assert_equal 49, u.favs
  end
  def test_sender_isnt_receiver
    u=create_fuser
    t=create_transfer(:receiver=>u, :sender=>u)
    assert !t.valid?
  end
  def test_add_favs_to_receiver
    u=create_fuser
    u2=create_fuser
    favs_before=u.favs
    t=create_transfer(:receiver=>u, :sender=>u2, :amount=>1)
    u.reload
    assert_equal favs_before+1, u.favs
  end
  def test_shouldnt_add_if_sender_doesnt_have
    u=create_fuser
    u_favs_before=u.favs
    u2=create_fuser
    u2.favs=0
    u2.save
    t=create_transfer(:receiver=>u, :sender=>u2, :amount=>1)
    u.reload
    assert_equal u_favs_before, u.favs
    assert !t.valid?
  end
  def test_amount_should_be_greater_than_0
    assert !create_transfer(:amount=>0).valid?
  end
  protected
  def create_transfer(options = {})
    t=Transfer.create({:sender=>create_fuser,:receiver=>create_fuser,:amount=>1}.merge(options))
  end
  def create_fuser(options = {})
    aleat='quire' + (10000+rand(89999)).to_s
    record = Fuser.new({ :login => aleat, :email => aleat + '@example.com', :password => aleat, :password_confirmation => aleat }.merge(options))
    record.favs=50
    record.save
    record
  end

end
