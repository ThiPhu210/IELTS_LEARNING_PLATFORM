class HomeController < ApplicationController
  def index
    @courses = Course.includes(:thumbnail_attachment).all
    @teacher_profiles = TeacherProfile.all
    @achievements = Achievement.high_band.sorted_by_band.page(params[:page]).per(10)
    @navbar_courses = Course.includes(:thumbnail_attachment).limit(8)
  end
end
