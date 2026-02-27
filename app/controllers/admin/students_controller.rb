class Admin::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    @students = User.where(role: :student)

    # Search by name or email
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @students = @students.where(
        "LOWER(full_name) LIKE :q OR LOWER(email) LIKE :q", q: q
      )
    end

    # Sort
    sort_col = %w[full_name email created_at].include?(params[:sort]) ? params[:sort] : "created_at"
    sort_dir = params[:dir] == "asc" ? "asc" : "desc"
    @students = @students.order("#{sort_col} #{sort_dir}")

    # Stats for header cards
    @total_students    = User.where(role: :student).count
    @new_this_month    = User.where(role: :student)
                             .where(created_at: Time.current.beginning_of_month..)
                             .count
    @enrolled_students = CourseAccess.distinct.count(:user_id)
    @avg_band          = SpeakingAttempt.where.not(overall_band: nil)
                                        .average(:overall_band)&.round(1)

    @students = @students.page(params[:page]).per(10)
  end

  def show
  end

  def edit
    render partial: "form", locals: { student: @student }
  end

  def update
    if @student.update(student_params)
      respond_to do |format|
        format.html { redirect_to admin_students_path, notice: "✓ Student updated successfully" }
        format.json { render json: { success: true } }
      end
    else
      render partial: "form", locals: { student: @student }, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to admin_students_path, notice: "Student removed successfully"
  end

  private

  def set_student
    @student = User.find(params[:id])
  end

  def student_params
    params.require(:user).permit(:full_name, :email, :phone, :bio, :school,
                                 :country, :city, :province, :postal_code, :thumbnail)
  end
end
