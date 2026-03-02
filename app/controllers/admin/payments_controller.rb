class Admin::PaymentsController < Admin::BaseController
  def index
    @payments = Payment.all.includes(:order, :course_access).order(created_at: :desc)
  end
end
