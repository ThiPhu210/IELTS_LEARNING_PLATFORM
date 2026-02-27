class Admin::TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_teacher, only: [:show, :edit, :update, :destroy]

  def index
    @teachers = TeacherProfile.all

    # Search by name or expertise
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @teachers = @teachers.where(
        "LOWER(full_name) LIKE :q OR LOWER(expertise) LIKE :q", q: q
      )
    end

    sort_col = %w[full_name experience_years created_at].include?(params[:sort]) ? params[:sort] : "created_at"
    sort_dir = params[:dir] == "asc" ? "asc" : "desc"
    @teachers = @teachers.order("#{sort_col} #{sort_dir}")
                         .page(params[:page]).per(10)
  end

  def show
    render layout: false
  end

  def edit
    render partial: "form", locals: { teacher: @teacher }
  end

  def update
    if @teacher.update(teacher_params)
      redirect_to admin_teachers_path, notice: "Teacher updated successfully"
    else
      render partial: "form", locals: { teacher: @teacher }, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy
    redirect_to admin_teachers_path, notice: "Teacher removed successfully"
  end

  private

  def set_teacher
    @teacher = TeacherProfile.find(params[:id])
  end

  def teacher_params
    params.require(:teacher_profile).permit(
      :full_name, :bio, :expertise, :experience_years, :avatar
    )
  end
end
