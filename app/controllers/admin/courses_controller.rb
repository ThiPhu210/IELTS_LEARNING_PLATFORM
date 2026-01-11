class Admin::CoursesController < Admin::BaseController
  def index
    @courses = Course.order(created_at: :desc)
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update(course_params)
      redirect_to admin_courses_path, notice: "Cập nhật khóa học thành công"
    else
      render :edit
    end
  end

  def destroy
    course = Course.find(params[:id])
    course.destroy
    redirect_to admin_courses_path, notice: "Đã xóa khóa học"
  end

  private

  def course_params
    params.require(:course).permit(
      :title, :description,
      :band_min, :band_max,
      :price, :duration_days,
      :status, :thumbnail
    )
  end
end
