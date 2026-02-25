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
  
  # ================= UPDATE - WITH CUSTOM LOGIC =================
  def update
    Rails.logger.debug "=========== PARAMS COURSE ==========="
    Rails.logger.debug params[:course]&.to_unsafe_h
    
    # 🔥 Custom update logic để tránh nested attribute issues
    if update_course_with_sections
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
  
  # 🔥 Custom update: xử lý course basic + sections/lessons riêng biệt
  def update_course_with_sections
    course_basic_params = params.require(:course).permit(:title, :description, :price, :thumbnail)
    
    # Update course basic info
    unless @course.update(course_basic_params)
      Rails.logger.debug "Basic update failed: #{@course.errors.full_messages}"
      return false
    end
    
    # Xử lý sections từng cái một (tránh nested issues)
    sections_attrs = params[:course][:course_sections_attributes] || {}
    
    sections_attrs.each do |index_key, section_data|
      next unless section_data.is_a?(Hash)
      
      section_id = section_data[:id]
      
      # Handle destroy
      if section_data[:_destroy] == "true"
        if section_id.present?
          CourseSection.find(section_id).destroy
        end
        next
      end
      
      # Create hoặc update section
      section = if section_id.present?
        CourseSection.find(section_id)
      else
        @course.course_sections.build
      end
      
      section.title = section_data[:title]
      unless section.save
        Rails.logger.debug "Section save failed: #{section.errors.full_messages}"
        return false
      end
      
      # Xử lý lessons của section
      lessons_attrs = section_data[:lessons_attributes] || {}
      lessons_attrs.each do |lesson_index_key, lesson_data|
        next unless lesson_data.is_a?(Hash)
        
        lesson_id = lesson_data[:id]
        
        # Handle destroy
        if lesson_data[:_destroy] == "true"
          if lesson_id.present?
            Lesson.find(lesson_id).destroy
          end
          next
        end
        
        # Create hoặc update lesson
        lesson = if lesson_id.present?
          Lesson.find(lesson_id)
        else
          section.lessons.build
        end
        
        lesson.title = lesson_data[:title]
        lesson.duration = lesson_data[:duration]
        
        # Handle video
        if lesson_data[:video].present? && lesson_data[:video].respond_to?(:io)
          lesson.video.attach(lesson_data[:video])
        end
        
        # Handle PDFs
        if lesson_data[:pdfs].present? && lesson_data[:pdfs].is_a?(Array)
          lesson_data[:pdfs].each do |pdf|
            lesson.pdfs.attach(pdf) if pdf.respond_to?(:io)
          end
        end
        
        unless lesson.save
          Rails.logger.debug "Lesson save failed: #{lesson.errors.full_messages}"
          return false
        end
        
        # Xử lý speaking topics của lesson
        topics_attrs = lesson_data[:speaking_topics_attributes] || {}
        topics_attrs.each do |topic_index_key, topic_data|
          next unless topic_data.is_a?(Hash)
          
          topic_id = topic_data[:id]
          
          # Handle destroy
          if topic_data[:_destroy] == "true"
            if topic_id.present?
              SpeakingTopic.find(topic_id).destroy
            end
            next
          end
          
          # Create hoặc update topic
          topic = if topic_id.present?
            SpeakingTopic.find(topic_id)
          else
            lesson.speaking_topics.build
          end
          
          topic.title = topic_data[:title]
          topic.part = topic_data[:part]
          
          unless topic.save
            Rails.logger.debug "Topic save failed: #{topic.errors.full_messages}"
            return false
          end
          
          # Xử lý questions của topic
          questions_attrs = topic_data[:speaking_questions_attributes] || {}
          questions_attrs.each do |q_index_key, q_data|
            next unless q_data.is_a?(Hash)
            
            q_id = q_data[:id]
            
            # Handle destroy
            if q_data[:_destroy] == "true"
              if q_id.present?
                SpeakingQuestion.find(q_id).destroy
              end
              next
            end
            
            # Create hoặc update question
            question = if q_id.present?
              SpeakingQuestion.find(q_id)
            else
              topic.speaking_questions.build
            end
            
            question.question_text = q_data[:question_text]
            question.cue_card = q_data[:cue_card]
            question.preparation_time = q_data[:preparation_time]
            question.speaking_time = q_data[:speaking_time]
            
            unless question.save
              Rails.logger.debug "Question save failed: #{question.errors.full_messages}"
              return false
            end
          end
        end
      end
    end
    
    true
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
end
