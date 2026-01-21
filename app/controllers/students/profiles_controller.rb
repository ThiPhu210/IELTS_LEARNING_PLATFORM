# app/controllers/students/profiles_controller.rb
class Students::ProfilesController < Students::BaseController
    before_action :authenticate_user!
    before_action :set_user

    def edit
    end

    def update
        if params[:id].present? && params[:id].to_i != current_user.id
          head :forbidden
          return
        end

        if @user.update(user_params)
          redirect_to students_dashboard_path,
                      notice: "Cập nhật thông tin thành công"
        else
          render :edit, status: :unprocessable_entity
        end
      end


    private

    def set_user
      @user = current_user
    end

    def user_params
      params.require(:user).permit(
        :email,
        :full_name,
        :thumbnail
      )
    end
end
