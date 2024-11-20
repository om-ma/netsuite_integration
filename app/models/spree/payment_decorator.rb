module Spree
  module PaymentDecorator

    def trigger_netsuite_update
      if Spree.constants.include?(:NetsuiteSetting) && Spree::NetsuiteSetting.respond_to?(:active?) && Spree::NetsuiteSetting.active?
        NetsuiteUpdatePaymentWorker.perform_async(self.order.id)
      end
    end

  end
end

::Spree::Payment.prepend(Spree::PaymentDecorator)