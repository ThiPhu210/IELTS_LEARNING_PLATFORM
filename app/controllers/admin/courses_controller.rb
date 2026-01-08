class Admin::CoursesController < ApplicationController
  layout "admin"
  before_action :require_login
  before_action :require_admin

  def index
    @courses = Course.all.includes(:lessons).order(created_at: :desc)
  end
end

