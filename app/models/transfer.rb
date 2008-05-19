class Transfer < ActiveRecord::Base
  belongs_to :receiver,
             :class_name => "Inhabitant" ,
             :foreign_key => "receiver_id"
  belongs_to :sender,
             :class_name => "Inhabitant" ,
             :foreign_key => "sender_id"
  validates_presence_of     :sender_id, :receiver_id
  validates_numericality_of :amount, :greater_than=>0
  validate :sender_isnt_receiver
  validate :substract_and_add_ok?
  before_create :substract_and_add

  def sender_isnt_receiver
    errors.add_to_base("You can't thank yourself!") if receiver == sender
  end
  def substract_and_add
    if sender && sender.valid? && receiver && receiver.valid?
      #transaction?
      sender.save
      receiver.save
    end
  end
  def substract_and_add_ok? #add and substract in validate! TODO: Do it properly! How?
    s=self.sender
    r=self.receiver
    if s and r
      s.favs=s.favs-self.amount unless s.superuser?
      r.favs=r.favs+self.amount
      if s.valid? and r.valid?
        #transaction?
#        s.save
#        r.save
      else
        if s.favs<0
          errors.add_to_base("sender doesn't have enough favs")
        else
          errors.add_to_base("error!!")
        end
      end
    end
  end
  def first_transfer_of_receiver?
    receiver.inputs.count == 1
  end
end
