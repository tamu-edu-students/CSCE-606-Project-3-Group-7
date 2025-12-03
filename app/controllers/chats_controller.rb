class ChatsController < ApplicationController
  before_action :require_login
  before_action :set_user_ecef

  def index
    # Use SQL-based radius filtering from Message model
    @messages = Message.within_radius(@user_ecef_x, @user_ecef_y, @user_ecef_z)
    @new_message = Message.new
  end

  private

  # Fake user location until Feature 2 is implemented
  def set_user_ecef
    lat = 30.615   # TAMU latitude (hardcoded for now)
    lng = -96.341  # TAMU longitude

    rad_lat = lat * Math::PI / 180
    rad_lng = lng * Math::PI / 180

    a = 6378137.0
    e_sq = 6.69437999014e-3
    n = a / Math.sqrt(1 - e_sq * Math.sin(rad_lat)**2)

    @user_ecef_x = n * Math.cos(rad_lat) * Math.cos(rad_lng)
    @user_ecef_y = n * Math.cos(rad_lat) * Math.sin(rad_lng)
    @user_ecef_z = n * (1 - e_sq) * Math.sin(rad_lat)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    unless current_user
      redirect_to login_path, alert: "Please log in to use the chat"
    end
  end
end
