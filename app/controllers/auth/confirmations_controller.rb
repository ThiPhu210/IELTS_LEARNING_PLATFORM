class Auth::ConfirmationsController < ApplicationController
  class Auth::ConfirmationsController < ApplicationController
    def show
      user = User.find_by!(confirmation_token: params[:token])
      user.confirm!  # ✅ set confirmed = true, confirmed_at, xóa token
      redirect_to login_path, notice: "Account confirmed successfully"
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Invalid or expired token"
    end
  end
end
