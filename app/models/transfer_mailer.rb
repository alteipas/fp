class TransferMailer < ActionMailer::Base
  def thank_notification(transfer)
    @body[:sender]=transfer.sender.to_s
    @body[:amount]=transfer.amount
    setup_email(transfer)
    @subject    += "#{@body[:sender]} has thanked you"
    @body[:url]  = "#{URL}/transfers/#{transfer.id}"
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
