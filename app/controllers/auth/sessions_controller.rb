class Auth::SessionsController < ApplicationController
  #before_action :require_login
  # before_action :redirect_if_logged_in, only: [ :new, :create ]
  before_action :disable_cache
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Email hoặc mật khẩu không đúng"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  def after_login_path
    case current_user.role
    when "student"
      student_dashboard_path
    when "teacher"
      teacher_dashboard_path
    when "admin"
      admin_dashboard_path
    else
      root_path
    end
  end
  private
  # def redirect_if_logged_in
  #   redirect_to after_login_path if logged_in?
  # end

  def disable_cache
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
