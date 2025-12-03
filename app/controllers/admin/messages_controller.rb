module Admin
  class MessagesController < ApplicationController
    before_action :require_admin

    def index
      @messages = Message.includes(:user).order(created_at: :desc).limit(1000)
    end

    private

    def require_admin
      unless current_user&.is_admin?
        redirect_to chat_path, alert: "Admin access only"
      end
    end
  end
end
