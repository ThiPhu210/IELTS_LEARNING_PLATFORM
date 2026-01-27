class Admin::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    @students = User.students.order(created_at: :asc).page(params[:page]).per(5)
  end

  def show
  end

  def edit
    render partial: "form", locals: { student: @student }
  end

  def update
    if @student.update(student_params)
      redirect_to admin_students_path, notice: "Cập nhật thành công"
    else
      render partial: "form", locals: { student: @student }, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to admin_students_path, notice: "🗑 Đã xóa học viên"
  end

  private

  def set_student
    @student = User.find(params[:id])
  end

  def student_params
    params.require(:user).permit(:full_name, :email, :phone, :bio, :thumbnail)
  end
end
