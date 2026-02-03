class HomeController < ApplicationController
    def index
      Rails.logger.info "PAID PARAM = #{params[:paid]}"
      @courses = Course.all
      @teacher_profiles = TeacherProfile.all
      @achievements = Achievement .high_band .sorted_by_band .page(params[:page]) .per(10)
  end
end
