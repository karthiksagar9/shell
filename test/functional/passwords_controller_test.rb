require File.dirname(__FILE__) + '/../test_helper'

class PasswordsControllerTest < ActionController::TestCase
  
  def test_user_can_create_reset_code
    post :create, :email => users(:quentin).email
    assert_redirected_to home_path
    assert flash[:notice], "A password reset link has been sent to #{assigns(:user).email}."
  end
  
  def test_user_cannot_create_reset_code
    post :create, :email => 'an@email.com'
    assert_redirected_to forgot_password_path
    assert flash[:error], "Could not find a user with that email address."
  end
  
  def test_user_cannot_reset_code_if_logged_in
    login_as(:quentin)
    get :new
    assert_redirected_to home_path
  end
  
  def test_user_can_reset_password
    user = users(:dan)
    user.forgot_password
    post :edit, :activation_code => user.activation_code,
                :password => '12346',
                :password_confirmation => '12346'
    assert_redirected_to login_path
    assert user.check_auth('12346')
  end
  
  def test_user_cannot_reset_password_with_incorrect_code
    user = users(:dan)
    user.forgot_password
    post :edit, :activation_code => '123431325hk3hus98fyw8',
                :password => '12346',
                :password_confirmation => '12346'
    assert_redirected_to forgot_password_path
    assert flash[:error], "Could not find a user with that email address."
    assert user.check_auth('test')
  end
end
