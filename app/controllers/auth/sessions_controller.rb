class Auth::SessionsController < ApplicationController
  before_action :disable_cache

  def new
    if current_user
      redirect_to after_login_path
    end
  end


  def create
    user = User.find_by(email: params[:email])

    unless user&.authenticate(params[:password])
      flash.now[:alert] = "Email hoặc mật khẩu không đúng"
      return render :new, status: :unprocessable_entity
    end

    unless user.confirmed?
      flash.now[:alert] = "Vui lòng kiểm tra email và xác nhận tài khoản trước khi đăng nhập"
      return render :new, status: :unprocessable_entity
    end

    session[:user_id] = user.id
    redirect_to after_login_path
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

  def disable_cache
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
