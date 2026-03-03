# spec/requests/students/chats_spec.rb
require "rails_helper"

RSpec.describe "Students::Chats", type: :request do
  let(:user)   { create(:user) }
  let(:course) { create(:course) }

  before do
    sign_in user
    allow(user).to receive(:has_course_access?)
      .with(course)
      .and_return(true)
  end

  describe "POST /students/courses/:course_id/chats" do
    let(:params) { { message: "Explain grammar" } }

    context "when request is valid" do
      before do
        allow(BedrockChatService)
          .to receive(:chat)
          .and_return("AI response")
      end

      it "creates user and assistant messages and returns 200" do
        expect {
          post students_course_chats_path(course_id: course.id),
               params: params
        }.to change(ChatMessage, :count).by(2)

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("AI response")
        expect(json["remaining"]).to eq(ChatMessage::DAILY_LIMIT - 1)
      end
    end

    context "when message is blank" do
      it "returns 422" do
        post students_course_chats_path(course_id: course.id),
             params: { message: "" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when daily limit reached" do
      before do
        ChatMessage::DAILY_LIMIT.times do
          create(:chat_message,
            user: user,
            course: course,
            role: "user",
            content: "Spam",
            sent_on: Date.today
          )
        end
      end

      it "returns 429 too_many_requests" do
        post students_course_chats_path(course_id: course.id),
             params: params

        expect(response).to have_http_status(:too_many_requests)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("limit_reached")
      end
    end

    context "when user has no access to course" do
      before do
        allow(user).to receive(:has_course_access?)
          .and_return(false)
      end

      it "returns 403 forbidden" do
        post students_course_chats_path(course_id: course.id),
             params: params

        expect(response).to have_http_status(:forbidden)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("access_denied")
      end
    end

    context "when Bedrock raises ServiceError" do
      before do
        allow(BedrockChatService)
          .to receive(:chat)
          .and_raise(
            Aws::BedrockRuntime::Errors::ServiceError.new(nil, "Bedrock failed")
          )
      end

      it "returns 503 service_unavailable" do
        post students_course_chats_path(course_id: course.id),
             params: params

        expect(response).to have_http_status(:service_unavailable)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("AI service unavailable. Please try again.")
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(BedrockChatService)
          .to receive(:chat)
          .and_raise(StandardError.new("Something bad"))
      end

      it "returns 500 internal_server_error" do
        post students_course_chats_path(course_id: course.id),
             params: params

        expect(response).to have_http_status(:internal_server_error)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Something went wrong.")
      end
    end
  end
end
