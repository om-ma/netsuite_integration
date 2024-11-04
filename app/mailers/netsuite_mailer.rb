module Spree  
  class NetsuiteMailer < Spree::BaseMailer
    default from: 'it-group@naturesflavors.com'

    def notify_netsuite(order_number:, product_id:, product_name:, variant_sku:)
      @order_number = order_number
      @product_id = product_id
      @product_name = product_name
      @variant_sku = variant_sku

      mail(to: 'test@gmail.com', subject: "Urgent: Item ID Not Found from Netsuite") # Added the missing closing parenthesis here
    end
  end
end