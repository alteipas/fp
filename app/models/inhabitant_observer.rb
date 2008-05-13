class InhabitantObserver < ActiveRecord::Observer
  def after_create(inhabitant)
    InhabitantMailer.deliver_signup_notification(inhabitant) if inhabitant.email
  end

  def after_save(inhabitant)
  
    #InhabitantMailer.deliver_activation(inhabitant) if inhabitant.recently_activated?
  
  end
end
