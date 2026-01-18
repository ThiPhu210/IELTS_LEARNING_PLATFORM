class Students::DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "students"

  def index
    @courses = Course
      .includes(:thumbnail_attachment)
      .order(created_at: :desc)
      .page(params[:page])
      .per(9)
  @teacher_profiles = TeacherProfile
  .joins(:avatar_attachment)
  .includes(:user)

  end
end
