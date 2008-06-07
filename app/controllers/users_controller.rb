class UsersController < ApplicationController
  include UserOpenidsHelper

  before_filter :login_required, :only => [ :edit, :update, :change_password ]
  before_filter :not_logged_in_required, :only => [:new, :create]
  def new
    @user = User.new(params[:user])
    @user.valid? if params[:user]
  end

  def normal_create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = User.find(params[:id])
    @user_openids = @user.user_openids
  end
  
  def update
    @user = User.find(params[:id])
    @success = @user.update_attributes(params[:user]) #TODO - protect some fields
    respond_to do |format|
      if @success
        flash[:notice] = "User account saved successfully."
        format.html {redirect_to :action => "edit"}
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "You have been destroyed your account."
      redirect_back_or_default('/')
    else
      flash[:error] = "Unable to destroy account"
      render :action => 'edit'
    end
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

end
