class FuserMailer < ActionMailer::Base
  def signup_notification(fuser)
    setup_email(fuser)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://localhost:3000/activate/#{fuser.activation_code}"
  
  end
  
  def activation(fuser)
    setup_email(fuser)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://localhost:3000/"
  end
  
  protected
    def setup_email(fuser)
      @recipients  = "#{fuser.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[FavPal] "
      @sent_on     = Time.now
      @body[:fuser] = fuser
    end
end
