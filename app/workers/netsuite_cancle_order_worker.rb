class NetsuiteAdminOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Spree::Order.find(order_id)
   Spree::NetsuiteUpdateService.update(order)
  end  
  rescue => e
    Rails.logger.error("Failed to cancel order on NetSuite by admin: #{e.message}")
  end
end