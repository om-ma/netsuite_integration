class NetsuiteCreateOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Spree::Order.find(order_id)
    Spree::NetsuiteApiService.create(order)
  rescue => e
    Rails.logger.error("Failed to create order on NetSuite: #{e.message}")
  end
end