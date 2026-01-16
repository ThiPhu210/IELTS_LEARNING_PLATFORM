class Admin::TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_teacher, only: [ :show, :edit, :update, :destroy ]


  def index
    @teachers = User.teacher_role.page(params[:page]).per(5).includes(:teacher_profile)
  end

  def show
  end

  def edit
  @teacher.build_teacher_profile if @teacher.teacher_profile.nil?
  end

def update
  if @teacher.update(teacher_params)
    redirect_to admin_teachers_path, notice: "Cập nhật thành công"
  else
    @teacher.build_teacher_profile if @teacher.teacher_profile.nil?
    render partial: "form", locals: { teacher: @teacher }, status: :unprocessable_entity
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
