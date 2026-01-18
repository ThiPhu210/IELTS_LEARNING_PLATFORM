class Students::CoursesController < ApplicationController
  layout "students"
  before_action :authenticate_user!
  before_action :ensure_student!
  
  def index
    @courses = Course
      .includes(:thumbnail_attachment)
      .where(published: true)
      .order(created_at: :desc)
    
  end

  private

  def ensure_student!
    redirect_to root_path unless current_user.student?
  end
end
