class Admin::CoursesController < Admin::BaseController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_course, only: [:edit, :update, :destroy]
  # ================= INDEX =================
  def index
    @courses = Course
                .order(created_at: :desc)
                .page(params[:page])
                .per(5)
  end
  # ================= EDIT =================
  def edit
    build_nested_structure
  end
  # ================= UPDATE =================
  def update
    Rails.logger.debug "=========== PARAMS COURSE ==========="
    Rails.logger.debug params[:course]&.to_unsafe_h
    
    # 🔥 FIX: Reorder course_sections_attributes by position
    reorder_section_attributes!
    
    if @course.update(course_params)
      Rails.logger.debug "=========== UPDATE SUCCESS ==========="
      redirect_to admin_courses_path,
                  notice: "Cập nhật khóa học thành công"
    else
      Rails.logger.debug "=========== COURSE ERRORS ==========="
      Rails.logger.debug @course.errors.full_messages
      log_nested_errors
      build_nested_structure
      render :edit, status: :unprocessable_entity
    end
  end
  # ================= DESTROY =================
  def destroy
    @course.destroy
    redirect_to admin_courses_path, notice: "Đã xóa khóa học"
  end
  # ================= PRIVATE =================
  private
  def set_course
    @course = Course.find(params[:id])
  end
  
  # 🔥 Ensure sections are saved in correct order by position
  # Rails fields_for uses hash indices, so reorder them
  def reorder_section_attributes!
    section_attrs = params[:course][:course_sections_attributes]
    return unless section_attrs.is_a?(Hash)
    
    # Convert hash indices to sequential 0, 1, 2...
    reordered = {}
    index = 0
    section_attrs.each do |old_index, section_data|
      reordered[index.to_s] = section_data
      index += 1
    end
    
    params[:course][:course_sections_attributes] = reordered
  end
  
  # 🔥 build nested structure tránh mất form khi lỗi
  def build_nested_structure
    if @course.course_sections.empty?
      section = @course.course_sections.build
      lesson  = section.lessons.build
      topic   = lesson.speaking_topics.build
      topic.speaking_questions.build
    else
      @course.course_sections.each do |section|
        section.lessons.build if section.lessons.empty?
        section.lessons.each do |lesson|
          lesson.speaking_topics.build if lesson.speaking_topics.empty?
          lesson.speaking_topics.each do |topic|
            topic.speaking_questions.build if topic.speaking_questions.empty?
          end
        end
      end
    end
  end
  
  # 🔥 log nested error chuẩn LMS
  def log_nested_errors
    @course.course_sections.each do |section|
      Rails.logger.debug "SECTION ERROR: #{section.errors.full_messages}" if section.errors.any?
      section.lessons.each do |lesson|
        Rails.logger.debug "LESSON ERROR: #{lesson.errors.full_messages}" if lesson.errors.any?
        lesson.speaking_topics.each do |topic|
          Rails.logger.debug "TOPIC ERROR: #{topic.errors.full_messages}" if topic.errors.any?
          topic.speaking_questions.each do |q|
            Rails.logger.debug "QUESTION ERROR: #{q.errors.full_messages}" if q.errors.any?
          end
        end
      end
    end
  end
  
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
          :course_section_id,
          :_destroy,
          { pdfs: [] },
          speaking_topics_attributes: [
            :id,
            :title,
            :part,
            :_destroy,
            speaking_questions_attributes: [
              :id,
              :question_text,
              :cue_card,
              :preparation_time,
              :speaking_time,
              :_destroy
            ]
          ]
        ]
      ]
    )
  end
end
