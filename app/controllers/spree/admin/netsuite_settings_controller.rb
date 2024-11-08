module Spree
  class Admin::NetsuiteSettingsController < Spree::Admin::BaseController
    before_action :set_netsuite_setting

    def edit
    end

    def update
      if @netsuite_setting.update(netsuite_settings_params)
        flash[:success] = "Setting updated"
        redirect_to edit_admin_netsuite_settings_path
      else
        flash[:error] = "Setting Failed"
        render :edit
      end
    end

    private

    def set_netsuite_setting
      @netsuite_setting = Spree::NetsuiteSetting.first_or_initialize
    end


    def netsuite_settings_params
      params.require(:netsuite_setting).permit(
        :netsuite_entity_id,
        :netsuite_location_id,
        :netsuite_check_payment_method_id,
        :netsuite_online_payment_method_id,
        :active
      )
    end
  end
end
