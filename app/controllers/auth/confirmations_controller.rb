class Auth::ConfirmationsController < ApplicationController
  def show
    token = params[:token]
    user = User.find_by!(confirmation_token: token)
    user.confirm!
    redirect_to login_path, notice: "Account confirmed successfully"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid or expired confirmation link"
  end
end
