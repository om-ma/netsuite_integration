module Spree
  module PaymentDecorator

    def trigger_netsuite_update
      NetsuiteUpdatePaymentWorker.perform_async(self.order.id)
    end

  end
end

::Spree::Payment.prepend(Spree::PaymentDecorator)