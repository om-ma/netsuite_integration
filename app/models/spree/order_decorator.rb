Spree::Order.class_eval do

  def trigger_netsuite_cancel_order
    if Spree.constants.include?(:NetsuiteSetting) && Spree::NetsuiteSetting.respond_to?(:active?) && Spree::NetsuiteSetting.active?
      NetsuiteCancelOrderWorker.perform_async(self.id)
    end
  end
end