module Spree  
  class NetsuiteMailer < Spree::BaseMailer
    default from: 'it-group@naturesflavors.com'

    def notify_netsuite(order:)
      @order = order
      
      # Fetch the first NetsuiteSetting record
      current_netsuite_setting = Spree::NetsuiteSetting.first
      
      # Safely retrieve exception_email_addresses as an array
      recipients = Array(current_netsuite_setting&.exception_email_addresses).reject(&:blank?)
      
      # Ensure there are recipients before sending the email
      if recipients.any?
        mail(to: recipients, subject: "[Urgent: Netsuite Item ID] Order ##{@order.number}")
      else
        Rails.logger.warn "No recipients configured for Netsuite notifications."
      end
    end
  end
end
