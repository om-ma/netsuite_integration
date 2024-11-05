Spree::Order.class_eval do

  def trigger_netsuite_update_order
    NetsuiteCancelOrderWorker.perform_async(self.id)
  end
end