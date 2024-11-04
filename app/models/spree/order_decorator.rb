Spree::Order.class_eval do

  def trigger_netsuite_update_order
    NetsuiteCancleOrderWorker.perform_async(self.id)
  end
end