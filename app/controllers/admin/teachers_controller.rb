# app/controllers/admin/teachers_controller.rb
class Admin::TeachersController < Admin::BaseController
    def new
      @user = User.new
    end
  
    def create
      @user = User.new(teacher_params)
      @user.role = "teacher"
  
      if @user.save
        redirect_to admin_dashboard_path, notice: "Tạo giáo viên thành công"
      else
        render :new
      end
    end
  
    private
  
    def teacher_params
      params.require(:user).permit(:full_name, :email, :password)
    end
  end
  