class InhabitantMailer < ActionMailer::Base
  def signup_notification(inhabitant)
    @inviter=inhabitant.inviter
    setup_email(inhabitant)
    if @inviter
      @subject    += "#{@inviter.name} has thanked you"
    else
      @subject += "midas or error"
    end
  
    @body[:url]  = "#{URL}/thanked/#{inhabitant.activation_code}"
  
  end
  
  def activation(inhabitant)
    setup_email(inhabitant)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{URL}/"
  end
  
  protected
    def setup_email(inhabitant)
      @recipients  = "#{inhabitant.email}"
      @from        = "info@favpal.org"
      @subject     = "[FavPal] "
      @sent_on     = Time.now
      @body[:inhabitant] = inhabitant
    end
end
