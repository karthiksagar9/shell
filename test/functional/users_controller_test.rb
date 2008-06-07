require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase

  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_should_activate_user
    assert_nil User.authenticate('aaron', 'test')
    get :activate, :activation_code => users(:aaron).activation_code
    assert_redirected_to '/'
    assert_not_nil flash[:notice]
    assert_equal users(:aaron), User.authenticate('aaron', 'test')
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
  
  def test_new_should_accept_defaults
    defaults = { :email => 'foo@bar.com', :name => 'Foo Bar' }
    get :new, :user => defaults
    assert(user = assigns(:user), "Cannot find @user")
    assert_equal(defaults[:email], user.email)
    assert_equal(defaults[:name],  user.name)
  end

  def test_new_should_accept_defaults_incl_identity_url
    defaults = { :email => 'foo@bar.com', :name => 'Foo Bar', :identity_url => 'http://foobar.com' }
    get :new, :user => defaults
    assert(user = assigns(:user), "Cannot find @user")
    assert_equal(defaults[:email], user.email)
    assert_equal(defaults[:name],  user.name)
    assert_equal(defaults[:identity_url],  user.identity_url)
    assert_select "input#user_identity_url"
  end
  
  # When user registers via OpenID yet they have missing required fields, then they
  # must complete app registration. The OpenID is stored in user[identity_url], not openid_url field
  # See users/new.html.erb form
  def test_should_accept_identity_url_on_create
    params = { :login => 'foobar', :email => 'foo@bar.com', :name => 'Foo Bar', :identity_url => 'http://foobar.com/' }
    assert_difference User, :count, 1 do 
      assert_difference UserOpenid, :count, 1 do 
        post :create, :user => params
        assert(user = assigns(:user), "Cannot find @user")
        assert_equal(params[:email], user.email)
        assert_equal(params[:name],  user.name)
        assert_equal(1, user.user_openids.count)
        user_openid = user.user_openids.first
        assert_equal(params[:identity_url], user_openid.openid_url)
      end
    end
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
