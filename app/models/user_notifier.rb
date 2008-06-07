class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'  
    @body[:url]  = "http://#{SITE_URL}/activate/#{user.activation_code}"  
  end
  
  def openid_signup_notification(user)
    setup_email(user)
    @subject += 'Thanks for signing up'
    @body[:url] = '#{SITE_URL}'
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = '#{SITE_URL}'
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'You have requested to change your password'
    @body[:url]  = "http://#{SITE_URL}/reset_password/#{user.activation_code}"
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset.'
  end
  protected
    def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "john@trenouth.com"
    @subject     = "Welcome to Test"
    @sent_on     = Time.now
    @body[:user] = user
  end
end
