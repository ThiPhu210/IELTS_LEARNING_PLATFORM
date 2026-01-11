class Admin::LessonsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @lessons = Lesson.all.includes(:course).order(created_at: :desc)
  end
end

