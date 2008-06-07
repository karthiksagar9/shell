class Admin::UsersController < ApplicationController
  layout 'admin'
  before_filter :admin_required
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  
  def index
    @users = User.not_deleted
    @deleted = User.find_all_by_state("deleted")
  end
  
  def mass_update
    @users = User.find(params[:user_ids])
    if params[:attr_update].eql? "role"
      for user in @users
        user.update_attribute(:role, params[:role]) unless im(user)
      end
    elsif params[:attr_update].eql? "event"
      for user in @users
        user.change_state(params[:event]) unless im(user)
      end
    else
      flash[:error] = "Not sure what you want to do"
    end
    redirect_to admin_users_path
  end
  
  def suspend
    @user.suspend! 
    redirect_to admin_users_path
  end
  
  def unsuspend
    @user.unsuspend! 
    redirect_to admin_users_path
  end
  
  def destroy
    @user.delete!
    redirect_to admin_users_path
  end
  
  def purge
    @user.destroy
    redirect_to admin_users_path
  end
  
  protected
  def find_user
    @user = User.find(params[:id])
    redirect_to admin_users_path if im(@user)
  end
  
end
