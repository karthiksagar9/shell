require File.dirname(__FILE__) + '/../test_helper'

class SessionsControllerTest < ActionController::TestCase

  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'test'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_login_from_openid_authorisation
    @controller.expects(:successful_login).returns(true)
    @controller.expects(:"current_user=")
    user = users(:quentin)
    identity_url = user.user_openids.first.openid_url
    assert_no_difference User, :count do 
      @controller.send :successful_openid_login, identity_url
      assert(user = @controller.instance_variable_get("@user"), "Cannot find @user")
    end
  end
  
  def test_should_register_and_login_from_new_openid
    @controller.expects(:successful_login).returns(true)
    @controller.expects(:"current_user=")
    registration = {"nickname" => "Dr Nic", "fullname" => "Dr Nic Williams"}
    identity_url = "http://drnicwilliams.com/"
    assert_difference User, :count, 1 do 
      assert_difference UserOpenid, :count, 1 do 
        @controller.send :successful_openid_login, identity_url, registration
        assert(user = @controller.instance_variable_get("@user"), "Cannot find @user")
        assert_equal(registration["fullname"], user.name)
        assert_equal(registration["nickname"], user.login)
        assert_equal(1, user.user_openids.count)
        assert_equal(identity_url, user.user_openids.first.openid_url)
      end
    end
  end
  
  def test_should_register_and_require_edit_from_new_openid_without_required_fields
    @controller.expects(:unfinished_registration).returns(true)
    @controller.expects(:"current_user=")
    identity_url = "http://drnicwilliams.com/"
    assert_no_difference User, :count do
      @controller.send :successful_openid_login, identity_url, {}
      assert(user = @controller.instance_variable_get("@user"), "Cannot find @user")
    end
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
