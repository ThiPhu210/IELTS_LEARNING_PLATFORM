class Users::PasswordsController < Devise::PasswordsController
    protected
    def after_resetting_password_path_for(resource)
      new_user_session_path
    end
  end
  