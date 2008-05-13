class InhabitantMailer < ActionMailer::Base
  def signup_notification(inhabitant)
    setup_email(inhabitant)
    #@subject    += 'Please activate your new account'
    @subject    += '... has thanked you..' #TODO
  
    @body[:url]  = "http://localhost:3000/thanked/#{inhabitant.activation_code}"
  
  end
  
  def activation(inhabitant)
    setup_email(inhabitant)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://localhost:3000/"
  end
  
  protected
    def setup_email(inhabitant)
      @recipients  = "#{inhabitant.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[FavPal] "
      @sent_on     = Time.now
      @body[:inhabitant] = inhabitant
    end
end
