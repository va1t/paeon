#
#
# for each patient's subscriber record, there is a validation of coverage 
# with each provider and/or group.  the SubscriberValid table tracks the validation linking to the  
# provider / group by a polymorphic relationship and to the subscriber
#
#
class SubscriberValid < ActiveRecord::Base
  
  belongs_to :validable, :polymorphic => true  
  belongs_to :subscriber
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  # the in_network field will have one of the following three states 
  IN_NETWORK = 1
  OUT_NETWORK = 2
  NOT_VALIDATED = 0

  before_validation :format_date

  attr_accessible :in_network, :validated_date, :validable_type, :validable_id, :subscriber_id,
                  :created_user, :updated_user, :deleted,
                  :unformatted_validated_date

  attr_accessor :unformatted_validated_date
  
  validates :in_network, :inclusion => {:in => [IN_NETWORK, OUT_NETWORK, NOT_VALIDATED]}
  
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true

  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    

  #
  # returns the status string defining the validation status for the subscriber
  #  
  def status
    str = ""
    case self.in_network
      when IN_NETWORK
        str = "In Network"
      when OUT_NETWORK
        str = "Out of Network"
      else
        str = "Not Validated"
    end
    return str
  end
  
  # reformat the dates from m/d/y to y/m/d for storing in db
  def format_date      
    begin
      if !self.unformatted_validated_date.blank?
        self.validated_date = Date.strptime(self.unformatted_validated_date, "%m/%d/%Y").to_time(:utc)
      end
    rescue
      errors.add :base, "Invalid Date"
      return false
    end
  end

  
end
