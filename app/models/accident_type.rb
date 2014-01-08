class AccidentType < ActiveRecord::Base
  
  #
  # includes
  #
  include CommonStatus

  #
  # callbacks
  #
  after_initialize :set_permanent

  #
  # assignments
  #
  attr_accessible :name, :created_user, :updated_user, :perm
  attr_protected :status

  #
  # constants
  #
  TYPE_MAX_LENGTH = 50

  # there are four entires the system is seeded with perm = true
  # these four entries are used in various areas of the app so
  # constants are declared for their use
  ACCIDENT_TYPE_AUTO = "Auto"
  ACCIDENT_TYPE_EMPLOYMENT = "Employment"
  ACCIDENT_TYPE_NOT = "Not an Accident"
  ACCIDENT_TYPE_OTHER = "Other"

  #
  # validations
  #
  validates :name, :length => {:maximum => TYPE_MAX_LENGTH }, :presence => true
  validates :created_user, :presence => true

end
