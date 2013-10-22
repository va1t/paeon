class EdiVendor < ActiveRecord::Base
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false)

  scope :primary, :conditions => {:primary => true}

  before_save :ensure_one_primary
  
  attr_accessible :folder_receive_from, :folder_send_to, :ftp_address, :ftp_port, :name, :passive_mode_enabled, :password, :password_confirmation, :ssh_sftp_enabled, 
                  :trans835, :trans837d, :trans837i, :trans837p, :trans997, :trans999, :username, :primary, :testing,
                  :created_user, :updated_user, :deleted
                  
  NAME_LENGTH = 100
  FOLDER_LENGTH = 150
  MIN_LENGTH = 2
              
  validates :name, :presence => true, :length => {:minimum => MIN_LENGTH, :maximum => NAME_LENGTH}
  validates_confirmation_of :password
  
  validates :ftp_address, :length => {:minimum => MIN_LENGTH, :maximum => NAME_LENGTH}
  validates :ftp_port, :numericality => true
  
  validates :folder_send_to, :length => {:minimum => MIN_LENGTH, :maximum => FOLDER_LENGTH}
  validates :folder_receive_from, :length => {:minimum => MIN_LENGTH, :maximum => FOLDER_LENGTH}
  
  validates :trans835,  :inclusion => {:in => [true, false]}
  validates :trans837p, :inclusion => {:in => [true, false]}
  validates :trans837d, :inclusion => {:in => [true, false]}
  validates :trans837i, :inclusion => {:in => [true, false]}
  validates :trans997,  :inclusion => {:in => [true, false]}
  validates :trans999,  :inclusion => {:in => [true, false]}
  
  validates :ssh_sftp_enabled,     :inclusion => {:in => [true, false]}
  validates :passive_mode_enabled, :inclusion => {:in => [true, false]}
  validates :testing, :inclusion => {:in => [true, false]}
  
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true
  
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end                  
  
  def ensure_one_primary
    if self.primary && self.primary_changed?
      EdiVendor.update_all( {:primary => false} )
    end
  end
  
end
