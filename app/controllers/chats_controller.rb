class ChatsController < ApplicationController
  include MessageHelper
  before_action :require_login

  def index
    # Use SQL-based radius filtering from Message model
    if (params[:lat] && params[:lon]) || params[:address]
      @messages = Message.within_radius(cartesian[0],
                                        cartesian[1],
                                        cartesian[2])
      @new_message = Message.new
    else
      @messages = []
      @new_message = nil
    end
  end

  private

  def cartesian
    p = params.permit(:lat, :lon, :address)
    if p[:lat] && p[:lon]
      MessageHelper.geo_to_cartesian(p[:lat].to_f, p[:lon].to_f)
    elsif p[:address]
      MessageHelper.address_to_cartesian(p[:address])
    else
      [ nil, nil, nil ]
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to use the chat"
    end
  end
end
