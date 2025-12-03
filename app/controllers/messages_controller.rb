class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_user_ecef

  def create
    @message = current_user.messages.build(message_params)
    @message.ecef_x = @user_ecef_x
    @message.ecef_y = @user_ecef_y
    @message.ecef_z = @user_ecef_z

    if @message.save
      redirect_to chat_path
    else
      flash[:alert] = @message.errors.full_messages.join(", ")
      redirect_to chat_path
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def require_login
    unless current_user
      redirect_to login_path, alert: "Please log in to use the chat"
    end
  end

  # Same fake ECEF as ChatsController
  def set_user_ecef
    lat = 30.615
    lng = -96.341

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
end
