class TransferObserver < ActiveRecord::Observer
  def after_create(transfer)
    TransferMailer.deliver_thank_notification(transfer) if transfer.receiver.email
  end
end
