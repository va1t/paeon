class CodesModifier < ActiveRecord::Base

  include CommonStatus

  scope :all, :order => "code ASC"

  attr_accessible :code, :description, :created_user, :updated_user
  attr_protected :status

  validates :created_user, :presence => true


  def display_codes
    "#{code}, #{description}"
  end

end
