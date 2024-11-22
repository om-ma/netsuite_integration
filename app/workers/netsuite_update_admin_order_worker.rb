class NetsuiteUpdateAdminOrderWorker
  include Sidekiq::Worker

  def perform(order_id, line_item_ids)
    Spree::NetsuiteUpdateLineItemService.new.update(order_id, line_item_ids)
  rescue => e
    Rails.logger.error("Failed to payment on NetSuite: #{e.message}")
  end
end