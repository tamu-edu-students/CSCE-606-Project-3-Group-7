module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [ :update ]

    def index
      @users = User.includes(:messages)

      # Sort by created_at if requested, otherwise by role (default)
      if params[:sort] == "created_at"
        @users = @users.order(created_at: :desc)
      else
        @users = @users.order(role: :asc, created_at: :desc)
      end
    end

    def update
      # Prevent admins from revoking their own admin access
      if @user.id == current_user.id && params[:user][:role] == "user"
        redirect_to admin_users_path, alert: "You cannot revoke your own admin access."
        return
      end

      if @user.update(user_params)
        action = @user.admin? ? "granted admin access to" : "revoked admin access from"
        redirect_to admin_users_path, notice: "Successfully #{action} #{@user.email}."
      else
        redirect_to admin_users_path, alert: "Failed to update user: #{@user.errors.full_messages.join(', ')}"
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end

    def require_admin
      unless current_user&.admin?
        redirect_to chat_path, alert: "Admin access only"
      end
    end
  end
end
