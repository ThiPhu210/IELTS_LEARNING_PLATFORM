class Admin::TeachersController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_teacher, only: [ :show, :update, :destroy ]

  def index
    @teachers = User.teacher_role.includes(:teacher_profile)
  end

  def show
    @teacher = User.teacher_role.find(params[:id])
    @teacher.build_teacher_profile if @teacher.teacher_profile.nil?
  end


  def update
    Rails.logger.debug params.inspect

    if @teacher.update(teacher_params)
      flash[:success] = "Thay đổi thông tin giáo viên thành công !"
      redirect_to admin_teacher_path(@teacher), notice: "Cập nhật thành công"
    else
      Rails.logger.debug @teacher.errors.full_messages
      render :show
    end
  end


  def destroy
    @teacher.destroy
    redirect_to admin_teachers_path, notice: "🗑 Đã xóa giáo viên"
  end

  private

  def set_teacher
    @teacher = User.teacher_role.find(params[:id])
  end

  def teacher_params
    params.require(:user).permit(
      :full_name,
      :email,
      teacher_profile_attributes: [
        :id,
        :bio,
        :expertise,
        :experience_years,
        :avatar
      ]
    )
  end
end
