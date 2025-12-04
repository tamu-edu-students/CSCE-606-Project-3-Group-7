module Admin
  class MessagesController < ApplicationController
    before_action :require_admin
    before_action :set_user_ecef

    def index
      @messages = Message.includes(:user).order(created_at: :desc).limit(1000)
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to chat_path, alert: "Admin access only"
      end
    end

    # Same ECEF calculation as ChatsController for distance calculations
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
  end
end
