class Students::BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_student!

    layout "students"

    private

    def ensure_student!
      return if current_user&.student_role?

      redirect_to root_path, alert: "Bạn không có quyền truy cập"
    end
end
