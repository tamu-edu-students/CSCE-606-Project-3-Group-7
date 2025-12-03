class OmniauthController < ApplicationController
  # Rails requires this action so OmniAuth can intercept /auth/:provider
  def passthru
    # OmniAuth will take over — we never reach this if omniauth-google-oauth2 works
    render plain: "Not implemented", status: :not_found
  end
end
