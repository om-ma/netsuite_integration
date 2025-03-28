class NetsuiteUpdatePaymentWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Spree::Order.find(order_id)
      Spree::NetsuiteUpdatePaymentService.new.update_order(order)
  rescue => e
    Rails.logger.error("Failed to payment on NetSuite: #{e.message}")
  end
end