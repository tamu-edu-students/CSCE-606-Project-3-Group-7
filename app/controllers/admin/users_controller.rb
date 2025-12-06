module Admin
  class UsersController < ApplicationController
    before_action :require_admin

    def index
      @users = User.includes(:messages).order(created_at: :desc)
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to chat_path, alert: "Admin access only"
      end
    end
  end
end
