require 'digest/sha1'
class User < ActiveRecord::Base
  ROLES = ['subscriber', 'moderator', 'administrator']
  
  STATES = [['active',     'unsuspend'], 
            ['suspended',  'suspend'],
            ['deleted',    'delete']]
  EVENTS = [['Activate', 'activate'], ['Suspend', 'suspend'], ['Delete', 'deleted'], ['Unsuspend','unsuspend']]
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :identity_url
  
  has_many :user_openids, :dependent => :destroy
  
  validates_presence_of     :email,                       :if => :not_openid?
  validates_length_of       :email,    :within => 3..100, :if => :not_openid?
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..100
  validates_uniqueness_of   :login,    :case_sensitive => false, :message => 'is already taken; sorry!'
  validates_uniqueness_of   :email,    :case_sensitive => false, :message => 'is already being used; do you already have an account?'
  
  validates_presence_of     :password,                    :if => :password_required?
  validates_presence_of     :password_confirmation,       :if => :password_required?
  validates_length_of       :password, :within => 4..40,  :if => :password_required?
  validates_confirmation_of :password,                    :if => :password_required?
  before_save :encrypt_password
  before_create :make_activation_code
  after_create :make_user_openid
  
  acts_as_state_machine :initial => :pending
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete
  
  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end
  
  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  def self.not_deleted
    find :all, :conditions => ['state <> ?', "deleted"]
  end

  def self.find_by_identity_url(openid_url)
    user_openid = UserOpenid.find_by_openid_url(openid_url, :include => :user)
    user_openid.nil? ? nil : user_openid.user
  end
  
  def self.find_for_forget(email)  
    find :first, :conditions => ['email = ? and activation_code is null', email]  
  end
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end
  
  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end
  
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end
  
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
    
  def check_auth(pw)  
    if User.authenticate(self.login, pw)
      @change_pw = true      
    else  
      errors.add(:old_password, "does not equal current password")  
      @change_pw = false  
    end  
  end  
  
  def forgot_password  
    @forgot_pw = true  
    self.make_activation_code  
    self.save  
  end  
  
  def reset_password(pw, confirm)  
    @reset_pw = true  
    update_attributes(:password => pw, :password_confirmation => confirm)  
  end      
  
  def has_role?(name)  
    self.role.eql?(name) ? true : false  
  end
  
  def change_state(state)
    self.method("#{state}!").call
  end
  
  def normal_account?
    return true if self.not_openid?
  end

  def openid_account?
    return true if !self.not_openid?
  end
  
  def forgot_pw?  
    @forgot_pw  
  end  
  
  def reset_pw?  
    @reset_pw  
  end  
  
  def change_pw?  
    @change_pw  
  end
  
  
  def to_param
    self.login
    #"#{login.gsub(/[^a-z0-9]+/i, '-')}" if self.login
  end
  
  
  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    not_openid? && (crypted_password.blank? || !password.blank?) || @change_pw || @reset_pw
  end
  
  def not_openid?
    identity_url.blank? && user_openids.count == 0
  end
  
  def make_activation_code
    logger.info("*@*@*@*@*@*@* user.make_activation_code")
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def make_user_openid
    self.user_openids.create(:openid_url => identity_url) unless identity_url.blank?
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end
  
  def do_activate
    logger.info("*&*&*&*&* user.do_activate")
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end
  
  

  
end
