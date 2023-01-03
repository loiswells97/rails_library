class SettingsController < ApplicationController

  def edit
    @current_settings = cookies
  end

  def update
    cookies[:recent_duration] = settings_params[:recent_duration]
    cookies[:reread_wait] = settings_params[:reread_wait]
    cookies[:rogue_wait] = settings_params[:rogue_wait]
    session[:return_to] ||= request.referer
    redirect_route = params[:previous_request] == '' ? books_path : params[:previous_request]
    redirect_to redirect_route
  end

  private
    def settings_params
      params.require(:settings).permit(
        :recent_duration,
        :reread_wait,
        :rogue_wait,
        :previous_request
      )
    end

end
