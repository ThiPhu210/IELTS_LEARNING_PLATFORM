class Admin::StudentsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @students = User.student_role.order(created_at: :desc).page(params[:page]).per(10)
  end
end
