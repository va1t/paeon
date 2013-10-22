class AccidentType < ActiveRecord::Base
  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  attr_accessible :name, :perm, :created_user, :updated_user, :deleted
    
  TYPE_MAX_LENGTH = 50
  
  # there are four entires the system is seeded with perm = true
  # these four entries are used in various areas of the app so
  # constants are declared for their use
  ACCIDENT_TYPE_AUTO = "Auto"
  ACCIDENT_TYPE_EMPLOYMENT = "Employment"
  ACCIDENT_TYPE_NOT = "Not an Accident"
  ACCIDENT_TYPE_OTHER = "Other"
  
  
  validates :name, :length => {:maximum => TYPE_MAX_LENGTH }, :presence => true
  validates :created_user, :presence => true
  validates :perm, :inclusion => {:in => [true, false]}
  validates :deleted, :inclusion => {:in => [true, false]}
  
  
  # override the destory method to set the deleted boolean to true.
  # the accident type name is stored in patient_injuries, not the id so there is no direct linkage to this table
  # do not need to worry about database integrity
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end
  
end
