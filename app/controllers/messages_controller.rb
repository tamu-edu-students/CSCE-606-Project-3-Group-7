class MessagesController < ApplicationController
  include MessageHelper
  before_action :require_login

  def create
    @message = current_user.messages.build(message_params)

    if @message.save
      redirect_to chat_path
    else
      flash[:alert] = @message.errors.full_messages.join(", ")
      redirect_to chat_path
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to chat_path, notice: "Message deleted"
  end

  private

  def message_params
    p = params.require(:message).permit(:body, :user_id, :lat, :lon, :address)
    cartesian = if p[:lat] && p[:lon]
      MessageHelper.geo_to_cartesian(p[:lat].to_f, p[:lon].to_f)
    elsif p[:address]
      MessageHelper.address_to_cartesian(p[:address])
    else
      [ nil, nil, nil ]
    end
    Rails.logger.info("Cartesian coordinates: #{cartesian.inspect}")
    p.permit(:body, :user_id).merge(
      ecef_x: cartesian[0],
      ecef_y: cartesian[1],
      ecef_z: cartesian[2]
    )
  end

  def require_login
    unless current_user
      redirect_to root_path, alert: "Please log in to use the chat"
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
