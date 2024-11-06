module Spree  
  class NetsuiteMailer < Spree::BaseMailer
    default from: 'it-group@naturesflavors.com'

    def notify_netsuite(order:)
      @order = order

      mail(to: 'test@gmail.com', subject: "[Urgent: Netsuite Item ID] Order # #{@order.number}")
    end
  end
end