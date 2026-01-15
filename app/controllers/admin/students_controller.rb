class Admin::StudentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @students = User.student_role.order(created_at: :desc).page(params[:page]).per(10)
  end
end
