class Admin::CoursesController < Admin::BaseController
  before_action :authenticate_user!
  before_action :require_admin
  def index
    @courses = Course.order(created_at: :desc)
  end

  def edit
    @course = Course.find(params[:id])

    if @course.course_sections.empty?
      section = @course.course_sections.build
      section.lessons.build
    else
      @course.course_sections.each do |section|
        section.lessons.build if section.lessons.empty?
      end
    end
  end


  def update
    @course = Course.find(params[:id])

    if @course.update(course_params)
      redirect_to edit_admin_course_path(@course), notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
    Rails.logger.debug params[:course]
  end

  def destroy
    course = Course.find(params[:id])
    course.destroy
    redirect_to admin_courses_path, notice: "Đã xóa khóa học"
  end

  private
  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :thumbnail,
      course_sections_attributes: [
        :id,
        :title,
        :_destroy,
        lessons_attributes: [
          :id,
          :title,
          :duration,
          :video,
          { pdfs: [] },
          :_destroy
        ]
      ]
    )
  end
  
end
