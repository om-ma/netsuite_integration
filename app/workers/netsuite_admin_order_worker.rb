class NetsuiteAdminOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Spree::Order.find_by(number: order_id)
    Spree::NetsuiteApiService.create(order)
  rescue => e
    Rails.logger.error("Failed to create order on NetSuite by admin: #{e.message}")
  end
end