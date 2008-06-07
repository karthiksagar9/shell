class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserNotifier.deliver_signup_notification(user) if user.normal_account?
    if user.openid_account?
      UserNotifier.deliver_openid_signup_notification(user)
      user.activate!
    end
  end

  def after_save(user)
    #UserNotifier.deliver_activation(user) if user.pending?
    UserNotifier.deliver_forgot_password(user) if user.forgot_pw?
    UserNotifier.deliver_reset_password(user) if user.reset_pw?
  end
end
