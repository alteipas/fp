class Transfer < ActiveRecord::Base
  belongs_to :receiver,
             :class_name => "Abitant" ,
             :foreign_key => "receiver_id"
  belongs_to :sender,
             :class_name => "Abitant" ,
             :foreign_key => "sender_id"
  validates_presence_of     :sender_id, :receiver_id
  validates_numericality_of :amount, :greater_than=>0
  validate :sender_isnt_receiver
  validate_on_create :enough_favs
  before_create :substract_and_add

  def sender_isnt_receiver
    errors.add_to_base("You can't thank yourself!") if receiver == sender
  end
  
  def enough_favs
    s=self.sender
    if s && ((s.favs-self.amount) < 0) && s.login != 'midas'
      errors.add("sender", "doesn't have enough favs")
    end
  end
  def substract_and_add
    s=self.sender
    r=self.receiver
    if s and r
      s.favs=s.favs-self.amount unless s.superuser?
      r.favs=r.favs+self.amount
      if s.valid? and r.valid?
        #transaction?
        s.save
        r.save
      else
        if s.favs<0
          #errors.add("sender", "doesn't have enough favs")
        else
          errors.add_to_base("error!!")
        end
        false
      end
    else
      false
    end
  end
  def first_transfer_of_receiver?
    receiver.inputs.count == 1
  end
end
