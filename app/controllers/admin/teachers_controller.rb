class Admin::TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_teacher, only: [ :show, :edit, :update, :destroy ]

  def index
    @teachers = TeacherProfile.order(created_at: :asc).page(params[:page]).per(5)
  end

  def show
  end

  def edit
    render partial: "form", locals: { teacher: @teacher }
  end

  def update
    if @teacher.update(teacher_params)
      redirect_to admin_teachers_path, notice: "Cập nhật thành công"
    else
      render partial: "form", locals: { teacher: @teacher }, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy
    redirect_to admin_teachers_path, notice: "🗑 Đã xóa giáo viên"
  end

  private

  def set_teacher
    @teacher = TeacherProfile.find(params[:id])
  end

  def teacher_params
    params.require(:teacher_profile).permit(
      :full_name,
      :bio,
      :expertise,
      :experience_years,
      :avatar
    )
  end
end
