class Transfer < ActiveRecord::Base
  belongs_to :receiver,
             :class_name => "Fuser" ,
             :foreign_key => "receiver_id"
  belongs_to :sender,
             :class_name => "Fuser" ,
             :foreign_key => "sender_id"
  validates_presence_of     :sender_id, :receiver_id
  validates_numericality_of :amount, :greater_than=>0
  validate :sender_isnt_receiver
  validate :substract_and_add_ok #before_create :substract_and_add

  def sender_isnt_receiver
    errors.add_to_base("You can't thank yourself!") if receiver == sender
  end
#  def self.new(*params)
#    File.open("debug","w"){|f| f.puts params.inspect}
#    sender=params[0][:sender]
#    if sender && (sender.class==String or sender.class==Fixnum)
#      params[0][:sender]=Fuser.find(sender)
#    end
#    super(*params)
#  end
  def substract_and_add_ok
    s=self.sender
    r=self.receiver
    if s and r
      s.favs=s.favs-self.amount
      r.favs=r.favs+self.amount
      if s.valid? and r.valid?
        #transaction?
        s.save
        r.save
      else
        if s.favs<0
          errors.add_to_base("sender hasn't enough favs")
        else
          errors.add_to_base("error!!")
        end
      end
    end
  end

 
end
