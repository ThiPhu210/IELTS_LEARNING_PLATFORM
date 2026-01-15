class Admin::UsersController < Admin::BaseController
  before_action :authenticate_user!
  before_action :require_admin
  def index
    @users = User.all.order(created_at: :desc).page(params[:page]).per(10)
  end
end
