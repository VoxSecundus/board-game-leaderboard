class SettingsController < ApplicationController
  def show
    @setting = AppSetting.instance
    @players = Player.order(:name)
  end

  def update
    @setting = AppSetting.instance
    if @setting.update(setting_params)
      redirect_to settings_path, notice: "Settings saved."
    else
      @players = Player.order(:name)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:app_setting).permit(default_player_ids: [])
  end
end
