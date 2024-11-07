Spree::Admin::PaymentsController.class_eval do

  def fire
    return unless event = params[:e] and @payment.payment_source

    # Because we have a transition method also called void, we do this to avoid conflicts.
    event = 'void_transaction' if event == 'void'
    
    if @payment.send("#{event}!")
      flash[:success] = Spree.t(:payment_updated)
      update_payment_on_netsuite(@payment, event)
    else
      flash[:error] = Spree.t(:cannot_perform_operation)
    end
  rescue Spree::Core::GatewayError => ge
    flash[:error] = ge.message.to_s
  ensure
    redirect_to spree.admin_order_payments_path(@order)
  end

  def update_payment_on_netsuite(payment,event)
    if (event == "capture") && (@payment.payment_source.type == "Spree::PaymentMethod::Check")
      payment.trigger_netsuite_update
    end
  end

end
