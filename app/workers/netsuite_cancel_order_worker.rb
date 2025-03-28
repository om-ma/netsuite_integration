class NetsuiteCancelOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Spree::Order.find_by(id: order_id)
    Spree::NetsuiteUpdateService.update(order)
  rescue => e
    Rails.logger.error("Failed to cancel order on NetSuite by admin: #{e.message}")
  end
end