class Admin::CoursesController < Admin::BaseController
  before_action :authenticate_user!
  before_action :require_admin
  def index
  @courses = Course
              .order(created_at: :desc)
              .page(params[:page])
              .per(1)
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
      flash[:success] = "✅ Bạn vừa thay đổi thành công thông tin khóa học"
      redirect_to admin_courses_path, notice: "Cập nhật khóa học thành công"

    else
      Rails.logger.debug @course.errors.full_messages
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
    :price,
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
        :_destroy,
        { pdfs: [] }
      ]
    ]
  )
end

  end
  
