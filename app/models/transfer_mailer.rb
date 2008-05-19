class TransferMailer < ActionMailer::Base
  def thank_notification(transfer)
    @body[:sender]=transfer.sender
    @body[:amount]=transfer.amount
    setup_email(transfer)
    @subject    += "#{@body[:sender]} has thanked you"
    if transfer.first_transfer_of_receiver?
      @body[:url]  = "#{URL}/token/#{transfer.receiver.login_by_email_token}"
    end
  end
  protected
  def setup_email(transfer)
    @recipients  = "#{transfer.receiver.email}"
    @from        = "info@favpal.org"
    @subject     = "[FavPal] "
    @sent_on     = Time.now
    @body[:transfer]=transfer
  end
end
