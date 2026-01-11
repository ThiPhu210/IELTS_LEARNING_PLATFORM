class Admin::PaymentsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @payments = Payment.all.includes(:order, :course_access).order(created_at: :desc)
  end
end

