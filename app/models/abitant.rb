require 'digest/sha1'
class Abitant < ActiveRecord::Base
  has_many :inputs, :class_name => "Transfer", :order=>'created_at DESC', :foreign_key=>'receiver_id'
  has_many :outputs, :class_name => "Transfer", :order=>'created_at DESC', :foreign_key=>'sender_id'

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password, :if => :password_confirmation?

  validates_length_of       :login,    :within => 3..40, :allow_nil => true
  validates_length_of       :email,    :within => 3..100, :allow_nil => true
  validates_uniqueness_of   :login, :case_sensitive => false, :allow_nil => true
  validates_uniqueness_of   :email, :case_sensitive => false, :allow_nil => true
  validates_numericality_of :favs, :greater_than_or_equal_to=>0
  validate :login_not_numeric
  validate :login_not_include_dots
  before_save :encrypt_password
  before_create :make_login_by_email_token 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :url, :name, :inviter_id
  def superuser?
    login=='midas'
  end
  def generated_wealth
    self.outputs.sum(:amount) || 0
  end
  def login_not_include_dots
    errors.add_to_base("username can't include dots") if login =~ /\./
  end
  def login_not_numeric #required if login is optional
    errors.add_to_base("username can't be a number") if login.to_i.to_s==login
  end

  def to_xml(*params)
    params[0]={:only=>Abitant.public_params} unless params[0]
    super(*params)
  end
  def self.public_params
    [:id, :login, :favs, :url, :activated_at, :created_at, :name]
  end
  def self.find(id_or_username,*others)
    if id_or_username.class!=String || id_or_username.to_i.to_s == id_or_username
      super(id_or_username,*others)
    else
      find_by_login(id_or_username)
    end
  end
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.login_by_email_token = nil
    save(false)
  end
  def to_param
    login || id.to_s
  end
  def to_s
    (name.blank? ? nil : name) || login || "abitant-#{id}"
  end
  def login?
    login
  end

  def active?
    !activated_at.nil? #login_by_email_token.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    #u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u = find :first, :conditions => ['login = ?', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
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

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def make_login_by_email_token
    self.login_by_email_token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
 
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      !email and (crypted_password.blank? || !password.blank?) or password
    end
    
    def password_confirmation?
      password
    end
   
end
