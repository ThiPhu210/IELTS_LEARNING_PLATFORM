class HomeController < ApplicationController
  def index
    @courses = Course.all
    @navbar_courses = Course.limit(12)
    @teacher_profiles = TeacherProfile.all
    @achievements = Achievement.high_band.sorted_by_band.page(params[:page]).per(10)
  end
end
