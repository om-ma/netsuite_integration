module Spree
  module Admin
    OrdersController.class_eval do

      after_action :need_to_update_on_netsuite, only: %i[edit]
      before_action :load_order, only: %i[ create_netsuite_order ]
      after_action :update_order_on_netsuite, only: :cancel

      def update_order_on_netsuite
        @order.trigger_netsuite_cancel_order
      end

      def need_to_update_on_netsuite
        if defined?(ActiveRecord::Base.connected_to) && ActiveRecord::Base.respond_to?(:connected_to)
          ActiveRecord::Base.connected_to(role: :writing) do
            @order.update(is_updated_on_netsuite: false)
          end
        else
          @order.update(is_updated_on_netsuite: false)
        end
      end

      def create_netsuite_order
        if defined?(Spree::NetsuiteSetting) && Spree::NetsuiteSetting.respond_to?(:active?) && Spree::NetsuiteSetting.active?
          order = Spree::Order.find_by(number: params[:id])
          NetsuiteAdminOrderWorker.perform_async(order.id)
          redirect_to edit_admin_order_path(order)
        end
      end
    end
  end
end