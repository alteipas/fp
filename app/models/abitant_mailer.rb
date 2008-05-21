class AbitantMailer < ActionMailer::Base
  def forgot(abitant)
    setup_email(abitant)
    @subject    += "password change"
    @body[:url]  = "#{URL}/token/#{abitant.login_by_email_token}"
  end
  
  protected
  def setup_email(abitant)
    @recipients  = "#{abitant.email}"
    @from        = "info@favpal.org"
    @subject     = "[FavPal] "
    @sent_on     = Time.now
    @body[:abitant] = abitant
  end
end
