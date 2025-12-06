module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [:update]

    def index
      @users = User.includes(:messages).order(created_at: :desc)
    end

    def update
      new_role = params[:role] == 'admin' ? 'admin' : 'user'
      
      if @user.update(role: new_role)
        redirect_to admin_users_path, notice: "#{@user.email} role updated to #{new_role}"
      else
        redirect_to admin_users_path, alert: "Failed to update role: #{@user.errors.full_messages.join(', ')}"
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def require_admin
      unless current_user&.admin?
        redirect_to chat_path, alert: "Admin access only"
      end
    end
  end
end
