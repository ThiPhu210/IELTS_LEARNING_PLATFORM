class Admin::CourseSectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  def index
    @course = Course.find(params[:course_id])
    @sections = @course.course_sections
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end
