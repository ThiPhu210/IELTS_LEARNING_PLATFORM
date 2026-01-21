class Admin::ProfilesController < Admin::BaseController
    before_action :set_user

    def edit
    end

    def update
        @user.skip_reconfirmation! if email_changed?

        if @user.update(user_params)
          redirect_to admin_dashboard_path,
                      notice: "Cập nhật thông tin thành công"
            flash[:success] = "Cập nhật thông tin thành công 🎉"
        else
          render :edit, status: :unprocessable_entity
        end
      end


    private

    def set_user
      @user = current_user   # ✅ QUAN TRỌNG
    end

    def user_params
      params.require(:user).permit(
        :email,
        :full_name,
        :thumbnail
      )
    end

    def email_changed?
      params[:user][:email].present? &&
        params[:user][:email] != @user.email
    end
end
