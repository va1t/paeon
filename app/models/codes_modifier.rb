class CodesModifier < ActiveRecord::Base

  #default scope hides records marked deleted   
  default_scope where(:deleted => false)
  scope :all, :order => "code ASC"
  
  attr_accessible :code, :description,
                  :created_user, :updated_user, :deleted

  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true


  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    
  
  
  def display_codes
    "#{code}, #{description}"
  end

end
