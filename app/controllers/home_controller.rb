class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
    def index
      Rails.logger.info "PAID PARAM = #{params[:paid]}"
      @courses = Course.all
      @teacher_profiles = TeacherProfile.all
      @achievements = Achievement .high_band .sorted_by_band .page(params[:page]) .per(10) # số bản ghi mỗi trang
  end
end
