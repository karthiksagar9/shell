# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  include UserOpenidsHelper
  
  def new
  end

  def normal_create
    password_authentication(params[:login], params[:password])
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  private
  def password_authentication(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { 
          :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      successful_login #defined in helpers/user_openids_helper.rb
    else
      failed_login('Invalid login or password') # defined in helpers/user_openids_helper.rb
    end
  end

end
