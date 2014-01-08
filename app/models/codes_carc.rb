class CodesCarc < ActiveRecord::Base
  include CommonStatus
  
  attr_accessible :code, :description,
                  :created_user, :updated_user
  attr_protected :status
    
  validates :created_user, :presence => true
  
end
