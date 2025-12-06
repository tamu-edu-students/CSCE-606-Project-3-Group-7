class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # Skip CSRF verification for OAuth callbacks (OmniAuth handles its own security)
  skip_before_action :verify_authenticity_token, only: [ :oauth_callback, :oauth_failure ]

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def oauth_callback
    auth = request.env["omniauth.auth"]

    Rails.logger.info "OAuth Data: #{auth.inspect}"

    user = User.find_or_create_from_oauth(auth)
    if user.nil?
      flash[:alert] = "Only @tamu.edu accounts are allowed."
      redirect_to root_path and return
    end

    session[:user_id] = user.id

    redirect_to root_path, notice: "Signed in as #{user.name}!"
  end

  def oauth_failure
    Rails.logger.error "OAuth Failure: #{params.inspect}"
    redirect_to root_path, alert: "Authentication failed: #{params[:message]}"
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out"
  end
end
