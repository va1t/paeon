
# There are 4 roles for user access: everyone, admin, invoicing and super admin
# only the user id 'admin' is marked perm (so it cant be deleted) and marked super admin (ability_superadmin)
# super admin has access only to the maintenance area of the application.  This is so any
# records changes are done by an identified user and not an admin.
# the everyone role doesnt have any booleans provided.  Everyone has access to gorup, provide, patient, sessions, processing areas,
# plus there are some maintenance arears relating to claims processing that eveyone has acess to.  
# the ability_invoicing has everyone access plus access to the invoicing
# the admin role has access to all areas of the application, including maintenance areas not gien to everyone.
# two users can create / modify additional users to the system, the admin and superadmin.

class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, 
         :authentication_keys => [:login]

  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  # Setup to login using user name, need to override the default behavior for devise
  attr_accessor :login
   
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :perm, 
                  :login_name, :first_name, :last_name, :home_phone, :cell_phone, :login, 
                  :ability_invoice, :ability_admin, :ability_superadmin,
                  :created_user, :updated_user, :deleted
  
  MIN_LENGTH = 2
  MAX_LENGTH = 30
  
  validates :login_name, :presence => true, :length => {:minimum => MIN_LENGTH, :maximum => MAX_LENGTH}, :uniqueness => true
  validates :first_name, :presence => true, :length => {:minimum => MIN_LENGTH, :maximum => MAX_LENGTH}
  validates :last_name, :presence => true, :length => {:minimum => MIN_LENGTH, :maximum => MAX_LENGTH} 
  validates_format_of :email, :with => REGEX_EMAIL, :allow_nil => false, :allow_blank => false
  validates_format_of :home_phone, :with => REGEX_PHONE, :allow_nil => true, :allow_blank => true
  validates_format_of :cell_phone, :with => REGEX_PHONE, :allow_nil => true, :allow_blank => true
  
  validates :perm, :inclusion => {:in => [true, false]}
  validates :ability_invoice, :inclusion => {:in => [true, false]}
  validates :ability_admin, :inclusion => {:in => [true, false]}
  validates :ability_superadmin, :inclusion => {:in => [true, false]}
  
  validates :created_user, :presence => true
  
  
  # override the destory method to set the deleted boolean to true.
  # set to delete only if the perm boolean is false
  def destroy    
    run_callbacks :destroy do
      self.update_column(:deleted, true) if !self.perm
    end
  end  

  
  # Overwritten find_for_database_authentication method using :name for login 
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(login_name) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
  
end
