class NetsuiteUpdateAdminOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Spree::Order.find(order_id)
      Spree::NetsuiteUpdateLineItemService.new.update(order)
  rescue => e
    Rails.logger.error("Failed to payment on NetSuite: #{e.message}")
  end
end