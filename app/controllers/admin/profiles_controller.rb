class Admin::ProfilesController < Admin::BaseController
    before_action :set_user

    def edit
    end

    def update
        @user.skip_reconfirmation! if email_changed?

        if @user.update(user_params)
          flash[:success] = "Cập nhật thông tin thành công 🎉"
          redirect_to admin_dashboard_path,
                      notice: "Cập nhật thông tin thành công 🎉"
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
        :thumbnail,
        :school,
        :feedback,
        :bio,
        :phone,
        :country,
        :city,
        :province,
        :postal_code
      )
    end


    def email_changed?
      params[:user][:email].present? &&
        params[:user][:email] != @user.email
    end
end
