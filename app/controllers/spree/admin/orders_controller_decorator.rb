module Spree
  module Admin
    OrdersController.class_eval do

      before_action :load_order, only: %i[
        create_netsuite_order
      ]

      after_action :update_order_on_netsuite, only: :cancel

      def update_order_on_netsuite
        @order.trigger_netsuite_update_order
      end

      def create_netsuite_order
        NetsuiteAdminOrderWorker.perform_async(params[:id])
      end
    end
  end
end