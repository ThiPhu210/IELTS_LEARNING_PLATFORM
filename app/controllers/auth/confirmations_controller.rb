class Auth::ConfirmationsController < ApplicationController
  def show
    begin
      user = User.find_by!(confirmation_token: params[:confirmation_token])
      user.confirm!
      redirect_to login_path, notice: "Account confirmed successfully"
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Invalid or expired confirmation link"
    end
  end
end
