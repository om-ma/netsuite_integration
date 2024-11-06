module Spree  
  class NetsuiteMailer < Spree::BaseMailer
    default from: 'it-group@naturesflavors.com'

    def notify_netsuite(order:)
      @order = order

      mail(to: Rails.configuration.x.netsuite.exception_email_address, subject: "[Urgent: Netsuite Item ID] Order # #{@order.number}") # Added the missing closing parenthesis here
    end
  end
end