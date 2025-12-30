class Admin::BaseController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    unless current_user&.admin_role?
      redirect_to login_path, alert: "Bạn không có quyền truy cập"
    end
  end
end
