require 'test_helper'

class InsuredTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @instype = insured_types(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @instype.valid?    
   
    test_created_user @instype
    test_deleted @instype
  end
  
end
