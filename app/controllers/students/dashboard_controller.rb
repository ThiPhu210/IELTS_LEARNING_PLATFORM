class Students::DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "students"

  def index
    Rails.logger.info "PAID PARAM = #{params[:paid]}"
    @courses = Course.all 
    @courses_paid = Course
      .joins(:orders)
      .where(
        orders: {
          user_id: current_user.id,
          status: Order.statuses[:paid]
        }
      )
      .distinct

    Rails.logger.info "COURSES FOUND = #{@courses.pluck(:id)}"
  end
end
