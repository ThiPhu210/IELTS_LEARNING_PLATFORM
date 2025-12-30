class Auth::RegistrationsController < ApplicationController
  layout "auth"

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "student" # default role
    if @user.save
      session[:user_id] = @user.id
      redirect_to student_dashboard_path, notice: "Đăng ký thành công!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :password)
  end
end
