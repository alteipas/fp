require 'digest/sha1'
class Inhabitant < ActiveRecord::Base
  has_many :inputs, :class_name => "Transfer", :order=>'created_at DESC', :foreign_key=>'receiver_id'
  has_many :outputs, :class_name => "Transfer", :order=>'created_at DESC', :foreign_key=>'sender_id'
  has_many :invited_inhabitants, :class_name => "Inhabitant", :order=>'created_at DESC', :foreign_key=>'inviter_id'
  belongs_to :inviter, 
             :class_name => "Inhabitant" ,
             :foreign_key => "inviter_id"


  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :inviter_id,                        :unless => :superuser?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password, :if => :password_confirmation?

  validates_length_of       :login,    :within => 3..40, :allow_nil => true
  validates_length_of       :email,    :within => 3..100, :allow_nil => true
  validates_uniqueness_of   :login, :case_sensitive => false, :allow_nil => true
  validates_uniqueness_of   :email, :case_sensitive => false, :allow_nil => true
  validates_numericality_of :favs, :greater_than_or_equal_to=>0
  validates_numericality_of :invitation_favs, :greater_than=>0
  validate_on_create :inviter_enough_favs#, :unless => :superuser?
  after_create :first_transfer#, :unless => :superuser?
  before_save :encrypt_password
  before_create :make_login_by_email_token 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :url, :name, :inviter_id, :invitation_favs
  def superuser?
    login=='midas'
  end
  def inviter_enough_favs
    if !superuser?
      if !inviter.superuser? && inviter.favs < (invitation_favs || 1)
        errors.add_to_base("inviter doesn't have enough favs")
      end
    end
  end
  def first_transfer
    t=Transfer.create(:sender_id=>inviter_id, :receiver_id=>id, :amount=>invitation_favs || 1) unless superuser?
  end
  def login?
    login
  end
  def to_xml(*params)
    params[0]={:only=>[:id, :login, :favs, :url, :activated_at, :name]} unless params[0]
    super(*params)
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
