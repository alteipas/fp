class FuserObserver < ActiveRecord::Observer
  def after_create(fuser)
    FuserMailer.deliver_signup_notification(fuser) if fuser.email
  end

  def after_save(fuser)
  
    #FuserMailer.deliver_activation(fuser) if fuser.recently_activated?
  
  end
end
