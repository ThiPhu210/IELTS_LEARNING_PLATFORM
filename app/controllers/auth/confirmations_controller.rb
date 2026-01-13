class Auth::ConfirmationsController < ApplicationController
  def show
    token = params[:confirmation_token]

    self.resource = User.confirm_by_token(token)

    if resource.errors.empty?
      redirect_to login_path, notice: "Email confirmed successfully"
    else
      redirect_to root_path, alert: "Invalid or expired confirmation token"
    end
  end
end
