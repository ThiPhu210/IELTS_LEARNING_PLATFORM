require 'rails_helper'

RSpec.describe "Students::SpeakingAttempts", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/students/speaking_attempts/create"
      expect(response).to have_http_status(:success)
    end
  end

end
