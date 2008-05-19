class InhabitantMailer < ActionMailer::Base
  def forgot(inhabitant)
    setup_email(inhabitant)
    @subject    += "password change"
    @body[:url]  = "#{URL}/token/#{inhabitant.login_by_email_token}"
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
