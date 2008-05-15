class InhabitantMailer < ActionMailer::Base
  def signup_notification(inhabitant)
    @inviter=inhabitant.inviter
    setup_email(inhabitant)
    if @inviter
      @subject    += "#{@inviter} has thanked you"
    else
      @subject += "midas or error"
    end
  
    @body[:url]  = "#{URL}/token/#{inhabitant.login_by_email_token}"
  
  end
  def forgot(inhabitant)
    setup_email(inhabitant)
    @subject    += "password change"
    @body[:url]  = "#{URL}/token/#{inhabitant.login_by_email_token}"
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
