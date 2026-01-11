class Admin::UsersController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @users = User.all.order(created_at: :desc)
  end
end

