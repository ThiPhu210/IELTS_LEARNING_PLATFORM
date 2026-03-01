# app/controllers/students/chats_controller.rb
# Route: /students/courses/:course_id/chats

class Students::ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :require_course_access!

  # GET /students/courses/:course_id/chats/history
  def history
    messages = current_user.chat_messages
                           .where(course: @course, sent_on: Date.today)
                           .order(:created_at)
                           .map { |m| { role: m.role, content: m.content } }

    render json: {
      messages:  messages,
      remaining: ChatMessage.remaining_for(current_user, @course),
      limit:     ChatMessage::DAILY_LIMIT
    }
  end

  # POST /students/courses/:course_id/chats
  def create
    unless ChatMessage.can_chat?(current_user, @course)
      render json: {
        error:   "limit_reached",
        message: "Bạn đã dùng hết #{ChatMessage::DAILY_LIMIT} lượt hôm nay cho khóa học này. Quay lại vào ngày mai nhé! 🌙"
      }, status: :too_many_requests
      return
    end

    user_content = params[:message].to_s.strip
    if user_content.blank?
      render json: { error: "Tin nhắn không được để trống." }, status: :unprocessable_entity
      return
    end

    # Lưu tin nhắn user
    ChatMessage.create!(
      user:    current_user,
      course:  @course,
      role:    "user",
      content: user_content,
      sent_on: Date.today
    )

    # Lấy context hôm nay (tối đa 10 tin gần nhất)
    history = current_user.chat_messages
                          .where(course: @course, sent_on: Date.today)
                          .order(:created_at)
                          .last(10)
                          .map { |m| { role: m.role, content: m.content } }

    # Gọi Bedrock
    ai_response = BedrockChatService.chat(messages: history)

    # Lưu response AI
    ChatMessage.create!(
      user:    current_user,
      course:  @course,
      role:    "assistant",
      content: ai_response,
      sent_on: Date.today
    )

    render json: {
      message:   ai_response,
      remaining: ChatMessage.remaining_for(current_user, @course),
      limit:     ChatMessage::DAILY_LIMIT
    }

  rescue Aws::BedrockRuntime::Errors::ServiceError => e
    Rails.logger.error "[ChatsController] Bedrock error: #{e.message}"
    render json: { error: "AI service unavailable. Please try again." }, status: :service_unavailable
  rescue StandardError => e
    Rails.logger.error "[ChatsController] Error: #{e.message}"
    render json: { error: "Something went wrong." }, status: :internal_server_error
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Course not found." }, status: :not_found
  end

  def require_course_access!
    unless current_user.has_course_access?(@course)
      render json: {
        error:   "access_denied",
        message: "Tính năng này chỉ dành cho học viên đã đăng ký khóa học."
      }, status: :forbidden
    end
  end
end
