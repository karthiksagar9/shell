class PasswordsController < ApplicationController
  before_filter :not_logged_in_required

  #/forgot_password
  def new
  end

  #/mail_reset_code
  def create
    return unless request.post?
    @user = User.find_by_email(params[:email])
    if @user
      @user.forgot_password
      flash[:notice] = "A password reset link has been sent to #{@user.email}."
      redirect_to home_path
    else
      flash[:error] = "Could not find a user with that email address."
      redirect_to forgot_password_path
    end
  end

  #/reset_password/:password_reset_code
  def edit
    @code = params[:activation_code]
    @user = User.find_by_activation_code(@code)
    if @user && request.post?
      @password, @confirmation = params[:password], params[:password_confirmation]
      if @user.reset_password(@password, @confirmation)
        flash[:notice] = "Password reset. You can now login"
        redirect_to login_path
      end
    else
      unless @user
        flash[:error] = "Sorry, that is an invalid password reset code"
        redirect_to forgot_password_path
      end
    end
  end

end